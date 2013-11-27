
        insert into t_ps_pcard
          (id_acc,
           id_creditcardtype,
           nm_lastfourdigits,
           nm_customerreferenceid,
           nm_customervatnumber,
           nm_companyaddress,
           nm_companypostalcode,
           nm_companyphone,
           nm_reserved1,
           nm_reserved2)
        values
          (%%ACCOUNT_ID%%,
           %%CREDIT_CARD_TYPE%%,
           N'%%LAST_FOUR_DIGITS%%',
           N'%%CUSTOMERREFERENCEID%%',
           N'%%CUSTOMERVATNUMBER%%',
           N'%%COMPANYADDRESS%%',
           N'%%COMPANYPOSTALCODE%%',
           N'%%COMPANYPHONE%%',
           N'%%RESERVED1%%',
           N'%%RESERVED2%%')
	  