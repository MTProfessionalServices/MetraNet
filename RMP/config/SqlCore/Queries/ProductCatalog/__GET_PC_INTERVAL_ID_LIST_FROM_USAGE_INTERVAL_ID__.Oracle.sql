
				select
					pc.id_interval as id_interval
				from
					t_pc_interval pc,
					t_usage_interval ui
				where
					pc.dt_start>=ui.dt_start 
					and pc.dt_start<=ui.dt_end
					and pc.id_interval not in (
						select ner.id_interval from t_nonrecurring_event_run ner)
					and pc.id_cycle=2 
					and ui.id_interval=%%USAGE_INTERVAL_ID%%
					and pc.dt_start <= TO_DATE('%%END_DATE%%', 'YYYY/MM/DD HH24:MI:SS')
			