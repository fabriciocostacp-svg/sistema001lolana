import { getSupabasePublishableKey, getSupabaseUrl } from "@/lib/supabase-env";

function pickErrorMessage(data: Record<string, unknown>): string | null {
  const err = data.error;
  if (typeof err === 'string' && err.trim()) return err.trim();
  const msg = data.message;
  if (typeof msg === 'string' && msg.trim()) return msg.trim();
  const m = data.msg;
  if (typeof m === 'string' && m.trim()) return m.trim();
  return null;
}

interface ApiOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  body?: unknown;
  sessionToken?: string | null;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

async function callEdgeFunction<T>(
  functionName: string,
  options: ApiOptions = {},
  queryParams?: Record<string, string>
): Promise<T> {
  const { method = 'GET', body, sessionToken } = options;

  const baseUrl = getSupabaseUrl();
  if (!baseUrl) {
    throw new ApiError(
      'Configuração ausente: defina VITE_SUPABASE_URL no .env (pasta do projeto, pasta pai ou onde você rodou o npm) ou no Vercel.',
      503,
    );
  }

  const anon = getSupabasePublishableKey();
  if (!anon) {
    throw new ApiError(
      'Configuração ausente: defina VITE_SUPABASE_PUBLISHABLE_KEY (chave anon do Supabase) no Vercel e no .env.',
      503,
    );
  }

  let url = `${baseUrl}/functions/v1/${functionName}`;
  
  if (queryParams) {
    const params = new URLSearchParams(queryParams);
    url += `?${params.toString()}`;
  }
  
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${anon}`,
    apikey: anon,
  };

  if (sessionToken) {
    headers['x-session-token'] = sessionToken;
  }

  let response: Response;
  let raw: string;
  try {
    response = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });
    raw = await response.text();
  } catch (e) {
    if (e instanceof TypeError) {
      throw new ApiError(
        'Não foi possível conectar ao Supabase (Edge Functions). Confira: .env com VITE_SUPABASE_URL e VITE_SUPABASE_PUBLISHABLE_KEY; reinicie o npm run dev; projeto não pausado no painel; internet.',
        0,
      );
    }
    throw e;
  }
  let data: Record<string, unknown> = {};
  if (raw) {
    try {
      data = JSON.parse(raw) as Record<string, unknown>;
    } catch {
      throw new ApiError(
        'Resposta inválida do servidor',
        response.status || 500,
      );
    }
  }

  if (!response.ok) {
    const msg = pickErrorMessage(data) ?? 'Erro na requisição';
    throw new ApiError(msg, response.status);
  }

  return data as T;
}

// Auth APIs
export interface LoginResponse {
  user: {
    id: string;
    nome: string;
    usuario: string;
    telefone: string | null;
    permissions: {
      pode_dar_desconto: boolean;
      pode_cobrar_taxa: boolean;
      pode_pagar_depois: boolean;
      is_admin: boolean;
    };
  };
  sessionToken: string;
  expiresAt: string;
}

export async function apiLogin(usuario: string, senha: string): Promise<LoginResponse> {
  return callEdgeFunction<LoginResponse>('auth-login', {
    method: 'POST',
    body: { usuario, senha },
  });
}

export async function apiLogout(sessionToken: string): Promise<void> {
  await callEdgeFunction('auth-logout', {
    method: 'POST',
    sessionToken,
  });
}

export async function apiValidateSession(sessionToken: string): Promise<{ valid: boolean; user?: LoginResponse['user'] }> {
  return callEdgeFunction('auth-validate', {
    method: 'POST',
    sessionToken,
  });
}

export interface ResetPasswordRequestResponse {
  success: boolean;
  message: string;
  resetToken: string;
  usuario: string;
  nome: string;
}

export async function apiRequestPasswordReset(telefone: string): Promise<ResetPasswordRequestResponse> {
  return callEdgeFunction<ResetPasswordRequestResponse>('auth-reset-password', {
    method: 'POST',
    body: { action: 'request', telefone },
  });
}

export async function apiResetPassword(token: string, novaSenha: string): Promise<{ success: boolean; message: string }> {
  return callEdgeFunction('auth-reset-password', {
    method: 'POST',
    body: { action: 'reset', token, novaSenha },
  });
}

// Data APIs
export async function apiGetData<T>(
  table: 'clientes' | 'pedidos' | 'servicos',
  sessionToken: string,
  id?: string
): Promise<{ data: T }> {
  const queryParams: Record<string, string> = { table };
  if (id) queryParams.id = id;
  
  return callEdgeFunction<{ data: T }>('secure-api', {
    method: 'GET',
    sessionToken,
  }, queryParams);
}

export async function apiCreateData<T>(
  table: 'clientes' | 'pedidos' | 'servicos',
  sessionToken: string,
  data: Record<string, unknown>
): Promise<{ data: T }> {
  return callEdgeFunction<{ data: T }>('secure-api', {
    method: 'POST',
    sessionToken,
    body: data,
  }, { table });
}

export async function apiUpdateData<T>(
  table: 'clientes' | 'pedidos' | 'servicos',
  sessionToken: string,
  id: string,
  data: Record<string, unknown>
): Promise<{ data: T }> {
  return callEdgeFunction<{ data: T }>('secure-api', {
    method: 'PUT',
    sessionToken,
    body: { id, ...data },
  }, { table });
}

export async function apiDeleteData(
  table: 'clientes' | 'pedidos' | 'servicos',
  sessionToken: string,
  id: string
): Promise<{ success: boolean }> {
  return callEdgeFunction<{ success: boolean }>('secure-api', {
    method: 'DELETE',
    sessionToken,
  }, { table, id });
}

// Admin APIs (Funcionarios)
export async function apiGetFuncionarios<T>(sessionToken: string): Promise<{ data: T }> {
  return callEdgeFunction<{ data: T }>('admin-funcionarios', {
    method: 'GET',
    sessionToken,
  });
}

export async function apiCreateFuncionario<T>(
  sessionToken: string,
  data: Record<string, unknown>
): Promise<{ data: T }> {
  return callEdgeFunction<{ data: T }>('admin-funcionarios', {
    method: 'POST',
    sessionToken,
    body: data,
  });
}

export async function apiUpdateFuncionario<T>(
  sessionToken: string,
  id: string,
  data: Record<string, unknown>
): Promise<{ data: T }> {
  return callEdgeFunction<{ data: T }>('admin-funcionarios', {
    method: 'PUT',
    sessionToken,
    body: { id, ...data },
  });
}

export async function apiDeleteFuncionario(
  sessionToken: string,
  id: string
): Promise<{ success: boolean }> {
  return callEdgeFunction<{ success: boolean }>('admin-funcionarios', {
    method: 'DELETE',
    sessionToken,
  }, { id });
}
