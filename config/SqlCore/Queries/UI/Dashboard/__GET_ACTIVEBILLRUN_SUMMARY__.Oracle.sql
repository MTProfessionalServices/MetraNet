select
%%ID_USAGE_INTERVAL%% as id_interval
, sub1.end_date
, sub2.eop_adapter_count
, sub3.EOP_Start_Time
, sub5.eop_RtR_adapter_count
, sub6.eop_NYR_adapter_count
, sub7.eop_failed_adapter_count
, sub8.eop_succeeded_adapter_count
, sub9.last_eop_adapter_name
, sub10.last_eop_adapter_duration
, sub11.last_eop_adapter_status
, sub12."Variance"
, GETUTCDATE() + (20/24 + dbms_random.value(1,10)/24) as earliest_eta

FROM

(SELECT dt_end AS end_date 
from t_usage_interval
where id_interval = %%ID_USAGE_INTERVAL%%
) sub1,

/* --get count of all EOP Adapters */
(select count(*) as eop_adapter_count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and re.tx_type = 'EndofPeriod' 
) sub2,

/* First Adapter Run */
(SELECT (rer.dt_start - 5/24) as EOP_Start_Time
FROM t_recevent_run rer
join t_recevent_inst rei on  rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' 
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and ROWNUM=1
order by rer.dt_start asc) sub3,

/* time of last EOP adapter / checkpoint run  - adjusted */
(SELECT (rer.dt_start - 5/24) as last_adapter_run_time
FROM t_recevent_run rer
join t_recevent_inst rei on rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and rer.tx_type = 'Execute'
and ROWNUM=1
order by rer.dt_start desc) sub4,

/* get count of scheduled adatpters in Ready-to-Run state */
(select count(*) as eop_RtR_adapter_count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and re.tx_type = 'EndofPeriod' and rei.tx_status = 'ReadytoRun'
) sub5,

/* get count of EOP adatpters in not yet run state */
(select count(*) as eop_NYR_adapter_count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and re.tx_type = 'EndofPeriod' and rei.tx_status = 'NotYetRun'
) sub6,

(SELECT count(*) as eop_failed_adapter_count
FROM t_recevent_inst rei
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.tx_status = 'Failed'
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
) sub7,

(SELECT count(*) as eop_succeeded_adapter_count
FROM t_recevent_inst rei 
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rei.tx_status = 'Succeeded'
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
) sub8,

(SELECT re.tx_display_name  as last_eop_adapter_name
FROM t_recevent_run rer
join t_recevent_inst rei on  rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and ROWNUM = 1
order by rer.dt_start desc
) sub9,

/* Get last EOP adapter duration */
(SELECT  dt_start + EXTRACT (DAY FROM nvl(dt_end, (getutcdate() + 4/24))) as last_eop_adapter_duration
FROM t_recevent_run rer
join t_recevent_inst rei on   rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and ROWNUM = 1
order by rer.dt_start desc
) sub10,

/* Get last EOP adapter status */
(SELECT  rer.tx_status as last_eop_adapter_status
FROM t_recevent_run rer
join t_recevent_inst rei on   rei.id_instance = rer.id_instance
join t_recevent re on re.id_event = rei.id_event
where re.tx_type = 'EndofPeriod' and rer.tx_type = 'Execute'
and rei.id_arg_interval = %%ID_USAGE_INTERVAL%%
and ROWNUM = 1
order by rer.dt_start desc
) sub11,

(SELECT dbms_random.value(1,10) + ROUND(dbms_random.value, 2)  AS "Variance"
  FROM DUAL
) sub12