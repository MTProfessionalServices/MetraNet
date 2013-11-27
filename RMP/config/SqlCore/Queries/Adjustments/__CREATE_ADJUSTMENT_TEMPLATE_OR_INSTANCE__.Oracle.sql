
    insert 
    into t_adjustment
    (
    id_prop,
	  tx_guid,
	  %%PI_COLUMN%%,
  	id_adjustment_type
  	)
     values (
      %%ID_PROP%%,
      rawtohex(hextoraw(replace('%%GUID%%','0x',''))),
      %%PI_ID%%,
      %%ID_ADJUSTMENT_TYPE%%
      )
  