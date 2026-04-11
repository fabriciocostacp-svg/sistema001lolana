-- Sincroniza catálogo de serviços para o padrão utilizado no sistema Apogeu
-- Script idempotente: pode ser executado mais de uma vez sem duplicar o terno.

-- Padronizar nomes de edredom
UPDATE public.servicos
SET nome = 'Edredom de solteiro', categoria = 'Peças de Cama', preco = 30.00
WHERE nome IN ('Edredom solteiro', 'Edredom de solteiro');

UPDATE public.servicos
SET nome = 'Edredom de casal', categoria = 'Peças de Cama', preco = 42.00
WHERE nome IN ('Edredom casal', 'Edredom de casal');

-- Sincronizar preços e categorias oficiais
UPDATE public.servicos SET categoria = 'Serviços por KG', preco = 26.00 WHERE nome = 'Por Kg';
UPDATE public.servicos SET categoria = 'Serviços por KG', preco = 22.00 WHERE nome = 'Kg lavada e passada';
UPDATE public.servicos SET categoria = 'Serviços por KG', preco = 22.00 WHERE nome = 'Kg lavar ou passar';
UPDATE public.servicos SET categoria = 'Peças de Cama', preco = 50.00 WHERE nome = 'Coberdrom';
UPDATE public.servicos SET categoria = 'Camisas', preco = 17.00 WHERE nome = 'Camisa manga longa (lavar e passar)';
UPDATE public.servicos SET categoria = 'Camisas', preco = 15.00 WHERE nome = 'Camisa manga longa (passar)';
UPDATE public.servicos SET categoria = 'Camisas', preco = 15.00 WHERE nome = 'Camisa manga curta (lavar e passar)';
UPDATE public.servicos SET categoria = 'Camisas', preco = 12.00 WHERE nome = 'Camisa manga curta (passar)';
UPDATE public.servicos SET categoria = 'Vestido', preco = 40.00 WHERE nome = 'Vestido de festa (a partir de)';
UPDATE public.servicos SET categoria = 'Valor Unitário', preco = 10.00 WHERE nome = 'Calça';
UPDATE public.servicos SET categoria = 'Valor Unitário', preco = 8.00 WHERE nome = 'Camiseta';
UPDATE public.servicos SET categoria = 'Valor Unitário', preco = 6.00 WHERE nome = 'Short';
UPDATE public.servicos SET categoria = 'Valor Unitário', preco = 30.00 WHERE nome = 'Paletó';

-- Garantir terno completo
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.servicos WHERE nome = 'Terno completo') THEN
    UPDATE public.servicos
    SET categoria = 'Valor Unitário', preco = 70.00
    WHERE nome = 'Terno completo';
  ELSE
    INSERT INTO public.servicos (nome, categoria, preco)
    VALUES ('Terno completo', 'Valor Unitário', 70.00);
  END IF;
END $$;
