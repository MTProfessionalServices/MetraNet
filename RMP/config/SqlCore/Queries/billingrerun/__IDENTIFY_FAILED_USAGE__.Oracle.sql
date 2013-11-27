
		    insert into %%TABLE_NAME%% (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
 		    select
 		      seq_%%TABLE_NAME%%.NEXTVAL,
			    ft.tx_FailureID, 
			    case when ft.tx_failureID=ft.tx_FailureCompoundID then ft.tx_batch else NULL end as tx_batch, 
			    NULL, 
			    NULL, 
			    NULL, 
			    NULL, 
			    NULL, 
			    '%%STATE%%',
			    ed.id_enum_data, 
			    case when ft.tx_failureID=ft.tx_FailureCompoundID then NULL else ft.tx_failureCompoundID end as id_parent_source_sess, 
		      NULL, 
		      NULL, 
		      NULL
		    from t_failed_transaction ft
		    inner join t_enum_data ed
		    on upper(ed.nm_enum_data) = upper(ft.tx_FailureServiceName)
		    %%JOIN_CLAUSE%%
		    where (ft.state <> 'R') and (ft.tx_FailureID not in (select id_source_sess from %%TABLE_NAME%%))
		    %%WHERE_CLAUSE%%
		
		  