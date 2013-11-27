
      update t_prod_view set 
      id_view=%%ID_VIEW%%, 
      dt_modified=%%%SYSTEMDATE%%%, 
      nm_name=N'%%NM_NAME%%', 
      nm_table_name='%%NM_TABLE%%',
      b_can_resubmit_from='%%B_CAN_RESUBMIT_FROM%%' 
      where 
      id_prod_view=%%ID_PROD_VIEW%%
			