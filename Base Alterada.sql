DROP SCHEMA IF EXISTS exemplo CASCADE;
CREATE SCHEMA exemplo;
SET SCHEMA 'exemplo';

CREATE TABLE Cliente
(
    Codigo INTEGER,
    Nome CHAR(150),
    Telefone INTEGER,
    Logradouro CHAR(150),
    Numero INTEGER,
    Complemento CHAR(25),
    Cidade CHAR(80),
    Estado CHAR(60),
    NumeroContribuinte INTEGER,
    PRIMARY KEY(Codigo)
);
CREATE TABLE NotasVenda 
(
    Numero INTEGER,
    DataEmissão DATE,
    FormaPagamento CHAR(150),
    CodigoCliente INTEGER,
    CPFVendedor INTEGER,
    PRIMARY KEY (Numero),
    FOREIGN KEY (CodigoCliente) REFERENCES Cliente(Codigo) 
);
CREATE TABLE Mercadorias
(
    NumeroMercadoria INTEGER,
    Descricao CHAR(250),
    QuantidadeEstoque INTEGER,
    PRIMARY KEY (NumeroMercadoria)
);
CREATE TABLE ItensNota
(
    Numero INTEGER,
    NumeroMercadoria INTEGER,
    Quantidade INTEGER,
    ValorUnitario INTEGER,
    PRIMARY KEY (Numero,NumeroMercadoria),
    FOREIGN KEY (NumeroMercadoria) REFERENCES Mercadorias(NumeroMercadoria)
);
CREATE TABLE Funcionario
(
    CPF INTEGER,
    Nome CHAR(150),
    Telefone INTEGER,
    Logradouro CHAR(150),
    Numero INTEGER,
    Complemento CHAR(25),
    Cidade CHAR(80),
    Estado CHAR(60),
    CodigoDepartamento INTEGER,
    PRIMARY KEY (CPF)
);
CREATE TABLE Cargo
(
    Codigo INTEGER,
    Descricao CHAR(250),
    Salario_Base INTEGER,
    PRIMARY KEY (Codigo)
);
CREATE TABLE Departamento
(
    CodigoDepartamento INTEGER,
    Nome CHAR(150),
    CPF_CHEFE INTEGER,
    PRIMARY KEY (CodigoDepartamento)
);
CREATE TABLE CargosFunc
(
    CPF INTEGER,
    CodigoCargo INTEGER,
    DataInicio DATE,
    DataFim DATE,
    PRIMARY KEY (CPF,CodigoCargo,DataInicio),
    FOREIGN KEY (CPF) REFERENCES Funcionario(CPF),
    FOREIGN KEY (CodigoCargo) REFERENCES Cargo(Codigo)
);
CREATE TABLE CLIENTE_FORNECEDOR
(
  CODIGO INTEGER,
  NOME CHAR(90) ,
  TELEFONE CHAR(11) ,
  LOGRADOURO CHAR(50) ,
  NUMERO INTEGER ,
  COMPLEMENTO CHAR(10) ,
  CIDADE CHAR(15) ,
  ESTADO CHAR(45) ,
  NUMEROCONTRIBUINTE INTEGER,
  CNPJ CHAR(18), 
  PRIMARY KEY (CODIGO)  
);
CREATE TABLE Notas_E_Compras
(
  NUMERO INTEGER NOT NULL,
  DATAEMISSAO DATE ,
  CODIGOFORNECEDOR INTEGER,
  Primary Key (NUMERO),
  FOREIGN KEY (CODIGOFORNECEDOR) REFERENCES CLIENTE_FORNECEDOR(CODIGO)
);
CREATE TABLE Itens_Nota_Compra
(
  NUMERO INTEGER NOT NULL,
  NUMEROMERCADORIA INTEGER ,
  QUANTIDADE INTEGER ,
  VALORUNITARIO FLOAT ,
  PRIMARY KEY  (NUMERO,NUMEROMERCADORIA),
  FOREIGN KEY (NUMEROMERCADORIA) REFERENCES MERCADORIAS(NUMEROMERCADORIA),
  FOREIGN KEY (NUMERO) REFERENCES Notas_E_Compras(NUMERO)
);
CREATE FUNCTION estoque_min()
Returns trigger AS
$BODY$
Declare 
estoque_atual INTEGER;
BEGIN 
SELECT (QuantidadeEstoque) INTO  estoque_atual 
FROM Mercadoria;
IF estoque_atual > 5 THEN 
RAISE EXCEPTION 'Abaixo do estoque minimo';
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER pede_estoque
BEFORE INSERT OR UPDATE
ON Mercadorias
FOR EACH ROW
EXECUTE PROCEDURE estoque_min();
CREATE TABLE PRECO_MIN
(
  CODIGOMERCADORIA INTEGER,
  ULTIMOPREÇO INTEGER,
  PRIMARY KEY (CODIGOMERCADORIA ),
  FOREIGN KEY (CODIGOMERCADORIA ) REFERENCES Mercadorias(NumeroMercadoria)
);
ALTER TABLE FUNCIONARIO
	Add CONSTRAINT fk_departamento FOREIGN KEY (CodigoDepartamento) REFERENCES departamento(codigoDepartamento);
ALTER TABLE NotasVenda
	ADD Column CPF_Funcionario INTEGER,
	ADD CONSTRAINT fk_cpf  FOREIGN KEY (CPF_Funcionario) REFERENCES Funcionario(CPF);
ALTER TABLE FUNCIONARIO
	Rename TO FUNCIONARIO_NEW;
ALTER TABLE Mercadorias
	ADD COLUMN Estoque_Max INTEGER;
ALTER TABLE Mercadorias
	RENAME TO MERCADORIAS_NEW;
CREATE VIEW FUNCIONARIO AS 
SELECT CPF,Nome,Telefone,Logradouro,Numero,Complemento,Cidade,Estado,CodigoDepartamento
FROM FUNCIONARIO_NEW;
CREATE VIEW MERCADORIAS AS 
SELECT NumeroMercadoria, Descricao, QuantidadeEstoque
FROM MERCADORIAS_NEW;
CREATE FUNCTION estoque_max()
Returns trigger AS
$BODY$
BEGIN 
IF NEW.QuantidadeEstoque > Old.Estoque_Max THEN 
RAISE EXCEPTION 'Acima do estoque maximo';
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER impede_over_estoque
BEFORE INSERT OR UPDATE
ON Mercadorias_NEW
FOR EACH ROW
EXECUTE PROCEDURE estoque_max();

CREATE FUNCTION estoque_zero()
Returns trigger AS
$BODY$
BEGIN 
IF OLD.QuantidadeEstoque < 1 THEN 
RAISE EXCEPTION 'SEM ESTOQUE';
END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER impede_venda_por_estoque_zero
BEFORE INSERT OR UPDATE
ON Mercadorias_NEW
FOR EACH ROW
EXECUTE PROCEDURE estoque_zero();

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