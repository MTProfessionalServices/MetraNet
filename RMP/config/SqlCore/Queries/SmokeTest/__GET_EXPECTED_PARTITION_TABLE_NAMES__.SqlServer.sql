
			SELECT DISTINCT table_name
			FROM   information_schema.columns
			WHERE  table_name LIKE 't_pv_%'
			       OR  table_name LIKE 't_svc_%'
				   OR  table_name = 't_acc_usage'
				   OR  table_name = 'agg_usage_audit_trail'
				   OR  table_name = 'agg_charge_audit_trail'
				   OR  table_name = 't_message'
				   OR  table_name = 't_session'
				   OR  table_name = 't_session_set'
				   OR  table_name = 't_session_state'
		