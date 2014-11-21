
/* ===========================================================
    Modified from original [__GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__]
    to filter on billing groups in addition to intervals
=========================================================== */
SELECT 
  evt.id_event EventID,
  evt.tx_name EventName,
  evt.tx_display_name EventDisplayName,
  evt.tx_type EventType,
  evt.tx_reverse_mode ReverseMode,
  evt.tx_class_name ClassName,
  evt.tx_config_file ConfigFile,
  evt.tx_desc EventDescription,
  evt.tx_billgroup_support BillGroupSupportType,
  inst.id_instance InstanceID,
  inst.id_arg_interval ArgIntervalID,
  inst.id_arg_billgroup BillGroupID,
  inst.b_ignore_deps IgnoreDeps,
  inst.dt_effective EffectiveDate,    
  inst.tx_status Status,
  CASE WHEN cur_run.tx_status = 'InProgress' THEN cur_run.id_run ELSE run.id_run END LastRunID,
  run.tx_type LastRunAction,
  {fn ifnull(run.dt_start, cur_run.dt_start)} LastRunStart, 
  {fn ifnull(run.dt_end, %%%SYSTEMDATE%%%)} LastRunEnd,
  {fn ifnull(cur_run.tx_status,run.tx_status)} LastRunStatus,
  CASE WHEN cur_run.tx_status = 'InProgress' THEN cur_run.tx_detail ELSE run.tx_detail END LastRunDetail,
  {fn ifnull(run.tx_machine, cur_run.tx_machine)} LastRunMachine, 
  {fn ifnull(batch.total, 0)} LastRunBatches,
  COUNT(dep.id_event) TotalDeps,
  {fn ifnull(warnings.total, 0)} LastRunWarnings,
  CASE WHEN evt.tx_billgroup_support = 'Interval' THEN 'Y' ELSE 'N' END IsGlobalAdapter
FROM t_recevent_inst inst
INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
LEFT OUTER JOIN %%TMP_BILLGROUP_TABLE%% bgs ON bgs.id_billgroup = inst.id_arg_billgroup
LEFT OUTER JOIN  
( 
	 	  /* finds the current run's ID */ 
 	  SELECT  
 	    id_instance, 
 	    MAX(dt_start) dt_start 
 	  FROM t_recevent_run run 
 	  where dt_end is null 
 	  GROUP BY 
 	    id_instance 
 	) current_run ON current_run.id_instance = inst.id_instance 
 	LEFT OUTER JOIN t_recevent_run cur_run  
 	  ON cur_run.dt_start = current_run.dt_start 
 	  AND cur_run.id_instance = current_run.id_instance 
LEFT OUTER JOIN
(
  /* finds the last run's ID */
  SELECT 
    id_instance,
    MAX(dt_end) dt_end
  FROM t_recevent_run run
  GROUP BY
    id_instance
) maxrun ON maxrun.id_instance = inst.id_instance
LEFT OUTER JOIN t_recevent_run run 
  ON run.dt_end = maxrun.dt_end
  AND run.id_instance = maxrun.id_instance
LEFT OUTER JOIN
(
  /* counts warnings from the last run */
  SELECT 
   id_run,
   COUNT(*) total
  FROM t_recevent_run_details details
  WHERE details.tx_type = 'Warning'
  GROUP BY id_run
) warnings ON warnings.id_run = run.id_run AND
              inst.tx_status NOT IN ('ReadyToRun', 'ReadyToReverse', 'InProgress')
LEFT OUTER JOIN
(
  /* gets the number of batches associated with the last run */
  SELECT 
    id_run,
    COUNT(*) total
  FROM t_recevent_run_batch
  GROUP BY id_run
) batch ON batch.id_run = run.id_run
INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
WHERE
  /*  only show events that are active when the billing group is open or soft closed
      or all events (including deactivated events) when the billing group is hard closed (CR11287)
      */
  (  
    (
      evt.dt_activated <= %%%SYSTEMDATE%%% AND
      (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) 
    ) OR
    /* or the event is not necessarily active and interval is hard closed */
    (bgs.status ='H' OR bgs.status IS NULL)

  ) AND
  evt.tx_type in (%%TYPE_FILTER%%)
  %%NAME_FILTER%%
  %%BILLING_GROUP_SUPPORT_FILTER%%
  %%INSTANCE_FILTER%%
  %%STATUS_FILTER%%
  %%INTERVAL_FILTER%%
  %%BILLING_GROUP_FILTER%%
  %%START_DATE_FILTER%%
  %%END_DATE_FILTER%%
GROUP BY
  evt.id_event,
  evt.tx_name,
  evt.tx_type,
  evt.tx_display_name,
  evt.tx_reverse_mode,
  evt.tx_class_name,
  evt.tx_config_file,
  evt.tx_desc,
  evt.tx_billgroup_support,
  inst.id_instance,
  inst.id_arg_interval,
  inst.id_arg_billgroup,
  inst.b_ignore_deps,
  inst.dt_effective,    
  inst.tx_status,
  run.id_run,
  cur_run.id_run,
  run.tx_type,
  run.dt_start,
  cur_run.dt_start,  
  run.dt_end,
  run.tx_status,
  cur_run.tx_status,  
  run.tx_detail,
  cur_run.tx_detail,
  run.tx_machine,
  cur_run.tx_machine,
  batch.total,
  warnings.total
ORDER BY
  inst.id_arg_interval ASC,
  TotalDeps ASC,
  evt.tx_display_name ASC
 	