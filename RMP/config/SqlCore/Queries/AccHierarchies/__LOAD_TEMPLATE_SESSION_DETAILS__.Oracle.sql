
            select 
	            cast(id_detail as int) as DetailId,
	            rownum as SequenceId,
	            id_session as SessionId,
	            n_detail_type as Type,
	            n_result as Result,
	            dt_detail as DetailDate,
	            nm_text as Detail,
              n_retry_count as NumRetries
            from t_acc_template_session_detail
            where
	            id_session = %%SESSION_ID%%
            order by DetailId
        