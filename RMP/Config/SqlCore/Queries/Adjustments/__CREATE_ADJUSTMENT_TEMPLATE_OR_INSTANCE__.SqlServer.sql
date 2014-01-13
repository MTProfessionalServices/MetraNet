
    insert 
    /* __CREATE_ADJUSTMENT_TEMPLATE_OR_INSTANCE__ */
    into t_adjustment
    (
    id_prop,
	  tx_guid,
	  %%PI_COLUMN%%,
  	id_adjustment_type
  	)
     values (
      %%ID_PROP%%,
      %%GUID%%,
      %%PI_ID%%,
      %%ID_ADJUSTMENT_TYPE%%
      )
  