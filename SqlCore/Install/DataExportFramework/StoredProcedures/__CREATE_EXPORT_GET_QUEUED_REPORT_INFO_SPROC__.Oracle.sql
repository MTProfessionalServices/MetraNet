                                     
      CREATE OR REPLACE PROCEDURE export_getqueuedreportinfo (
      	p_id_work_queue IN CHAR DEFAULT NULL,
      	p_system_datetime IN DATE DEFAULT NULL
      )
AS
    v_rawworkqid   RAW (16) := NULL;
    v_dt_end       DATE := NULL;   
BEGIN
    v_rawworkqid := HEXTORAW (TRANSLATE (p_id_work_queue, '0{-}', '0'));
	
	execute immediate 'TRUNCATE TABLE tt_queuedreportinfo';
    
	INSERT INTO tt_queuedreportinfo
        (SELECT   c_rep_title,
                  c_rep_type,
                  c_rep_def_source,                  
                  c_rep_query_tag,
                  LOWER (c_rep_output_type) c_rep_output_type,
                  c_rep_distrib_type,
                  c_rep_destn,
                  NVL (c_destn_direct, 0) c_destn_direct,
                  c_destn_access_user,
                  c_destn_access_pwd,
                  c_generate_control_file,
                  c_control_file_delivery_locati,
                  c_exec_type,
                  c_compressreport,
                  NVL (c_compressthreshold, -1) c_compressthreshold,
                  NVL (c_ds_id, 0) c_ds_id,
                  c_eop_step_instance_name,
                  dt_last_run,
                  dt_next_run,
                  c_output_execute_params_info,
                  c_use_quoted_identifiers,
                  id_rep_instance_id,
                  id_schedule,
                  c_sch_type,
                  dt_sched_run,
                  REPLACE (c_param_name_values, '%', '^') c_param_name_values,                  
                  c_output_file_name,
                  id_work_queue,
                  dt_queued,
                  TO_CHAR (NVL (dt_next_run, p_system_datetime) - 1, 'MM/DD/YYYY')
                      control_file_data_date
           FROM   t_export_workqueue a
          WHERE   id_work_queue = v_rawworkqid);
          
    BEGIN
        SELECT   ui.dt_end
          INTO   v_dt_end
          FROM       tt_queuedreportinfo qri
                 LEFT OUTER JOIN t_usage_interval ui
                 ON (CAST (REGEXP_SUBSTR(regexp_replace(qri.c_param_name_values,
             '.*?\^\^ID_INTERVAL\^\^\=(\d{10})(,?.*?)',
          '\1'), '\d{10}', 1) AS number) = ui.id_interval)
         WHERE   id_work_queue IN
                         (SELECT   tt_queuedreportinfo.id_work_queue
                            FROM   tt_queuedreportinfo
                           WHERE   tt_queuedreportinfo.c_exec_type = 'eop'
                                   AND tt_queuedreportinfo.c_param_name_values LIKE
                                          '%ID_INTERVAL%')
                 AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            UPDATE   tt_queuedreportinfo
               SET   c_param_name_values =
                         REPLACE (c_param_name_values, '^', '%');

            RETURN;
    END;

    UPDATE   tt_queuedreportinfo
       SET   control_file_data_date =
                 TO_CHAR (NVL (v_dt_end, p_system_datetime) + 1, 'MM/DD/YYYY');

    UPDATE   tt_queuedreportinfo
       SET   c_param_name_values = REPLACE (c_param_name_values, '^', '%');
END;
	 