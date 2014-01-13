
				SELECT * 
				FROM t_export_execute_audit 
				WHERE c_eop_step_instance_name = '%%EOP_INSTANCE_NAME%%'
					AND id_run = %%ID_RUN%%
					AND c_execution_backedout = 0
			