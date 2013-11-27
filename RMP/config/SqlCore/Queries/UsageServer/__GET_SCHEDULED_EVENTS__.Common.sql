
SELECT 
  evt.tx_name Name,
  evt.tx_display_name DisplayName,
  evt.id_event EventID
FROM t_recevent evt
WHERE
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  /* only scheduled events */
  evt.tx_type = 'Scheduled'
