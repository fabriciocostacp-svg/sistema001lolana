-- IMPORT servicos gerado a partir de: backup_servicos_colado.csv
-- Linhas: 16
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- Requer CONSTRAINT UNIQUE(nome) em servicos.

ALTER TABLE public.servicos
  ADD COLUMN IF NOT EXISTS ativo boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

INSERT INTO public.servicos (nome, categoria, preco, ativo, created_at)
VALUES
  ('Camisa manga curta (lavar e passar)', 'Camisas', 15.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Camisa manga curta (passar)', 'Camisas', 12.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Camisa manga longa (lavar e passar)', 'Camisas', 17.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Camisa manga longa (passar)', 'Camisas', 15.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Coberdrom', 'Peças de Cama', 50.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Edredom casal', 'Peças de Cama', 42.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Edredom solteiro', 'Peças de Cama', 30.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Kg lavada e passada', 'Serviços por KG', 22.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Kg lavar ou passar', 'Serviços por KG', 22.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Por Kg', 'Serviços por KG', 26.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Calça', 'Valor Unitário', 10.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Camiseta', 'Valor Unitário', 8.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Paletó', 'Valor Unitário', 30.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Short', 'Valor Unitário', 6.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Terno completo', 'Valor Unitário', 70.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz),
  ('Vestido de festa (a partir de)', 'Vestido', 40.00, true, '2026-03-21T10:06:16.110541+00:00'::timestamptz)

ON CONFLICT (nome) DO UPDATE SET
  categoria = EXCLUDED.categoria,
  preco = EXCLUDED.preco,
  ativo = EXCLUDED.ativo,
  created_at = EXCLUDED.created_at,
  updated_at = now();

SELECT count(*)::bigint AS servicos_total FROM public.servicos;
