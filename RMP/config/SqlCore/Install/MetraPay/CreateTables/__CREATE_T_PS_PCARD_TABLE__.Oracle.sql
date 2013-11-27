
        CREATE TABLE t_ps_pcard (
        id_acc                 number(10) NOT NULL,
        id_creditcardtype      number(10) NOT NULL,
        nm_lastfourdigits      nvarchar2(4) NOT NULL,
        nm_customerreferenceid varchar2(17) NULL,
        nm_customervatnumber   nvarchar2(17) NULL,
        nm_companyaddress      nvarchar2(40) NULL,
        nm_companypostalcode   nvarchar2(10) NULL,
        nm_companyphone        nvarchar2(40) NULL,
        nm_reserved1           nvarchar2(40) NULL,
        nm_reserved2           nvarchar2(40) NULL,
        PRIMARY KEY (id_acc, nm_lastfourdigits, id_creditcardtype))
      