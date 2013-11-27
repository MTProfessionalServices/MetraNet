
			INSERT into %%TABLE_NAME%% (id, id_source_sess, tx_batch, id_sess, id_parent_sess, root, id_interval, id_view, tx_state, id_svc, id_parent_source_sess, id_payer, amount, currency)
            SELECT 
            seq_%%TABLE_NAME%%.NEXTVAL, 
			f.tx_FailureID, --id_source_sess
			case when f.tx_failureID=f.tx_FailureCompoundID then f.tx_batch else NULL end, -- tx_batch
			NULL, -- id_sess
			NULL, -- id_parent_sess
			NULL, -- root
			NULL, -- id_interval
			NULL, -- id_view
			'E', -- tx_state
			ed.id_enum_data, -- id_svc
			case when f.tx_failureID=f.tx_FailureCompoundID then NULL else f.tx_failureCompoundID end, -- id_parent_source_sess,
			NULL, -- id_payer
			NULL,
			NULL
            FROM t_failed_transaction f
            JOIN
            	(
            	SELECT a.id_entity, MAX(a.dt_crt) dt_crt
            	FROM t_audit a
            	INNER JOIN t_audit_details ad 
            		ON a.id_audit=ad.id_audit
            		AND ad.tx_details like 'Status Changed To ''Dismissed''%' 
            	WHERE a.id_event = 1701 
            	GROUP BY a.id_entity
            	) tmp
            	ON tmp.id_entity = f.id_failed_transaction
              AND tmp.dt_crt < %%DT_END%%
            INNER JOIN t_enum_data ed on upper(ed.nm_enum_data) = upper(f.tx_FailureServiceName)
            WHERE f.State = 'P' and (f.tx_FailureID not in (select id_source_sess from %%TABLE_NAME%%))
			
        