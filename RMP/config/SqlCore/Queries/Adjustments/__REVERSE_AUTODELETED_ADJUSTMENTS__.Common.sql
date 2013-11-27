
				 UPDATE t_adjustment_transaction SET c_status =
				 CASE WHEN id_sess IS NULL THEN 'O' ELSE 'P' END
				 WHERE id_usage_interval = %%INTERVAL_ID%% AND c_status = 'AD'
                 AND id_acc_payer in (select id_acc from t_billgroup_member
									  where id_billgroup = %%BILLGROUP_ID%%)
				 