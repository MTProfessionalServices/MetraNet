SELECT 

%%ID_USAGE_INTERVAL%% AS id_interval
, (
    SELECT dt_end AS end_date 
    FROM t_usage_interval
    WHERE id_interval = %%ID_USAGE_INTERVAL%%
  ) AS end_date
, (
    SELECT COUNT(*) AS eop_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND re.tx_type = 'EndofPeriod' 
  ) AS eop_adapter_count
, (
    SELECT * FROM (SELECT (rer.dt_start - 5/24) AS EOP_Start_Time
    FROM t_recevent_run rer
    JOIN t_recevent_inst rei ON  rei.id_instance = rer.id_instance
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndofPeriod' 
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND rer.tx_type = 'Execute'
    AND ROWNUM=1
    ORDER BY rer.dt_start ASC)
  ) AS EOP_Start_Time
, (
    SELECT * FROM (SELECT (rer.dt_start - 5/24) AS EOP_Start_Time
    FROM t_recevent_run rer
    JOIN t_recevent_inst rei ON  rei.id_instance = rer.id_instance
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndofPeriod' 
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND rer.tx_type = 'Execute'
    AND ROWNUM=1
    ORDER BY rer.dt_start DESC)
  ) AS last_adapter_run_time  
, (
    SELECT COUNT(*) AS eop_RtR_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND re.tx_type = 'EndofPeriod' AND rei.tx_status = 'ReadytoRun'
  ) AS eop_RtR_adapter_count
, (
    SELECT COUNT(*) AS eop_NYR_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND re.tx_type = 'EndofPeriod' AND rei.tx_status = 'NotYetRun'
  ) AS eop_NYR_adapter_count
, (
    SELECT COUNT(*) AS eop_failed_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndofPeriod' AND rei.tx_status = 'Failed'
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
  ) AS eop_failed_adapter_count
, (
    SELECT COUNT(*) AS eop_succeeded_adapter_count
    FROM t_recevent_inst rei 
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndofPeriod' AND rei.tx_status = 'Succeeded'
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
  ) AS eop_succeeded_adapter_count
, (
    SELECT * FROM (
                    SELECT re.tx_display_name  AS last_eop_adapter_name
                    FROM t_recevent_run rer
                    JOIN t_recevent_inst rei ON  rei.id_instance = rer.id_instance
                    JOIN t_recevent re ON re.id_event = rei.id_event
                    WHERE re.tx_type = 'EndofPeriod' AND rer.tx_type = 'Execute'
                    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
                    AND ROWNUM = 1
                    ORDER BY rer.dt_start DESC
                  )
  )  AS last_eop_adapter_name
, (
    SELECT * FROM (
                    SELECT  dt_start + EXTRACT (DAY FROM nvl(dt_end, (getutcdate() + 4/24))) as last_eop_adapter_duration
                    FROM t_recevent_run rer
                    JOIN t_recevent_inst rei ON rei.id_instance = rer.id_instance
                    JOIN t_recevent re ON re.id_event = rei.id_event
                    WHERE re.tx_type = 'EndofPeriod' AND rer.tx_type = 'Execute'
                    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
                    AND ROWNUM = 1
                    ORDER BY rer.dt_start DESC
                  )
  )  AS last_eop_adapter_duration
, (
    SELECT * FROM (
                    SELECT  rer.tx_status AS last_eop_adapter_status
                    FROM t_recevent_run rer
                    JOIN t_recevent_inst rei ON rei.id_instance = rer.id_instance
                    JOIN t_recevent re ON re.id_event = rei.id_event
                    WHERE re.tx_type = 'EndofPeriod' AND rer.tx_type = 'Execute'
                    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
                    and ROWNUM = 1
                    ORDER BY rer.dt_start DESC
                  )
  ) AS last_eop_adapter_status
, (
    SELECT ROUND(dbms_random.value(1,10),2) + ROUND(dbms_random.value, 2)  AS "Variance"
    FROM DUAL
  ) AS "Variance"
, GETUTCDATE() + (20/24 + dbms_random.value(1,10)/24) AS earliest_eta

FROM DUAL
