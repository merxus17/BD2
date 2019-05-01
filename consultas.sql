CREATE OR REPLACE FUNCTION criar_produto (Num INTEGER, Des CHAR(250), Qtd INTEGER)
RETURNS VOID
AS $$
BEGIN
INSERT INTO Mercadoria (NumeroMercadoria, Descricao, QuantidadeEstoque)
VALUES (Num, Des, Qtd);
END; $$

LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION get_best_clientes (N INTEGER)
RETURNS TABLE (
    Codigo INTEGER,
    Nome CHAR(150),
    Numero INTEGER
)
AS $$
BEGIN
RETURN QUERY
SELECT * FROM (
    SELECT CLIENTE_FORNECEDOR.CODIGO,sum(ItensNota.quantidade * ValorUnitario) AS vendas 
    FROM NotasVenda 
    JOIN ItensNota ON NotasVenda.Numero = ItensNota.Numero
    JOIN CLIENTE_FORNECEDOR ON NotasVenda.CodigoCliente = CLIENTE_FORNECEDOR.CODIGO 
    GROUP BY CLIENTE_FORNECEDOR.CODIGO ORDER BY vendas DESC
) AS derivedTable
WHERE rownum <= N;
END; $$ 
 
LANGUAGE 'plpgsql';




CREATE OR REPLACE FUNCTION get_cliente_fornecedor (ID INTEGER)
RETURNS TABLE (
  CODIGO INTEGER,
  NOME CHAR(90) ,
  TELEFONE CHAR(11) ,
  LOGRADOURO CHAR(50) ,
  NUMERO INTEGER ,
  COMPLEMENTO CHAR(10) ,
  CIDADE CHAR(15) ,
  ESTADO CHAR(45) ,
  NUMEROCONTRIBUINTE INTEGER,
  CNPJ CHAR(18)
)
AS $$
BEGIN
SELECT * FROM CLIENTE_FORNECEDOR WHERE CODIGO=ID;
END; $$

LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION get_estoque_preco (NUMERO INTEGER)
RETURNS TABLE (
    NumeroMercadoria INTEGER,
    QuantidadeEstoque INTEGER,
    ValorUnitario INTEGER
)
AS $$
BEGIN
SELECT * FROM Mercadorias JOIN ItensNota ON NumeroMercadoria
WHERE NumeroMercadoria=NUMERO;
END; $$

LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION get_info_pedido (N INTEGER)
RETURNS TABLE (
  NUMERO INTEGER,
  DATAEMISSAO DATE ,
  CODIGOFORNECEDOR INTEGER
)
AS $$
BEGIN
SELECT * FROM Notas_E_Compras WHERE NUMERO=N;
END; $$

LANGUAGE 'plpgsql';


--  RETURNS TABLE (
--  film_title VARCHAR,
--  film_release_year INT
-- ) 
-- AS $$
-- BEGIN
--  RETURN QUERY SELECT
--  title,
--  cast( release_year as integer)
--  FROM
--  film
--  WHERE
--  title ILIKE p_pattern ;
-- END; $$ 
 
-- LANGUAGE 'plpgsql';