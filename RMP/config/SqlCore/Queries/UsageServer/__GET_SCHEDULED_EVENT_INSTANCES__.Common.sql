
SELECT 
  inst.id_instance
FROM t_recevent_inst inst
INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
%%INTERVAL_JOIN%%
WHERE
  /*  event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_type = 'Scheduled'
  %%NAME_FILTER%%
  %%INSTANCE_FILTER%%
  %%STATUS_FILTER%%
  %%START_DATE_FILTER%%
  %%END_DATE_FILTER%%
