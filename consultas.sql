CREATE FUNCTION get_best_clientes (N in NUMBER)
RETURNS 

SELECT * 
FROM (SELECT Cliente_Fornecedor.Codigo,sum(ItensNota.QUANTIDADE * VALORUNITARIO) AS vendas 
FROM NotasVenda JOIN ItensNota ON NotasVenda.numero = ItensNota.numero
JOIN Cliente_Fornecedor on NotasVenda.CodigoCliente = Cliente_Fornecedor.Codigo 
GROUP BY Cliente_Fornecedor.Codigo ORDER BY vendas DESC)
WHERE rownum <= N
