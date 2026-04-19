-- =============================================================================
-- Criar (ou atualizar) usuário com TODAS as permissões do sistema Lolana
-- Rode no Supabase → SQL Editor
--
-- Pré-requisito: tabela public.funcionarios já existir
-- (se não existir, rode antes: supabase/scripts/bootstrap-funcionarios-e-auth.sql)
--
-- ANTES DE RODAR: altere nome_usuario, nome_exibicao, telefone e senha_texto
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- <<< edite estes quatro valores >>>
DO $$
DECLARE
  nome_usuario   text := 'lolana';              -- login (único)
  nome_exibicao  text := 'Administrador';     -- nome na tela
  telefone       text := '';                   -- só dígitos / vazio; use no "Esqueci minha senha"
  senha_texto    text := 'DefinaSenhaForte2026!';  -- mín. 8 chars; letras + número (regra do app)
BEGIN
  IF length(trim(senha_texto)) < 8 THEN
    RAISE EXCEPTION 'Senha deve ter pelo menos 8 caracteres';
  END IF;

  INSERT INTO public.funcionarios (
    nome,
    usuario,
    senha,
    telefone,
    pode_dar_desconto,
    pode_cobrar_taxa,
    pode_pagar_depois,
    is_admin,
    ativo
  )
  VALUES (
    nome_exibicao,
    lower(trim(nome_usuario)),
    crypt(senha_texto, gen_salt('bf')),
    NULLIF(trim(telefone), ''),
    true,  -- pode_dar_desconto
    true,  -- pode_cobrar_taxa
    true,  -- pode_pagar_depois
    true,  -- is_admin
    true   -- ativo
  )
  ON CONFLICT (usuario) DO UPDATE SET
    nome = EXCLUDED.nome,
    senha = EXCLUDED.senha,
    telefone = EXCLUDED.telefone,
    pode_dar_desconto = true,
    pode_cobrar_taxa = true,
    pode_pagar_depois = true,
    is_admin = true,
    ativo = true,
    updated_at = now();
END $$;

-- Conferência
SELECT
  usuario,
  nome,
  telefone,
  ativo,
  pode_dar_desconto,
  pode_cobrar_taxa,
  pode_pagar_depois,
  is_admin,
  left(senha, 4) AS senha_eh_bcrypt
FROM public.funcionarios
WHERE usuario = lower(trim('lolana'));  -- mesmo login do bloco acima (ajuste se mudou nome_usuario)
