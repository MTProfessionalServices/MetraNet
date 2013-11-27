
    insert into t_applicability_rule
    (
    id_prop,
    tx_guid,
	  id_formula
  	)
     values (
      %%ID_PROP%%,
      rawtohex(hextoraw(replace('%%GUID%%','0x',''))),
      %%ID_FORMULA%%
      )
  