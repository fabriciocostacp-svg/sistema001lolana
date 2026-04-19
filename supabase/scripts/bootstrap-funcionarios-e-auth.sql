-- Rode no Supabase: SQL Editor (projeto correto).
-- Corrige banco onde existe clientes/pedidos mas NÃO existe funcionarios (login quebra).

-- Login: lolana / 1234 (bcrypt). Troque em produção.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1) Funcionários
CREATE TABLE IF NOT EXISTS public.funcionarios (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  usuario VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL,
  telefone VARCHAR(20),
  pode_dar_desconto BOOLEAN NOT NULL DEFAULT false,
  pode_cobrar_taxa BOOLEAN NOT NULL DEFAULT false,
  pode_pagar_depois BOOLEAN NOT NULL DEFAULT false,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger updated_at (só se a função já existir no projeto)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'update_updated_at_column'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_funcionarios_updated_at'
  ) THEN
    CREATE TRIGGER update_funcionarios_updated_at
      BEFORE UPDATE ON public.funcionarios
      FOR EACH ROW
      EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

-- Usuário admin (bcrypt — exigido pela Edge auth-login)
INSERT INTO public.funcionarios (
  nome, usuario, senha, telefone,
  pode_dar_desconto, pode_cobrar_taxa, pode_pagar_depois, is_admin, ativo
)
VALUES (
  'Administrador',
  'lolana',
  crypt('1234', gen_salt('bf')),
  '',
  true, true, true, true, true
)
ON CONFLICT (usuario) DO UPDATE SET
  senha = EXCLUDED.senha,
  ativo = true,
  nome = EXCLUDED.nome;

-- 2) Sessões (login grava aqui após senha OK)
CREATE TABLE IF NOT EXISTS public.sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID NOT NULL REFERENCES public.funcionarios(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON public.sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON public.sessions(expires_at);

-- 3) Reset de senha
CREATE TABLE IF NOT EXISTS public.password_resets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  funcionario_id UUID NOT NULL REFERENCES public.funcionarios(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_password_resets_token ON public.password_resets(token);

-- 4) Rate limit de login
CREATE TABLE IF NOT EXISTS public.login_attempts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  identifier TEXT NOT NULL,
  identifier_type TEXT NOT NULL CHECK (identifier_type IN ('username', 'ip', 'phone')),
  ip_address TEXT,
  success BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_login_attempts_identifier
  ON public.login_attempts (identifier, identifier_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_login_attempts_ip
  ON public.login_attempts (ip_address, identifier_type, created_at DESC);

-- Conferência
SELECT EXISTS (
  SELECT 1 FROM information_schema.tables
  WHERE table_schema = 'public' AND table_name = 'funcionarios'
) AS existe_funcionarios;

SELECT usuario, ativo, left(senha, 7) AS senha_prefixo FROM public.funcionarios;
