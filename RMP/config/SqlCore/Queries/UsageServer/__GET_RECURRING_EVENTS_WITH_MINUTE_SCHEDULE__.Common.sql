
SELECT 
  evt.id_event,
  sch.interval n_minutes
FROM t_recevent evt
INNER JOIN t_recevent_scheduled sch ON sch.id_event = evt.id_event
WHERE 
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_type = 'Scheduled' AND
  sch.interval_type = 'Minutely'
