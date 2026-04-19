-- =============================================================================
-- DADOS DE DEMONSTRAÇÃO — clientes, serviços (catálogo) e pedidos com itens
-- Rode no Supabase → SQL Editor (mesmo projeto do app).
--
-- IMPORTANTE: copie e execute o arquivo INTEIRO de uma vez.
-- Se rodar só um pedaço (ex.: a partir do meio do bloco DO), aparece erro
-- "unterminated dollar-quoted string" no END $$.
--
-- Requisitos:
--   • Tabelas clientes, pedidos, servicos já existirem (migrations do projeto).
--   • Em servicos: constraint UNIQUE(nome) — migration 20260412000000_unique...
--
-- O app NÃO importa dados de outro lugar: ele só mostra o que está no Postgres.
-- Rodar de novo cria MAIS clientes/pedidos (ex.: outro "Maria Silva" com outro número).
-- =============================================================================

-- 1) Catálogo de serviços (igual à migration original; atualiza preço se já existir)
INSERT INTO public.servicos (nome, categoria, preco) VALUES
  ('Por Kg', 'Serviços por KG', 26.00),
  ('Kg lavada e passada', 'Serviços por KG', 22.00),
  ('Kg lavar ou passar', 'Serviços por KG', 22.00),
  ('Edredom solteiro', 'Peças de Cama', 30.00),
  ('Edredom casal', 'Peças de Cama', 42.00),
  ('Coberdrom', 'Peças de Cama', 50.00),
  ('Camisa manga longa (lavar e passar)', 'Camisas', 17.00),
  ('Camisa manga longa (passar)', 'Camisas', 15.00),
  ('Camisa manga curta (lavar e passar)', 'Camisas', 15.00),
  ('Camisa manga curta (passar)', 'Camisas', 12.00),
  ('Vestido de festa (a partir de)', 'Vestido', 40.00),
  ('Calça', 'Valor Unitário', 10.00),
  ('Camiseta', 'Valor Unitário', 8.00),
  ('Short', 'Valor Unitário', 6.00),
  ('Paletó', 'Valor Unitário', 30.00),
  ('Terno completo', 'Valor Unitário', 70.00)
ON CONFLICT (nome) DO UPDATE SET
  categoria = EXCLUDED.categoria,
  preco = EXCLUDED.preco,
  ativo = EXCLUDED.ativo;

-- 2) Clientes + pedidos (triggers preenchem numero em clientes e pedidos)
DO $seed$
DECLARE
  s_por_kg   public.servicos%ROWTYPE;
  s_camisa   public.servicos%ROWTYPE;
  s_calca    public.servicos%ROWTYPE;
  c1_id uuid;
  c2_id uuid;
  c3_id uuid;
  itens1 jsonb;
  itens2 jsonb;
  itens3 jsonb;
BEGIN
  SELECT * INTO s_por_kg FROM public.servicos WHERE nome = 'Por Kg' LIMIT 1;
  SELECT * INTO s_camisa FROM public.servicos WHERE nome = 'Camisa manga curta (lavar e passar)' LIMIT 1;
  SELECT * INTO s_calca FROM public.servicos WHERE nome = 'Calça' LIMIT 1;

  IF s_camisa.id IS NULL THEN s_camisa := s_por_kg; END IF;
  IF s_calca.id IS NULL THEN s_calca := s_por_kg; END IF;

  IF s_por_kg.id IS NULL THEN
    RAISE EXCEPTION 'Serviço "Por Kg" não encontrado. Rode a parte de INSERT de serviços acima.';
  END IF;

  INSERT INTO public.clientes (nome, telefone, endereco)
  VALUES ('Maria Silva', '19991234001', 'Rua das Flores, 120 - Centro, Itirapina/SP')
  RETURNING id INTO c1_id;

  INSERT INTO public.clientes (nome, telefone, endereco)
  VALUES ('João Oliveira', '19991234002', 'Av. Principal, 450 - Itirapina/SP')
  RETURNING id INTO c2_id;

  INSERT INTO public.clientes (nome, telefone, endereco)
  VALUES ('Ana Costa', '19991234003', 'Rua Jurema, 88 - Itirapina/SP')
  RETURNING id INTO c3_id;

  itens1 := jsonb_build_array(
    jsonb_build_object(
      'quantidade', 2,
      'servico', jsonb_build_object(
        'id', s_por_kg.id::text,
        'nome', s_por_kg.nome,
        'categoria', s_por_kg.categoria,
        'preco', s_por_kg.preco
      )
    )
  );

  itens2 := jsonb_build_array(
    jsonb_build_object(
      'quantidade', 1,
      'servico', jsonb_build_object(
        'id', s_camisa.id::text,
        'nome', s_camisa.nome,
        'categoria', s_camisa.categoria,
        'preco', s_camisa.preco
      )
    ),
    jsonb_build_object(
      'quantidade', 2,
      'servico', jsonb_build_object(
        'id', s_calca.id::text,
        'nome', s_calca.nome,
        'categoria', s_calca.categoria,
        'preco', s_calca.preco
      )
    )
  );

  itens3 := jsonb_build_array(
    jsonb_build_object(
      'quantidade', 1.5,
      'servico', jsonb_build_object(
        'id', s_por_kg.id::text,
        'nome', s_por_kg.nome,
        'categoria', s_por_kg.categoria,
        'preco', s_por_kg.preco
      )
    )
  );

  INSERT INTO public.pedidos (
    cliente_id, cliente_nome, cliente_telefone,
    valor_total, status, itens, pago, retirado,
    desconto_percentual, desconto_valor, taxa_entrega
  )
  VALUES (
    c1_id, 'Maria Silva', '19991234001',
    (2 * s_por_kg.preco), 'lavando', itens1, false, false, 0, 0, 0
  );

  INSERT INTO public.pedidos (
    cliente_id, cliente_nome, cliente_telefone,
    valor_total, status, itens, pago, retirado,
    desconto_percentual, desconto_valor, taxa_entrega
  )
  VALUES (
    c2_id, 'João Oliveira', '19991234002',
    (s_camisa.preco + 2 * s_calca.preco), 'passando', itens2, true, false, 0, 0, 0
  );

  INSERT INTO public.pedidos (
    cliente_id, cliente_nome, cliente_telefone,
    valor_total, status, itens, pago, retirado,
    desconto_percentual, desconto_valor, taxa_entrega
  )
  VALUES (
    c3_id, 'Ana Costa', '19991234003',
    round((1.5 * s_por_kg.preco)::numeric, 2), 'pronto', itens3, true, true, 0, 0, 0
  );
END $seed$;

-- Conferência rápida
SELECT 'servicos' AS tabela, count(*)::bigint AS qtd FROM public.servicos
UNION ALL
SELECT 'clientes', count(*) FROM public.clientes
UNION ALL
SELECT 'pedidos', count(*) FROM public.pedidos;
