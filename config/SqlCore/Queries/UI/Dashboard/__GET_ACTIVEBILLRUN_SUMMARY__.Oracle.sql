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
    AND re.tx_type = 'EndOfPeriod' 
  ) AS eop_adapter_count
, (
    SELECT * FROM (SELECT (rer.dt_start - 5/24) AS EOP_Start_Time
    FROM t_recevent_run rer
    JOIN t_recevent_inst rei ON  rei.id_instance = rer.id_instance
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndOfPeriod' 
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
    WHERE re.tx_type = 'EndOfPeriod' 
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
    AND re.tx_type = 'EndOfPeriod' AND rei.tx_status = 'ReadytoRun'
  ) AS eop_RtR_adapter_count
, (
    SELECT COUNT(*) AS eop_NYR_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
    AND re.tx_type = 'EndOfPeriod' AND rei.tx_status = 'NotYetRun'
  ) AS eop_NYR_adapter_count
, (
    SELECT COUNT(*) AS eop_failed_adapter_count
    FROM t_recevent_inst rei
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndOfPeriod' AND rei.tx_status = 'Failed'
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
  ) AS eop_failed_adapter_count
, (
    SELECT COUNT(*) AS eop_succeeded_adapter_count
    FROM t_recevent_inst rei 
    JOIN t_recevent re ON re.id_event = rei.id_event
    WHERE re.tx_type = 'EndOfPeriod' AND rei.tx_status = 'Succeeded'
    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
  ) AS eop_succeeded_adapter_count
, (
    SELECT * FROM (
                    SELECT re.tx_display_name  AS last_eop_adapter_name
                    FROM t_recevent_run rer
                    JOIN t_recevent_inst rei ON  rei.id_instance = rer.id_instance
                    JOIN t_recevent re ON re.id_event = rei.id_event
                    WHERE re.tx_type = 'EndOfPeriod' AND rer.tx_type = 'Execute'
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
                    WHERE re.tx_type = 'EndOfPeriod' AND rer.tx_type = 'Execute'
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
                    WHERE re.tx_type = 'EndOfPeriod' AND rer.tx_type = 'Execute'
                    AND rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
                    and ROWNUM = 1
                    ORDER BY rer.dt_start DESC
                  )
  ) AS last_eop_adapter_status
, (
SELECT
  case when
        /*Past_three_month_average*/
(SELECT  case when count(distinct rei.id_arg_interval) != 0 then sum(ROUND((rer.dt_end - rer.dt_start) * 86400,0)) / count(distinct rei.id_arg_interval) else 0.0 end
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > add_months(GETUTCDATE(),-3)
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and tx_name in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded')
        )
  != 0.0 then
    ROUND(
      (
        (/*EOP_Interval_run_time*/
(SELECT NVL(sum(ROUND((rer.dt_end - rer.dt_start) * 86400,0)),0.0)
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded')

        - 
        
        /*Past_three_month_average*/
(SELECT  case when count(distinct rei.id_arg_interval) != 0 then sum(ROUND((rer.dt_end - rer.dt_start) * 86400,0)) / count(distinct rei.id_arg_interval) else 0.0 end
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > add_months(GETUTCDATE(),-3)
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and tx_name in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'))
        ) *  
        
        (100 / 
        /*Past_three_month_average*/
(SELECT  case when count(distinct rei.id_arg_interval) != 0 then sum(ROUND((rer.dt_end - rer.dt_start) * 86400,0)) / count(distinct rei.id_arg_interval) else 0.0 end
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > add_months(GETUTCDATE(),-3)
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and tx_name in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'))        
        )
      ) , 2) /*round off the Variance to 2 decimal places*/
  else 
    0.0 
  end
  FROM DUAL
  ) AS "Variance"  
, (SELECT 
/*This is the 3 month average run time (in seconds) for the adapters that have *not* yet run successfully for the current interval*/
(SELECT  case when count(distinct rei.id_arg_interval) != 0 then sum(ROUND((rer.dt_end - rer.dt_start) * 24,0)) / count(distinct rei.id_arg_interval) else 0 end
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > add_months(GETUTCDATE(),-3)
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and tx_name not in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'
)
and tx_name != '_EndRoot')
+ GETUTCDATE()
FROM DUAL) AS "earliest_eta"
,
/*This is the 3 month average run time (in hours) for the adapters that have *not* yet run successfully for the current interval*/
ROUND((
SELECT  case when count(distinct rei.id_arg_interval) != 0 then sum((rer.dt_end - rer.dt_start) * 24) / count(distinct rei.id_arg_interval) else 0 end
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
WHERE id_arg_interval in (
select ui.id_interval
from t_usage_interval ui
where ui.tx_interval_status = 'H'
and ui.dt_end > add_months(GETUTCDATE(),-3)
and ui.id_usage_cycle = (select id_usage_cycle from t_usage_interval where id_interval = %%ID_USAGE_INTERVAL%%))
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and tx_name not in (
-- These are the adapters that have successfully run so far for the current EOP interval
SELECT tx_name
  FROM t_recevent_inst rei
  join t_recevent re on re.id_event = rei.id_event
  left join t_recevent_run rer on rer.id_instance = rei.id_instance
Where id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and NVL(tx_detail,' ') not like 'Manually changed status%'
and rei.tx_status = 'Succeeded'
)
and tx_name != '_EndRoot'
), 3) AS "eta_offset"
FROM DUAL