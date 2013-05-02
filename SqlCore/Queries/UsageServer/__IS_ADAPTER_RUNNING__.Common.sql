
SELECT COUNT(*) Total
FROM t_recevent evt
INNER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
WHERE 
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
  (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_name = '%%EVENT_NAME%%' AND
  inst.tx_status = 'Running'
