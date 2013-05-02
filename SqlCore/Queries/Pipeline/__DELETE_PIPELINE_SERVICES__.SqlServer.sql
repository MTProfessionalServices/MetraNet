
      update t_pipeline_service 
			set tt_end = dateadd(s, -1, %%TT_END%%)
			where id_pipeline=%%ID_PIPELINE%%
			