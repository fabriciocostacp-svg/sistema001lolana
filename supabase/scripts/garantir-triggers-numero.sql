-- Recria triggers de auto-numero (001, 002 / pedidos) se faltarem.
-- Execute no SQL Editor depois das migrations ou se aparecer erro de trigger inexistente.
-- Idempotente: DROP IF EXISTS + CREATE.

CREATE SEQUENCE IF NOT EXISTS public.clientes_numero_seq START 1;
CREATE SEQUENCE IF NOT EXISTS public.pedidos_numero_seq START 1;

CREATE OR REPLACE FUNCTION public.generate_cliente_numero()
RETURNS TRIGGER AS $$
BEGIN
  NEW.numero := LPAD(nextval('public.clientes_numero_seq')::TEXT, 3, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.generate_pedido_numero()
RETURNS TRIGGER AS $$
BEGIN
  NEW.numero := LPAD(nextval('public.pedidos_numero_seq')::TEXT, 3, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_cliente_numero ON public.clientes;
CREATE TRIGGER set_cliente_numero
  BEFORE INSERT ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_cliente_numero();

DROP TRIGGER IF EXISTS set_pedido_numero ON public.pedidos;
CREATE TRIGGER set_pedido_numero
  BEFORE INSERT ON public.pedidos
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_pedido_numero();
