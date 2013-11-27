
SELECT 
  evt.id_event EventID,
  evt.tx_name EventName,
  evt.tx_display_name EventDisplayName,
  evt.tx_type EventType,
  evt.tx_reverse_mode ReverseMode,
  evt.tx_class_name ClassName,
  evt.tx_config_file ConfigFile,
  evt.tx_desc EventDescription,
  inst.id_instance InstanceID,
  case when inst.id_arg_interval is null then inst.dt_arg_start else run.dt_start end as ArgStartDate, 
  case when inst.id_arg_interval is null then inst.dt_arg_end else run.dt_end end as ArgEndDate, 
  inst.b_ignore_deps IgnoreDeps,
  inst.dt_effective EffectiveDate,    
  inst.tx_status Status,
  run.id_run LastRunID,
  run.tx_type LastRunAction,
  run.dt_start LastRunStart,
  run.dt_end LastRunEnd,
  run.tx_status LastRunStatus,
  run.tx_detail LastRunDetail,
  run.tx_machine LastRunMachine,
  {fn ifnull(batch.total, 0)} LastRunBatches,
  COUNT(dep.id_event) TotalDeps,
  {fn ifnull(warnings.total, 0)} LastRunWarnings
FROM t_recevent_inst inst
INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
LEFT OUTER JOIN
(
  /* finds the last run's ID */
  SELECT 
    id_instance,
    MAX(dt_start) dt_start
  FROM t_recevent_run run
  GROUP BY
    id_instance
) maxrun ON maxrun.id_instance = inst.id_instance
LEFT OUTER JOIN t_recevent_run run ON run.dt_start = maxrun.dt_start AND
                                      run.id_instance = maxrun.id_instance
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
              inst.tx_status NOT IN ('ReadyToRun', 'ReadyToReverse')
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
%%INTERVAL_JOIN%%
WHERE
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_type = 'Scheduled'
  %%NAME_FILTER%%
  %%INSTANCE_FILTER%%
  %%STATUS_FILTER%%
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
  inst.id_instance,
  inst.dt_arg_start,
  inst.dt_arg_end,
  inst.b_ignore_deps,
  inst.dt_effective,    
  inst.tx_status,
  inst.id_arg_interval,
  run.id_run,
  run.tx_type,
  run.dt_start,
  run.dt_end,
  run.tx_status,
  run.tx_detail,
  run.tx_machine,
  batch.total,
  warnings.total
ORDER BY
  TotalDeps ASC,
  evt.tx_display_name ASC
