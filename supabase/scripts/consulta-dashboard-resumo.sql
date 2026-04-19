-- Numeros parecidos com o Dashboard e lista de pedidos (so leitura).
-- Cole no Supabase SQL Editor e clique Run (pode aparecer 2 resultados).

-- Resumo (uma tabela)
SELECT * FROM (
  SELECT 1 AS ord, 'Total clientes'::text AS indicador, (SELECT count(*)::text FROM public.clientes) AS valor
  UNION ALL SELECT 2, 'Total pedidos', (SELECT count(*)::text FROM public.pedidos)
  UNION ALL SELECT 3, 'Pedidos lavando', (SELECT count(*)::text FROM public.pedidos WHERE status = 'lavando')
  UNION ALL SELECT 4, 'Pedidos passando', (SELECT count(*)::text FROM public.pedidos WHERE status = 'passando')
  UNION ALL SELECT 5, 'Pedidos secando', (SELECT count(*)::text FROM public.pedidos WHERE status = 'secando')
  UNION ALL SELECT 6, 'Pedidos prontos', (SELECT count(*)::text FROM public.pedidos WHERE status = 'pronto')
  UNION ALL SELECT 7, 'Faturamento recebido (R$)', (
    SELECT coalesce(round(sum(valor_total), 2), 0)::text FROM public.pedidos WHERE pago = true
  )
  UNION ALL SELECT 8, 'A receber - nao pagos (R$)', (
    SELECT coalesce(round(sum(valor_total), 2), 0)::text FROM public.pedidos WHERE pago = false
  )
) t
ORDER BY ord;

-- Lista de pedidos — segunda aba de resultados no editor (sem ORDER BY created_at: coluna pode não existir em bases antigas)
SELECT numero, cliente_nome, cliente_telefone, valor_total, status, pago, retirado, id
FROM public.pedidos
ORDER BY id DESC
LIMIT 200;
