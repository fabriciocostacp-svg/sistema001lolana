-- Cole isto PRIMEIRO no SQL Editor e clique Run.
-- Se aparecer uma tabela com 3 linhas (clientes, pedidos, servicos), a ligacao esta OK.

SELECT 'clientes'::text AS tabela, count(*)::bigint AS total FROM public.clientes
UNION ALL
SELECT 'pedidos', count(*) FROM public.pedidos
UNION ALL
SELECT 'servicos', count(*) FROM public.servicos;
