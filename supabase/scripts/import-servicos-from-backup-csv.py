"""
Gera import-servicos-backup.sql a partir de backup_servicos_*.csv
(formato do botao Backup: nome, categoria, preco, ativo, created_at).

Requer UNIQUE(nome) em public.servicos (migration 20260412000000_unique_servicos_nome.sql).

Uso:
  python import-servicos-from-backup-csv.py
  python import-servicos-from-backup-csv.py C:\\caminho\\backup_servicos_2026-04-02.csv
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path


def esc(s: str) -> str:
    return str(s).replace("'", "''")


def sql_str(s: str) -> str:
    return "'" + esc(s.strip()) + "'"


def sql_ts(s: str) -> str:
    s = (s or "").strip()
    if not s:
        return "now()"
    return "'" + esc(s) + "'::timestamptz"


def parse_bool(raw: str) -> str:
    s = (raw or "").strip().lower()
    if s in ("true", "1", "sim", "yes"):
        return "true"
    return "false"


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
            root.glob("backup_servicos_*.csv"),
            key=lambda x: x.stat().st_mtime,
            reverse=True,
        )
        if matches:
            return matches[0]
    sys.exit(
        "Nenhum backup_servicos_*.csv encontrado. Copie o CSV para a pasta do projeto ou passe o caminho."
    )


def main() -> None:
    csv_path = find_csv(sys.argv[1] if len(sys.argv) > 1 else None)
    out_path = Path(__file__).resolve().parent / "import-servicos-backup.sql"

    rows = []
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            nome = (row.get("nome") or "").strip()
            cat = (row.get("categoria") or "").strip()
            if not nome or not cat:
                continue
            try:
                preco = float((row.get("preco") or "0").replace(",", "."))
            except ValueError:
                preco = 0.0
            ativo = parse_bool(row.get("ativo", "true"))
            ca = sql_ts(row.get("created_at", ""))
            rows.append((nome, cat, preco, ativo, ca))

    if not rows:
        sys.exit("CSV sem linhas validas (nome/categoria obrigatorios).")

    vals = []
    for nome, cat, preco, ativo, ca in rows:
        vals.append(
            "  ({}, {}, {}, {}, {})".format(
                sql_str(nome),
                sql_str(cat),
                f"{preco:.2f}",
                ativo,
                ca,
            )
        )

    header = f"""-- IMPORT servicos gerado a partir de: {csv_path.name}
-- Linhas: {len(rows)}
-- Supabase SQL Editor: execute o ficheiro INTEIRO.
-- Requer CONSTRAINT UNIQUE(nome) em servicos.

INSERT INTO public.servicos (nome, categoria, preco, ativo, created_at)
VALUES
"""

    footer = """
ON CONFLICT (nome) DO UPDATE SET
  categoria = EXCLUDED.categoria,
  preco = EXCLUDED.preco,
  ativo = EXCLUDED.ativo,
  created_at = EXCLUDED.created_at,
  updated_at = now();

SELECT count(*)::bigint AS servicos_total FROM public.servicos;
"""

    out_path.write_text(header + ",\n".join(vals) + "\n" + footer, encoding="utf-8")
    print(csv_path, "->", out_path, "rows:", len(rows))


if __name__ == "__main__":
    main()
