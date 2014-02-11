
      update t_pricelist set 
        n_type = %%TYPE%%,
        nm_currency_code = N'%%CURRENCY_CODE%%',
		c_PLPartitionId = %%PLPARTITIONID%%
        where id_pricelist = %%ID_PL%%
    