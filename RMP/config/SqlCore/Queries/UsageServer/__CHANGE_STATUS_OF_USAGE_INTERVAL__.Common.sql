
          UPDATE t_usage_interval SET tx_interval_status = '%%NEW_STATUS%%'
				  FROM t_usage_interval ui 
          WHERE 
            ui.id_interval = %%ID_INTERVAL%% AND
            ui.tx_interval_status <> '%%NEW_STATUS%%'    
        