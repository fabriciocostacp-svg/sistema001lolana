-- Adiciona constraint UNIQUE no campo nome da tabela servicos
-- Garante que não seja possível criar serviços duplicados pelo nome
ALTER TABLE public.servicos
  ADD CONSTRAINT servicos_nome_unique UNIQUE (nome);
