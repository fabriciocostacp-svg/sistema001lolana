-- Execute UMA vez no SQL Editor se a app mostrar: column pedidos.created_at does not exist
ALTER TABLE public.pedidos
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
