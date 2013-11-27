
                SELECT COUNT(*) FROM t_adjustment_transaction
                WHERE id_usage_interval = %%INTERVAL_ID%%
                      AND n_adjustmenttype = 0 AND c_status IN ('P', 'O')
	                  AND id_acc_payer in (select id_acc from t_billgroup_member
										   where id_billgroup = %%BILLGROUP_ID%%)
                 