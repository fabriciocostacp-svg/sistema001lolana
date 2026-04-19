"""
Gera import-pedidos-backup.sql a partir de backup_pedidos_*.csv
(export gerado pelo botao Backup da app: colunas numero, cliente_nome, ...).

Uso (na pasta scripts ou na raiz do workspace onde esta o CSV):
  python import-pedidos-from-backup-csv.py
  python import-pedidos-from-backup-csv.py caminho\\backup_pedidos_2026-04-20.csv

Requisitos no Supabase antes de rodar o SQL:
  - Clientes ja importados (mesmo telefone/nome que no CSV).
  - Usa session_replication_role=replica na transacao para nao disparar triggers
    (mantem numeros do backup sem referenciar o nome do trigger).
"""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path


def esc(s: str) -> str:
    return s.replace("'", "''")


def sql_str(s: str) -> str:
    return "'" + esc(s.strip()) + "'"


def sql_ts(s: str) -> str:
    s = (s or "").strip()
    if not s:
        return "now()"
    return "'" + esc(s) + "'::timestamptz"


def sql_jsonb(raw: str) -> str:
    raw = (raw or "").strip()
    if not raw or "object Object" in raw:
        # CSV gerado com String(itens) em vez de JSON — itens originais perdidos
        return "'[]'::jsonb"
    try:
        parsed = json.loads(raw)
        dumped = json.dumps(parsed, ensure_ascii=False)
    except json.JSONDecodeError:
        dumped = "[]"
    return "'" + esc(dumped) + "'::jsonb"


def find_csv(arg: str | None) -> Path:
    if arg:
        p = Path(arg)
        if p.is_file():
            return p
        sys.exit(f"Ficheiro nao encontrado: {arg}")
    here = Path(__file__).resolve().parent
    roots = [here.parent.parent.parent, here.parent.parent, Path.cwd()]
    for root in roots:
        matches = sorted(root.glob("backup_pedidos_*.csv"), key=lambda x: x.stat().st_mtime, reverse=True)
        if matches:
            return matches[0]
    sys.exit(
        "Nenhum backup_pedidos_*.csv encontrado. Coloque o CSV na raiz do projeto "
        "ou passe o caminho: python import-pedidos-from-backup-csv.py caminho.csv"
    )


def main() -> None:
    csv_path = find_csv(sys.argv[1] if len(sys.argv) > 1 else None)
    out_path = Path(__file__).resolve().parent / "import-pedidos-backup.sql"

    rows: list[dict[str, str]] = []
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            rows.append({k: (row.get(k) or "").strip() for k in row})

    allowed_status = {"lavando", "passando", "secando", "pronto"}
    inserts: list[str] = []

    for r in rows:
        num = r.get("numero", "").strip()
        nome = r.get("cliente_nome", "").strip()
        tel = r.get("cliente_telefone", "").strip()
        if not num or not nome or not tel:
            continue
        st = r.get("status", "lavando").strip().lower()
        if st not in allowed_status:
            st = "lavando"
        try:
            vtotal = float((r.get("valor_total") or "0").replace(",", "."))
        except ValueError:
            vtotal = 0.0
        pago = (r.get("pago") or "").lower() in ("true", "1", "sim", "yes")
        retirado = (r.get("retirado") or "").lower() in ("true", "1", "sim", "yes")
        try:
            dpct = float((r.get("desconto_percentual") or "0").replace(",", "."))
        except ValueError:
            dpct = 0.0
        try:
            dval = float((r.get("desconto_valor") or "0").replace(",", "."))
        except ValueError:
            dval = 0.0
        try:
            taxa = float((r.get("taxa_entrega") or "0").replace(",", "."))
        except ValueError:
            taxa = 0.0
        itens_sql = sql_jsonb(r.get("itens", ""))
        ca = sql_ts(r.get("created_at", ""))

        inserts.append(
            """INSERT INTO public.pedidos (
  numero, cliente_id, cliente_nome, cliente_telefone,
  valor_total, status, pago, retirado,
  desconto_percentual, desconto_valor, taxa_entrega,
  itens, created_at
)
SELECT
  {num}, c.id, {nome}, {tel},
  {vtotal}, {status}, {pago}, {retirado},
  {dpct}, {dval}, {taxa},
  {itens}, {ca}
FROM public.clientes c
WHERE regexp_replace(trim(c.telefone), '[^0-9]', '', 'g') = regexp_replace(trim({telq}), '[^0-9]', '', 'g')
ORDER BY
  CASE WHEN lower(trim(c.nome)) = lower(trim({nomeq})) THEN 0 ELSE 1 END,
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
  updated_at = now();""".format(
                num=sql_str(num),
                nome=sql_str(nome),
                tel=sql_str(tel),
                telq=sql_str(tel),
                nomeq=sql_str(nome),
                vtotal=f"{vtotal:.2f}",
                status=sql_str(st),
                pago="true" if pago else "false",
                retirado="true" if retirado else "false",
                dpct=f"{dpct:.2f}",
                dval=f"{dval:.2f}",
                taxa=f"{taxa:.2f}",
                itens=itens_sql,
                ca=ca,
            )
        )

    header = f"""-- IMPORT pedidos gerado a partir de: {csv_path.name}
-- Total de linhas no CSV: {len(rows)} | INSERTs gerados: {len(inserts)}
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

"""

    footer = """
SET LOCAL session_replication_role = origin;

COMMIT;

SELECT setval(
  'public.pedidos_numero_seq',
  COALESCE((SELECT MAX(numero::bigint) FROM public.pedidos WHERE numero ~ '^[0-9]+$'), 0)
);

SELECT count(*)::bigint AS pedidos_total FROM public.pedidos;
"""

    out_path.write_text(header + "\n\n".join(inserts) + "\n" + footer, encoding="utf-8")
    print(csv_path, "->", out_path, "inserts:", len(inserts))


if __name__ == "__main__":
    main()
