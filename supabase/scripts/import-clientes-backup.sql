-- IMPORT clientes gerado a partir de: backup_clientes_colado.csv
-- Linhas no CSV: 59 | VALUES gerados: 59
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- session_replication_role=replica: triggers normais nao disparam (mantem numeros do backup).
-- ON CONFLICT (numero) atualiza nome, telefone, endereco, cpf, cnpj, created_at.

ALTER TABLE public.clientes
  ADD COLUMN IF NOT EXISTS cpf text,
  ADD COLUMN IF NOT EXISTS cnpj text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

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

SELECT setval(
  'public.clientes_numero_seq',
  COALESCE((SELECT MAX(numero::bigint) FROM public.clientes WHERE numero ~ '^[0-9]+$'), 0)
);

SELECT count(*)::bigint AS clientes_total FROM public.clientes;
