
SELECT 
  inst.id_instance
FROM t_recevent_inst inst
INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
WHERE
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) AND
  evt.tx_type in (%%TYPE_FILTER%%)
  %%NAME_FILTER%%
  %%BILLING_GROUP_SUPPORT_FILTER%%
  %%INSTANCE_FILTER%%
  %%STATUS_FILTER%%
  %%INTERVAL_FILTER%%
  %%BILLING_GROUP_FILTER%%
  %%START_DATE_FILTER%%
  %%END_DATE_FILTER%%
