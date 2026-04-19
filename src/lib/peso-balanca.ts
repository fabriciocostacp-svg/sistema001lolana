const roundKg = (n: number) => Math.round(n * 1000) / 1000;

/**
 * Interpreta leitura de balança em pt-BR.
 *
 * **Só números (sem vírgula nem ponto):**
 * - Com `opts.gramas`: sempre trata como gramas → divide por 1000 (ex.: 3 → 0,003 kg).
 * - Sem `opts.gramas`: automático — **1 ou 2 caracteres** no texto = **kg inteiros**
 *   (ex.: 5 → 5 kg; 12 → 12 kg); **3 ou mais caracteres** só com dígitos = **gramas**
 *   (ex.: 3200 → 3,2 kg; 050 → 50 g; 100 → 100 g).
 *
 * **Com vírgula:** milhar com ponto, decimal com vírgula (ex.: 1.234,56).
 * **Só vírgula:** decimal (ex.: 3,25).
 * **Um ponto sem vírgula:** decimal internacional (ex.: 3.25).
 * **Vários pontos sem vírgula:** inválido (evita 3.200.5.100).
 */
export function parseLeituraBalanca(
  raw: string,
  options?: { gramas?: boolean },
): number | null {
  const t = raw.trim().replace(/\s/g, "");
  if (!t) return null;

  if (/^\d+$/.test(t)) {
    const nInt = parseInt(t, 10);
    if (!Number.isFinite(nInt) || nInt < 0) return null;
    if (nInt === 0) return 0;

    if (options?.gramas) {
      return roundKg(nInt / 1000);
    }

    /* Comprimento do que foi digitado: 050 = 3 chars → gramas; 12 = 2 chars → kg */
    if (t.length <= 2) {
      return nInt;
    }
    return roundKg(nInt / 1000);
  }

  let normalized = t;
  if (t.includes(",")) {
    normalized = t.replace(/\./g, "").replace(",", ".");
  } else {
    const dotCount = (t.match(/\./g) || []).length;
    if (dotCount > 1) return null;
  }

  const n = parseFloat(normalized);
  if (!Number.isFinite(n) || n < 0) return null;
  return roundKg(n);
}

export function formatKgBr(kg: number): string {
  if (!Number.isFinite(kg)) return "";
  return kg.toLocaleString("pt-BR", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 3,
  });
}

/** Exibe quantidade em pedido/cupom (inteiros normais; kg fracionado com vírgula). */
export function formatQuantidadePedido(quantidade: number): string {
  if (!Number.isFinite(quantidade)) return "";
  if (Number.isInteger(quantidade)) return String(quantidade);
  return quantidade.toLocaleString("pt-BR", { maximumFractionDigits: 3 });
}
