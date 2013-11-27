
      update t_pipeline_service 
			set tt_end = dbo.subtractsecond(%%TT_END%%)
			where id_pipeline=%%ID_PIPELINE%%
			