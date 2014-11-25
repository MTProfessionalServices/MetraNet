SELECT inst.id_instance InstanceID, 
			inst.dt_arg_start ArgStartDate, 
			inst.dt_arg_end ArgEndDate, 
			inst.b_ignore_deps IgnoreDeps, 
			inst.dt_effective EffectiveDate,
			
			/* Status */ 
			COALESCE( (select de.tx_desc
					  from t_enum_data e        
						left outer join t_description de on de.id_desc = e.id_enum_data and de.id_lang_code = %%ID_LANGUAGE%%

					  where UPPER(e.nm_enum_data) = UPPER(CONCAT('metratech.com/Events/Status/', inst.tx_status)))
					, inst.tx_status) Status,
					
			run.id_run LastRunID,

			/* LastRunAction */
			COALESCE( (select de.tx_desc
					  from t_enum_data e        
						left outer join t_description de on de.id_desc = e.id_enum_data and de.id_lang_code = %%ID_LANGUAGE%%

					  where UPPER(e.nm_enum_data) = UPPER(CONCAT('metratech.com/Events/Action/', run.tx_type)))
					, run.tx_type ) LastRunAction, 

			run.dt_start LastRunStart, 
			run.dt_end LastRunEnd,

			/* LastRunStatus */
			COALESCE( (select de.tx_desc
					  from t_enum_data e        
						left outer join t_description de on de.id_desc = e.id_enum_data and de.id_lang_code = %%ID_LANGUAGE%%

					  where UPPER(e.nm_enum_data) = UPPER(CONCAT('metratech.com/Events/Status/', run.tx_status)))
					, run.tx_status) LastRunStatus, 
			run.tx_detail LastRunDetail,
			run.tx_machine LastRunMachine
    FROM t_recevent_inst inst 
			INNER JOIN t_recevent evt ON evt.id_event = inst.id_event 
			LEFT OUTER JOIN ( SELECT id_instance, MAX(id_run) id_run, MAX(dt_start) dt_start FROM t_recevent_run run GROUP BY id_instance )
			maxrun ON maxrun.id_instance = inst.id_instance 
			LEFT OUTER JOIN t_recevent_run run ON run.dt_start = maxrun.dt_start AND run.id_run = maxrun.id_run
			INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
			WHERE evt.id_event = %%ID_EVENT%% 
			GROUP BY 
			inst.id_instance, inst.dt_arg_start, 
			inst.dt_arg_end, inst.b_ignore_deps, inst.dt_effective, inst.tx_status, run.id_run, 
			run.tx_type, run.dt_start, run.dt_end, run.tx_status, run.tx_detail, run.tx_machine 
			ORDER BY ArgStartDate asc, ArgEndDate asc