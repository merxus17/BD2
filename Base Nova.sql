DROP SCHEMA IF EXISTS exemplo CASCADE;
CREATE SCHEMA exemplo;
SET SCHEMA 'exemplo';
CREATE TABLE CLIENTE/FORNECEDOR
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
  CNPJ CHAR(18) 
  PRIMARY KEY (CODIGO)  
);
CREATE TABLE Notas_E_Compras
(
  NUMERO INTEGER NOT NULL,
  DATAEMISSAO DATE ,
  CODIGOFORNECEDOR INTEGER,
  Primary Key (NUMERO),
  FOREIGN KEY (CODIGOFORNECEDOR)
  REFERENCES CLIENTE/FORNECEDOR(CODIGO)
);
CREATE TABLE Itens_Nota_Compra
(
  NUMERO INTEGER NOT NULL,
  NUMEROMERCADORIA INTEGER ,
  QUANTIDADE INTEGER ,
  VALORUNITARIO FLOAT ,
  PRIMARY KEY  (NUMERO,NUMEROMERCADORIA),
  FOREIGN KEY (NUMERO)
  REFERENCES Notas_E_Compras(NUMERO)
);


