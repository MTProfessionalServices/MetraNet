
        CREATE TABLE t_ps_pcard (
        id_acc                 int NOT NULL,
        id_creditcardtype      int NOT NULL,
        nm_lastfourdigits      nvarchar(4) NOT NULL,
        nm_customerreferenceid varchar(17) NULL,
        nm_customervatnumber   nvarchar(17) NULL,
        nm_companyaddress      nvarchar(40) NULL,
        nm_companypostalcode   nvarchar(10) NULL,
        nm_companyphone        nvarchar(40) NULL,
        nm_reserved1           nvarchar(40) NULL,
        nm_reserved2           nvarchar(40) NULL,
        CONSTRAINT PK_t_ps_pcard PRIMARY KEY CLUSTERED (id_acc,
        nm_lastfourdigits,
        id_creditcardtype))
      