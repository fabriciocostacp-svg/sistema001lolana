-- =============================================================================
-- RESTAURAR DADOS LOLANA (clientes + servicos + pedidos) — um unico ficheiro
-- =============================================================================
-- ANTES: (1) migrations aplicadas (2) instalar-login-no-banco.sql (3) UNIQUE em servicos(nome)
-- Isto so repoe DADOS. Ordem: clientes -> servicos -> pedidos.
-- Pedidos com itens [] se backup CSV tinha [object Object].
-- Execute o ficheiro INTEIRO no SQL Editor.
-- =============================================================================

-- Colunas usadas pelos INSERTs abaixo (bases antigas / sem migrations completas)
ALTER TABLE public.clientes
  ADD COLUMN IF NOT EXISTS cpf text,
  ADD COLUMN IF NOT EXISTS cnpj text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

ALTER TABLE public.servicos
  ADD COLUMN IF NOT EXISTS ativo boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

ALTER TABLE public.pedidos
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS pago boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS retirado boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS desconto_percentual numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS desconto_valor numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS taxa_entrega numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cliente_cpf text,
  ADD COLUMN IF NOT EXISTS cliente_cnpj text;

-- ########## CLIENTES ##########

-- IMPORT clientes gerado a partir de: backup_clientes_colado.csv
-- Linhas no CSV: 59 | VALUES gerados: 59
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- session_replication_role=replica: triggers normais nao disparam (mantem numeros do backup).
-- ON CONFLICT (numero) atualiza nome, telefone, endereco, cpf, cnpj, created_at.

BEGIN;

SET LOCAL session_replication_role = replica;

INSERT INTO public.clientes (numero, nome, telefone, endereco, cpf, cnpj, created_at)
VALUES
  ('001', 'Jose Roberto', '19993494444', 'Rua 1', NULL, NULL, '2026-01-21T13:04:59.905375+00:00'::timestamptz),
  ('002', 'Rafael Lira', '19997415137', 'Rua 1 edificio STA eugenia', NULL, NULL, '2026-01-21T17:47:23.584787+00:00'::timestamptz),
  ('003', 'Silvana', '19996212341', 'Rua jaraguarucu n⁰427 jd Nova Itirapina', NULL, NULL, '2026-01-21T19:14:33.22305+00:00'::timestamptz),
  ('004', 'Eduardo', '16991849944', 'Centro', NULL, NULL, '2026-01-22T14:11:24.781947+00:00'::timestamptz),
  ('005', 'Daniela( Dani)', '19971553618', 'Av13n⁰50 Santa Cruz', NULL, NULL, '2026-01-22T18:46:27.84404+00:00'::timestamptz),
  ('006', 'Andréia.', '16997844747', 'Condomínio Hobby', NULL, NULL, '2026-01-23T11:27:19.429816+00:00'::timestamptz),
  ('007', 'Desirée', '19999756868', 'Jardim Uba', NULL, NULL, '2026-01-23T12:01:40.702836+00:00'::timestamptz),
  ('012', 'Lurdinha', '19997992142', 'Jardim do Sol', NULL, NULL, '2026-01-30T14:57:32.530842+00:00'::timestamptz),
  ('013', 'Ivete Andrioli', '19998659624', 'Analândia', NULL, NULL, '2026-02-02T12:28:53.307108+00:00'::timestamptz),
  ('014', 'Carlos( mot.Padovani)', '19997292924', 'São Carlos', NULL, NULL, '2026-02-02T12:37:07.132178+00:00'::timestamptz),
  ('015', 'Mary', '16997681999', 'Condomínio Hobby', NULL, NULL, '2026-02-02T12:40:06.74042+00:00'::timestamptz),
  ('016', 'Márcia ( Analândia)', '19999972327', 'Analândia', NULL, NULL, '2026-02-02T12:47:05.535022+00:00'::timestamptz),
  ('017', 'Taty(Analândia)', '19993024640', 'Nova Analândia', NULL, NULL, '2026-02-02T12:48:07.262561+00:00'::timestamptz),
  ('018', 'D.Rita', '19996080224', 'Condomínio Hobby', NULL, NULL, '2026-02-02T12:58:35.545421+00:00'::timestamptz),
  ('019', 'Ariane', '19998813672', 'Rua cinco centro', NULL, NULL, '2026-02-02T20:33:28.579695+00:00'::timestamptz),
  ('020', 'Fabio', '14997141155', 'Monte Alegre', NULL, NULL, '2026-02-02T20:43:09.334284+00:00'::timestamptz),
  ('021', 'Flávia', '19991928317', 'Rua 1 jardim dos Eucaliptos', NULL, NULL, '2026-02-02T20:46:50.281408+00:00'::timestamptz),
  ('022', 'Renata  Andrade', '19996864539', 'Rua perimetral Jd N Itirapina', NULL, NULL, '2026-02-02T20:54:41.891989+00:00'::timestamptz),
  ('023', 'Renata.', '19996023645', 'Parque das Garças', NULL, NULL, '2026-02-04T18:01:31.432467+00:00'::timestamptz),
  ('024', 'Bruna', '19996554453', 'Jardim Lemos', NULL, NULL, '2026-02-04T18:02:39.922456+00:00'::timestamptz),
  ('025', 'Angélica', '19996368378', 'Rua cinco centro', NULL, NULL, '2026-02-04T18:03:42.700137+00:00'::timestamptz),
  ('026', 'Ariane Nardi', '19997295303', 'Santa Cruz', NULL, NULL, '2026-02-04T18:23:49.774919+00:00'::timestamptz),
  ('027', 'Gabriel Salles', '11959582154', 'Rural', NULL, NULL, '2026-02-04T18:33:21.778885+00:00'::timestamptz),
  ('028', 'Cleo', '19981004998', 'Centro', NULL, NULL, '2026-02-04T18:44:12.979559+00:00'::timestamptz),
  ('029', 'Chácara Amarela (Lilian)', '19997337334', 'Analândia', NULL, NULL, '2026-02-05T18:24:35.653832+00:00'::timestamptz),
  ('030', 'Rubens Nascimento', '19971498064', 'Vila Garbi', NULL, NULL, '2026-02-06T13:21:11.435721+00:00'::timestamptz),
  ('031', 'Carol', '19996690494', 'Vila monte Alegre', NULL, NULL, '2026-02-06T20:14:43.369446+00:00'::timestamptz),
  ('032', 'Elton', '14981135830', 'Rua 2centro', NULL, NULL, '2026-02-06T20:56:23.857173+00:00'::timestamptz),
  ('033', 'Paulinha', '19997517136', 'Rua cinco -Vila Garbi', NULL, NULL, '2026-02-10T18:53:38.287705+00:00'::timestamptz),
  ('034', 'Cladis', '19996410082', 'Avenida 3 centro', NULL, NULL, '2026-02-11T17:25:00.852235+00:00'::timestamptz),
  ('035', 'Barbara Pucci', '19996231818', 'Santa Cruz', NULL, NULL, '2026-02-12T13:12:50.04189+00:00'::timestamptz),
  ('036', 'Patrícia', '19999968645', 'Centro', NULL, NULL, '2026-02-12T13:28:17.750255+00:00'::timestamptz),
  ('037', 'Sandra ( Pousada Cambucá)', '16997139526', 'Ubá ( rua onze)', NULL, NULL, '2026-02-12T17:46:48.270185+00:00'::timestamptz),
  ('038', 'Karline', '19998365365', 'Jardim do Sol', NULL, NULL, '2026-02-18T17:03:32.264935+00:00'::timestamptz),
  ('039', 'Carol', '19996690494', 'Monte Alegre', NULL, NULL, '2026-02-19T19:18:19.874507+00:00'::timestamptz),
  ('040', 'Santiago', '11975937070', 'Vila Garbi avenida 6', NULL, NULL, '2026-02-19T19:38:32.683595+00:00'::timestamptz),
  ('041', 'Migrar', '19996552128', 'Santa Cruz', NULL, NULL, '2026-02-20T12:53:29.377377+00:00'::timestamptz),
  ('042', 'Beatriz', '17992108638', 'Ed. Santa Eugênia', NULL, NULL, '2026-02-20T13:13:09.856325+00:00'::timestamptz),
  ('043', 'Giane.', '19971182812', 'Vila Cianelli', NULL, NULL, '2026-02-20T13:19:03.620268+00:00'::timestamptz),
  ('044', 'Wanice( Lagoa Dourada)', '169997214551', 'Lagoa Dourada', NULL, NULL, '2026-02-20T13:21:43.63269+00:00'::timestamptz),
  ('045', 'Tiago( Mundy)', '19998501919', 'Jardim Dallas', NULL, NULL, '2026-02-25T18:33:57.381523+00:00'::timestamptz),
  ('046', 'Célia Botelho', '11999925546', 'Condomínio Broa', NULL, NULL, '2026-02-27T10:52:15.033607+00:00'::timestamptz),
  ('047', 'Pousada Hortelã Pimenta Raphael', '447934645050', 'Jardim Uba', NULL, NULL, '2026-03-02T19:52:38.433736+00:00'::timestamptz),
  ('048', 'Bianca( Bianchini)', '19996839755', 'Jardim do Sol', NULL, NULL, '2026-03-11T12:21:42.416648+00:00'::timestamptz),
  ('049', 'Padre Dony', '19971264191', 'Av 8- vila Garbi', NULL, NULL, '2026-03-11T13:02:43.52992+00:00'::timestamptz),
  ('050', 'Natan', '19981827871', 'Rua 3-298', NULL, NULL, '2026-03-12T12:32:56.241223+00:00'::timestamptz),
  ('051', 'Jaco', '16996033324', 'Jardim Lemos', NULL, NULL, '2026-03-16T17:47:20.901881+00:00'::timestamptz),
  ('052', 'Fabiana', '16997282830', 'Fazenda', NULL, NULL, '2026-03-16T17:57:37.012556+00:00'::timestamptz),
  ('053', 'Nádia Robin', '19997981530', 'Jardim Planalto', NULL, NULL, '2026-03-16T18:54:27.173174+00:00'::timestamptz),
  ('054', 'Nadia Robin', '19997981530', 'Jardim Planalto', NULL, NULL, '2026-03-16T18:56:17.831105+00:00'::timestamptz),
  ('055', 'Thais Barreto', '7592134251', 'Santa Eugênia', NULL, NULL, '2026-03-18T18:51:27.822222+00:00'::timestamptz),
  ('056', 'Franklin', '19998825830', 'Jardim do Sol', NULL, NULL, '2026-03-18T18:59:34.112041+00:00'::timestamptz),
  ('057', 'Milena', '19998088100', 'Jd. Nova itirapina', NULL, NULL, '2026-03-18T19:02:57.248642+00:00'::timestamptz),
  ('058', 'Diana', '19999706566', 'Vale Verde', NULL, NULL, '2026-03-18T19:05:47.925304+00:00'::timestamptz),
  ('059', 'Cesar', '11983340312', 'Centro', NULL, NULL, '2026-03-18T19:23:42.855674+00:00'::timestamptz),
  ('060', 'Cecília Salles', '16982044116', 'Cianeli Av 2', NULL, NULL, '2026-03-18T19:27:45.600702+00:00'::timestamptz),
  ('061', 'Enathara', '19992190555', 'Edifício santa Eugênia', NULL, NULL, '2026-03-19T12:45:06.570942+00:00'::timestamptz),
  ('062', 'Alex', '19997597602', 'Vila Garbi', NULL, NULL, '2026-03-24T20:13:33.95115+00:00'::timestamptz),
  ('063', 'Luciane pilon', '19997635305', 'Cianelli', NULL, NULL, '2026-03-27T13:25:44.200468+00:00'::timestamptz)

ON CONFLICT (numero) DO UPDATE SET
  nome = EXCLUDED.nome,
  telefone = EXCLUDED.telefone,
  endereco = EXCLUDED.endereco,
  cpf = EXCLUDED.cpf,
  cnpj = EXCLUDED.cnpj,
  created_at = EXCLUDED.created_at,
  updated_at = now();

SET LOCAL session_replication_role = origin;

COMMIT;

SELECT count(*)::bigint AS clientes_total FROM public.clientes;


-- ########## SERVICOS ##########

-- IMPORT servicos gerado a partir de: backup_servicos_colado.csv
-- Linhas: 16
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- Requer CONSTRAINT UNIQUE(nome) em servicos.

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


-- ########## PEDIDOS ##########

-- IMPORT pedidos gerado a partir de: backup_pedidos_2026-04-02.csv
-- Total de linhas no CSV: 95 | INSERTs gerados: 95
-- Rode no Supabase SQL Editor o ficheiro INTEIRO.
-- Liga ao cliente pelo telefone (so digitos). Prefere nome igual (trim+lower);
-- se nao bater o nome, usa o cliente mais antigo com esse telefone (evita 0 rows).
--
ALTER TABLE public.pedidos
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS pago boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS retirado boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS desconto_percentual numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS desconto_valor numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS taxa_entrega numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cliente_cpf text,
  ADD COLUMN IF NOT EXISTS cliente_cnpj text;

BEGIN;
SET LOCAL session_replication_role = replica;

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '105', c.id, 'Cecília Salles', '16982044116',
  75.00, 'pronto', false, false,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-27T20:07:18.046949+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16982044116'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cecília Salles')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '104', c.id, 'Luciane pilon', '19997635305',
  96.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-03-27T17:10:38.401331+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997635305'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Luciane pilon')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '103', c.id, 'Silvana', '19996212341',
  198.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-27T13:35:13.460826+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '101', c.id, 'Alex', '19997597602',
  42.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-24T20:19:27.572181+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997597602'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Alex')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '100', c.id, 'Enathara', '19992190555',
  102.00, 'pronto', true, true,
  0.00, 8.00, 0.00,
  '[]'::jsonb, '2026-03-19T12:45:45.06731+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19992190555'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Enathara')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '098', c.id, 'Cesar', '11983340312',
  45.00, 'pronto', false, false,
  0.00, 0.00, 3.00,
  '[]'::jsonb, '2026-03-18T19:25:07.738446+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11983340312'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cesar')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '097', c.id, 'Ariane Nardi', '19997295303',
  87.00, 'pronto', true, true,
  0.00, 0.00, 3.00,
  '[]'::jsonb, '2026-03-18T19:22:10.683812+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997295303'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Ariane Nardi')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '096', c.id, 'Renata.', '19996023645',
  264.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-18T19:17:26.804698+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996023645'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata.')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '095', c.id, 'Diana', '19999706566',
  87.00, 'pronto', true, true,
  0.00, 0.00, 10.00,
  '[]'::jsonb, '2026-03-18T19:06:47.526678+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999706566'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Diana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '094', c.id, 'Milena', '19998088100',
  140.00, 'lavando', false, false,
  0.00, 10.00, 0.00,
  '[]'::jsonb, '2026-03-18T19:03:56.038364+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998088100'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Milena')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '093', c.id, 'Desirée', '19999756868',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-03-18T19:01:17.279393+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999756868'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Desirée')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '092', c.id, 'Franklin', '19998825830',
  70.00, 'pronto', true, true,
  0.00, 0.00, 10.00,
  '[]'::jsonb, '2026-03-18T19:00:40.487653+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998825830'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Franklin')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '091', c.id, 'Pousada Hortelã Pimenta', '447934645050',
  148.00, 'pronto', true, true,
  0.00, 0.00, 18.00,
  '[]'::jsonb, '2026-03-18T18:57:17.039094+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('447934645050'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Pousada Hortelã Pimenta')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '090', c.id, 'Thais Barreto', '7592134251',
  149.00, 'pronto', true, true,
  0.00, 0.00, 7.00,
  '[]'::jsonb, '2026-03-18T18:52:24.677371+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('7592134251'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Thais Barreto')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '089', c.id, 'Eduardo', '16991849944',
  65.00, 'pronto', true, true,
  0.00, 13.00, 0.00,
  '[]'::jsonb, '2026-03-18T18:49:23.883595+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16991849944'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Eduardo')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '088', c.id, 'Daniela( Dani)', '19971553618',
  230.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-03-18T18:47:31.709824+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '086', c.id, 'Silvana', '19996212341',
  251.00, 'pronto', true, true,
  0.00, 0.00, 9.00,
  '[]'::jsonb, '2026-03-17T19:41:28.861941+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '085', c.id, 'Desirée', '19999756868',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-03-17T13:44:41.04952+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999756868'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Desirée')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '084', c.id, 'Nadia Robin', '19997981530',
  26.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-16T18:56:53.238972+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997981530'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Nadia Robin')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '083', c.id, 'Cladis', '19996410082',
  58.00, 'lavando', false, false,
  0.00, 0.00, 6.00,
  '[]'::jsonb, '2026-03-16T18:52:45.933484+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996410082'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cladis')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '082', c.id, 'Daniela( Dani)', '19971553618',
  331.00, 'pronto', true, true,
  0.00, 7.00, 0.00,
  '[]'::jsonb, '2026-03-16T18:46:45.851207+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '081', c.id, 'Fabiana', '16997282830',
  45.00, 'pronto', true, true,
  0.00, 0.00, 3.00,
  '[]'::jsonb, '2026-03-16T17:58:52.94163+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16997282830'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Fabiana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '080', c.id, 'Natan', '19981827871',
  108.00, 'pronto', true, true,
  0.00, 0.00, 4.00,
  '[]'::jsonb, '2026-03-16T17:53:32.829898+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19981827871'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Natan')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '079', c.id, 'Jaco', '16996033324',
  135.00, 'pronto', true, true,
  0.00, 0.00, 13.00,
  '[]'::jsonb, '2026-03-16T17:51:23.001562+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16996033324'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Jaco')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '078', c.id, 'Célia Botelho', '11999925546',
  42.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-12T20:44:57.801411+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11999925546'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Célia Botelho')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '077', c.id, 'Carol', '19996690494',
  74.00, 'pronto', false, false,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-12T20:34:06.912138+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996690494'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Carol')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '076', c.id, 'Padre Dony', '19971264191',
  83.00, 'pronto', true, true,
  0.00, 0.00, 5.00,
  '[]'::jsonb, '2026-03-12T18:48:15.065993+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971264191'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Padre Dony')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '075', c.id, 'D.Rita', '19996080224',
  323.00, 'pronto', true, true,
  0.00, 0.00, 11.00,
  '[]'::jsonb, '2026-03-12T14:42:53.19892+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996080224'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('D.Rita')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '074', c.id, 'Natan', '19981827871',
  108.00, 'pronto', false, false,
  0.00, 0.00, 4.00,
  '[]'::jsonb, '2026-03-12T12:34:20.619494+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19981827871'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Natan')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '073', c.id, 'Daniela( Dani)', '19971553618',
  272.00, 'lavando', false, false,
  0.00, 14.00, 0.00,
  '[]'::jsonb, '2026-03-12T12:31:30.452158+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '072', c.id, 'Bianca( Bianchini)', '19996839755',
  71.00, 'pronto', true, true,
  0.00, 17.00, 0.00,
  '[]'::jsonb, '2026-03-11T19:07:51.499588+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996839755'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Bianca( Bianchini)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '070', c.id, 'Gabriel Salles', '11959582154',
  111.00, 'pronto', true, true,
  0.00, 0.00, 7.00,
  '[]'::jsonb, '2026-03-11T12:20:10.440223+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11959582154'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Gabriel Salles')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '069', c.id, 'Daniela( Dani)', '19971553618',
  182.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-10T16:53:36.509876+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '068', c.id, 'Sandra ( Pousada Cambucá)', '16997139526',
  126.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-03-04T13:57:35.404169+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16997139526'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Sandra ( Pousada Cambucá)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '067', c.id, 'Eduardo', '16991849944',
  59.00, 'pronto', true, true,
  0.00, 1.00, 0.00,
  '[]'::jsonb, '2026-03-03T19:31:47.908397+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16991849944'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Eduardo')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '066', c.id, 'Rubens Nascimento', '19971498064',
  127.00, 'pronto', false, false,
  0.00, 3.00, 0.00,
  '[]'::jsonb, '2026-03-03T14:47:45.238797+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971498064'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Rubens Nascimento')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '065', c.id, 'Renata  Andrade', '19996864539',
  60.00, 'pronto', true, true,
  0.00, 6.00, 0.00,
  '[]'::jsonb, '2026-03-02T19:58:41.285957+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996864539'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata  Andrade')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '064', c.id, 'Pousada Hortelã Pimenta', '447934645050',
  90.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-02T19:53:31.794566+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('447934645050'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Pousada Hortelã Pimenta')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '063', c.id, 'Silvana', '19996212341',
  279.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-02T19:45:30.583605+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '062', c.id, 'Renata  Andrade', '19996864539',
  257.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-03-02T18:48:08.846958+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996864539'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata  Andrade')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '061', c.id, 'Eduardo', '16991849944',
  65.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-02-27T20:44:48.418134+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16991849944'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Eduardo')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '060', c.id, 'Daniela( Dani)', '19971553618',
  258.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-02-27T19:24:17.190305+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '059', c.id, 'Cladis', '19996410082',
  43.00, 'lavando', false, false,
  0.00, 0.00, 2.00,
  '[]'::jsonb, '2026-02-27T19:07:02.636146+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996410082'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cladis')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '058', c.id, 'Renata  Andrade', '19996864539',
  257.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-27T11:12:15.055983+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996864539'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata  Andrade')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '057', c.id, 'Giane.', '19971182812',
  90.00, 'pronto', true, true,
  0.00, 10.00, 0.00,
  '[]'::jsonb, '2026-02-27T11:08:42.557504+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971182812'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Giane.')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '056', c.id, 'Célia Botelho', '11999925546',
  315.00, 'pronto', true, true,
  0.00, 0.00, 3.00,
  '[]'::jsonb, '2026-02-27T10:53:15.313294+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11999925546'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Célia Botelho')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '055', c.id, 'Tiago( Mundy)', '19998501919',
  176.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-02-25T18:38:11.016508+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998501919'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Tiago( Mundy)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '054', c.id, 'Daniela( Dani)', '19971553618',
  416.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-25T14:47:57.76934+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '053', c.id, 'Gabriel Salles', '11959582154',
  130.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-20T19:56:27.261966+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11959582154'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Gabriel Salles')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '052', c.id, 'Wanice( Lagoa Dourada)', '169997214551',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-02-20T13:24:05.718298+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('169997214551'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Wanice( Lagoa Dourada)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '051', c.id, 'Giane.', '19971182812',
  90.00, 'pronto', true, true,
  0.00, 10.00, 0.00,
  '[]'::jsonb, '2026-02-20T13:20:03.214707+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971182812'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Giane.')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '050', c.id, 'Beatriz', '17992108638',
  130.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-20T13:15:04.751448+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('17992108638'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Beatriz')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '049', c.id, 'Migrar', '19996552128',
  89.00, 'pronto', true, true,
  0.00, 0.00, 1.00,
  '[]'::jsonb, '2026-02-20T13:03:58.418077+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996552128'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Migrar')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '048', c.id, 'Santiago', '11975937070',
  108.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-19T19:39:34.466954+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11975937070'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Santiago')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '047', c.id, 'Daniela( Dani)', '19971553618',
  448.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-19T19:28:20.153805+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '046', c.id, 'Silvana', '19996212341',
  170.00, 'pronto', true, true,
  0.00, 6.00, 0.00,
  '[]'::jsonb, '2026-02-19T19:26:52.438818+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '045', c.id, 'Carol', '19996690494',
  192.00, 'pronto', true, true,
  0.00, 3.00, 0.00,
  '[]'::jsonb, '2026-02-19T19:20:45.363815+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996690494'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Carol')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '044', c.id, 'Bruna', '19996554453',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-02-18T17:04:44.880721+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996554453'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Bruna')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '043', c.id, 'Karline', '19998365365',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-02-18T17:04:14.407158+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998365365'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Karline')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '042', c.id, 'D.Rita', '19996080224',
  113.00, 'pronto', true, true,
  0.00, 17.00, 0.00,
  '[]'::jsonb, '2026-02-13T14:20:00.662711+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996080224'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('D.Rita')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '041', c.id, 'Sandra ( Pousada Cambucá)', '16997139526',
  113.00, 'pronto', true, true,
  0.00, 0.00, 3.00,
  '[]'::jsonb, '2026-02-12T17:47:48.344969+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16997139526'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Sandra ( Pousada Cambucá)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '040', c.id, 'Daniela( Dani)', '19971553618',
  182.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-12T17:15:42.273182+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '039', c.id, 'Patrícia', '19999968645',
  45.00, 'pronto', false, false,
  0.00, 0.00, 5.00,
  '[]'::jsonb, '2026-02-12T13:29:30.097869+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999968645'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Patrícia')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '038', c.id, 'Barbara Pucci', '19996231818',
  75.00, 'pronto', false, false,
  0.00, 5.00, 0.00,
  '[]'::jsonb, '2026-02-12T13:14:07.808106+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996231818'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Barbara Pucci')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '037', c.id, 'Cladis', '19996410082',
  87.00, 'pronto', true, true,
  0.00, 17.00, 0.00,
  '[]'::jsonb, '2026-02-11T17:26:28.65206+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996410082'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cladis')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '036', c.id, 'Paulinha', '19997517136',
  222.00, 'pronto', true, true,
  0.00, 12.00, 0.00,
  '[]'::jsonb, '2026-02-10T18:55:10.491755+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997517136'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Paulinha')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '035', c.id, 'Daniela( Dani)', '19971553618',
  245.00, 'pronto', true, true,
  0.00, 15.00, 0.00,
  '[]'::jsonb, '2026-02-06T21:27:32.107202+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '034', c.id, 'Elton', '14981135830',
  196.00, 'pronto', true, true,
  0.00, 0.00, 6.00,
  '[]'::jsonb, '2026-02-06T20:58:41.084086+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('14981135830'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Elton')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '033', c.id, 'Carol', '19996690494',
  67.00, 'pronto', true, true,
  0.00, 0.00, 1.00,
  '[]'::jsonb, '2026-02-06T20:16:17.288071+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996690494'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Carol')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '032', c.id, 'Renata  Andrade', '19996864539',
  192.00, 'pronto', true, true,
  0.00, 6.00, 0.00,
  '[]'::jsonb, '2026-02-06T17:58:30.241836+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996864539'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata  Andrade')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '031', c.id, 'Rubens Nascimento', '19971498064',
  198.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-06T13:28:04.363605+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971498064'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Rubens Nascimento')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '030', c.id, 'Chácara Amarela (Lilian)', '19997337334',
  133.00, 'pronto', true, true,
  0.00, 8.00, 15.00,
  '[]'::jsonb, '2026-02-05T18:27:38.245233+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997337334'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Chácara Amarela (Lilian)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '029', c.id, 'Cleo', '19981004998',
  40.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-04T18:44:46.276064+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19981004998'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Cleo')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '028', c.id, 'Gabriel Salles', '11959582154',
  120.00, 'pronto', true, true,
  0.00, 10.00, 0.00,
  '[]'::jsonb, '2026-02-04T18:36:03.146282+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('11959582154'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Gabriel Salles')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '027', c.id, 'Ariane Nardi', '19997295303',
  42.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-04T18:25:11.60797+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997295303'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Ariane Nardi')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '026', c.id, 'Mary', '16997681999',
  114.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-04T18:13:56.930711+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16997681999'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Mary')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '025', c.id, 'Angélica', '19996368378',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-02-04T18:05:37.47178+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996368378'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Angélica')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '024', c.id, 'Renata.', '19996023645',
  105.00, 'pronto', true, true,
  0.00, 0.00, 5.00,
  '[]'::jsonb, '2026-02-04T18:04:57.849192+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996023645'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Renata.')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '023', c.id, 'Silvana', '19996212341',
  226.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-02T21:00:19.602206+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '021', c.id, 'Flávia', '19991928317',
  190.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-02T20:48:48.899952+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19991928317'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Flávia')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '020', c.id, 'Fabio', '14997141155',
  23.00, 'pronto', true, true,
  0.00, 3.00, 0.00,
  '[]'::jsonb, '2026-02-02T20:45:28.187014+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('14997141155'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Fabio')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '019', c.id, 'Ariane', '19998813672',
  75.00, 'pronto', true, true,
  0.00, 5.00, 0.00,
  '[]'::jsonb, '2026-02-02T20:34:14.888375+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998813672'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Ariane')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '018', c.id, 'Taty(Analândia)', '19993024640',
  224.00, 'pronto', true, true,
  0.00, 11.00, 15.00,
  '[]'::jsonb, '2026-02-02T12:54:06.861023+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19993024640'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Taty(Analândia)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '017', c.id, 'Márcia ( Analândia)', '19999972327',
  99.00, 'pronto', true, true,
  0.00, 0.00, 15.00,
  '[]'::jsonb, '2026-02-02T12:50:11.043911+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999972327'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Márcia ( Analândia)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '015', c.id, 'Carlos( mot.Padovani)', '19997292924',
  38.00, 'pronto', true, true,
  0.00, 4.00, 0.00,
  '[]'::jsonb, '2026-02-02T12:37:52.885943+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997292924'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Carlos( mot.Padovani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '014', c.id, 'Ivete Andrioli', '19998659624',
  30.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-02-02T12:33:33.699516+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19998659624'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Ivete Andrioli')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '013', c.id, 'Daniela( Dani)', '19971553618',
  312.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-30T19:51:39.179582+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '012', c.id, 'Lurdinha', '19997992142',
  48.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-30T14:58:24.791835+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997992142'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Lurdinha')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '007', c.id, 'Desirée', '19999756868',
  48.00, 'pronto', true, true,
  0.00, 2.00, 0.00,
  '[]'::jsonb, '2026-01-23T12:02:40.763764+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19999756868'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Desirée')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '006', c.id, 'Andréia.', '16997844747',
  478.00, 'pronto', true, true,
  0.00, 6.00, 0.00,
  '[]'::jsonb, '2026-01-23T11:31:37.545559+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16997844747'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Andréia.')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '005', c.id, 'Daniela( Dani)', '19971553618',
  286.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-22T18:49:03.463705+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19971553618'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Daniela( Dani)')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '004', c.id, 'Eduardo', '16991849944',
  108.02, 'pronto', true, true,
  1.80, 0.00, 0.00,
  '[]'::jsonb, '2026-01-22T14:13:37.651741+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('16991849944'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Eduardo')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '003', c.id, 'Silvana', '19996212341',
  154.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-21T19:16:39.218598+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19996212341'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Silvana')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '002', c.id, 'Rafael Lira', '19997415137',
  50.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-21T17:48:07.511927+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19997415137'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Rafael Lira')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  '001', c.id, 'Jose Roberto', '19993494444',
  42.00, 'pronto', true, true,
  0.00, 0.00, 0.00,
  '[]'::jsonb, '2026-01-21T13:05:43.794482+00:00'::timestamptz
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim('19993494444'), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim('Jose Roberto')) THEN 0 ELSE 1 END,
  c.created_at ASC
LIMIT 1
ON CONFLICT (numero) DO UPDATE SET
  cliente_id = EXCLUDED.cliente_id,
  cliente_nome = EXCLUDED.cliente_nome,
  cliente_telefone = EXCLUDED.cliente_telefone,
  valor_total = EXCLUDED.valor_total,
  status = EXCLUDED.status,
  pago = EXCLUDED.pago,
  retirado = EXCLUDED.retirado,
  desconto_percentual = EXCLUDED.desconto_percentual,
  desconto_valor = EXCLUDED.desconto_valor,
  taxa_entrega = EXCLUDED.taxa_entrega,
  itens = EXCLUDED.itens,
  created_at = EXCLUDED.created_at,
  updated_at = now();

SET LOCAL session_replication_role = origin;

COMMIT;

SELECT setval(
  'public.pedidos_numero_seq',
  COALESCE((SELECT MAX(numero::bigint) FROM public.pedidos WHERE numero ~ '^[0-9]+$'), 0)
);

SELECT count(*)::bigint AS pedidos_total FROM public.pedidos;

-- Proximos INSERTs pela app usam as sequences; alinhar ao maior numero ja importado
SELECT setval(
  'public.clientes_numero_seq',
  COALESCE((SELECT MAX(numero::bigint) FROM public.clientes WHERE numero ~ '^[0-9]+$'), 0)
);
SELECT setval(
  'public.pedidos_numero_seq',
  COALESCE((SELECT MAX(numero::bigint) FROM public.pedidos WHERE numero ~ '^[0-9]+$'), 0)
);

-- Conferencia final
SELECT 'clientes'::text AS tabela, count(*)::bigint AS total FROM public.clientes
UNION ALL
SELECT 'servicos'::text, count(*)::bigint FROM public.servicos
UNION ALL
SELECT 'pedidos'::text, count(*)::bigint FROM public.pedidos;
