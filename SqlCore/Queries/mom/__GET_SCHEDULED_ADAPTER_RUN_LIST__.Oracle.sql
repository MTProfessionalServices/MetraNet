
SELECT 
  inst.id_instance /*InstanceID*/,
  COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name /*EventDisplayName*/,
  inst.tx_status /*Status*/,
  case when inst.id_arg_interval is null then inst.dt_arg_start else run.dt_start end as dt_argstartdate, 
  case when inst.id_arg_interval is null then inst.dt_arg_end else run.dt_end end as dt_argenddate, 
  run.dt_start /*LastRunStart*/,
  run.tx_machine /*LastRunMachine*/
FROM t_recevent_inst inst
INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = %%ID_LANG_CODE%% AND evt.id_event=loc.id_item)
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
WHERE
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_type = 'Scheduled' AND
  run.dt_end >= TO_DATE ('%%END_DATE%%', 'MM/DD/YYYY HH24:MI:SS')
