   
        /*  __GET_ADAPTER_INSTANCE_INFORMATION__ */   
      SELECT 
				inst.id_instance InstanceID, 
      COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
				evt.tx_reverse_mode ReverseMode, 
				inst.dt_arg_start ArgStartDate, 
				inst.dt_arg_end ArgEndDate, 
				inst.b_ignore_deps IgnoreDeps, 
				inst.dt_effective EffectiveDate, 
				inst.tx_status Status, 
				run.id_run LastRunID, 
				run.tx_type LastRunAction, 
				run.dt_start LastRunStart, 
				run.dt_end LastRunEnd, 
				run.tx_status LastRunStatus, 
				run.tx_detail LastRunDetail,
				run.tx_machine LastRunMachine
				FROM t_recevent_inst inst 
				INNER JOIN t_recevent evt ON evt.id_event = inst.id_event 
        LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = %%ID_LANG_CODE%% AND evt.id_event=loc.id_item)
				LEFT OUTER JOIN ( SELECT id_instance, MAX(dt_start) dt_start FROM t_recevent_run run GROUP BY id_instance ) 
				maxrun ON maxrun.id_instance = inst.id_instance 
                /* ESR-4188 add predicate on id_instance */                              
				LEFT OUTER JOIN t_recevent_run run ON run.dt_start = maxrun.dt_start and run.id_instance = maxrun.id_instance         
				INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event WHERE inst.id_instance=%%ID_INSTANCE%% 
      GROUP BY evt.id_event, evt.tx_name, evt.tx_type, evt.tx_display_name, evt.tx_reverse_mode, 
				evt.tx_class_name, evt.tx_config_file, evt.tx_desc, inst.id_instance, inst.dt_arg_start, 
				inst.dt_arg_end, inst.b_ignore_deps, inst.dt_effective, inst.tx_status, run.id_run, 
				run.tx_type, run.dt_start, run.dt_end, run.tx_status, run.tx_detail, run.tx_machine,
        loc.tx_name
      ORDER BY evt.tx_name asc, 
				inst.dt_arg_start asc, inst.tx_status
 			