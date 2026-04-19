"""
Gera import-clientes-backup.sql a partir de backup_clientes_*.csv
(mesmo formato do botao Backup: numero, nome, telefone, endereco, cpf, cnpj, created_at).

Uso:
  python import-clientes-from-backup-csv.py
  python import-clientes-from-backup-csv.py C:\\caminho\\backup_clientes_2026-04-02.csv

Coloque o CSV na raiz do workspace (pasta pai de sistema001lolana-main) ou passe o caminho completo.
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path


def esc(s: str) -> str:
    return str(s).replace("'", "''")


def sql_str(s: str) -> str:
    return "'" + esc(s.strip()) + "'"


def sql_opt(s: str) -> str:
    s = (s or "").strip()
    if not s:
        return "NULL"
    return "'" + esc(s) + "'"


def sql_ts(s: str) -> str:
    s = (s or "").strip()
    if not s:
        return "now()"
    return "'" + esc(s) + "'::timestamptz"


def find_csv(arg: str | None) -> Path:
    if arg:
        p = Path(arg)
        if p.is_file():
            return p
        sys.exit(f"Ficheiro nao encontrado: {arg}")
    here = Path(__file__).resolve().parent
    roots = [here.parent.parent.parent, here.parent.parent, Path.cwd()]
    for root in roots:
        matches = sorted(
            root.glob("backup_clientes_*.csv"),
            key=lambda x: x.stat().st_mtime,
            reverse=True,
        )
        if matches:
            return matches[0]
    sys.exit(
        "Nenhum backup_clientes_*.csv encontrado. Copie o CSV para a pasta do projeto "
        "ou: python import-clientes-from-backup-csv.py caminho\\backup_clientes_2026-04-02.csv"
    )


def main() -> None:
    csv_path = find_csv(sys.argv[1] if len(sys.argv) > 1 else None)
    out_path = Path(__file__).resolve().parent / "import-clientes-backup.sql"

    rows = []
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            rows.append(
                (
                    (row.get("numero") or "").strip(),
                    (row.get("nome") or "").strip(),
                    (row.get("telefone") or "").strip(),
                    (row.get("endereco") or "").strip(),
                    (row.get("cpf") or "").strip(),
                    (row.get("cnpj") or "").strip(),
                    (row.get("created_at") or "").strip(),
                )
            )

    vals = []
    for num, nome, tel, end_, cpf, cnpj, ca in rows:
        if not num or not nome or not tel:
            continue
        vals.append(
            "  ({}, {}, {}, {}, {}, {}, {})".format(
                sql_str(num),
                sql_str(nome),
                sql_str(tel),
                sql_str(end_),
                sql_opt(cpf),
                sql_opt(cnpj),
                sql_ts(ca),
            )
        )

    header = f"""-- IMPORT clientes gerado a partir de: {csv_path.name}
-- Linhas no CSV: {len(rows)} | VALUES gerados: {len(vals)}
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- session_replication_role=replica na transacao: triggers normais nao disparam (mantem numeros do backup).
-- ON CONFLICT (numero) atualiza nome, telefone, endereco, cpf, cnpj, created_at.

BEGIN;

SET LOCAL session_replication_role = replica;

INSERT INTO public.clientes (numero, nome, telefone, endereco, cpf, cnpj, created_at)
VALUES
"""

    footer = """
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
"""

    out_path.write_text(header + ",\n".join(vals) + "\n" + footer, encoding="utf-8")
    print(csv_path, "->", out_path, "rows:", len(vals))


if __name__ == "__main__":
    main()
