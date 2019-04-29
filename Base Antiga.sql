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
    PRIMARY KEY (Codigo)
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
