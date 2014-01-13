
		    insert into %%TABLE_NAME%% (id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
 		    select distinct
			    ft.tx_FailureID, --id_source_sess
			    case when ft.tx_failureID=ft.tx_FailureCompoundID then ft.tx_batch else NULL end, -- tx_batch
			    NULL, -- id_sess
			    NULL, -- id_parent_sess
			    NULL, -- root
			    NULL, -- id_interval
			    NULL, -- id_view
			    '%%STATE%%', -- tx_state
			    ed.id_enum_data, -- id_svc
			    case when ft.tx_failureID=ft.tx_FailureCompoundID then NULL else ft.tx_failureCompoundID end, -- id_parent_source_sess,
		      NULL, -- id_payer
		      NULL, -- amount
		      NULL -- currency
		    from t_failed_transaction ft
		    inner join t_enum_data ed
		    on ed.nm_enum_data = ft.tx_FailureServiceName
		    %%JOIN_CLAUSE%%
		    where (ft.state <> 'R') and (ft.tx_FailureID not in (select id_source_sess from %%TABLE_NAME%%))
		    %%WHERE_CLAUSE%%
		
		  