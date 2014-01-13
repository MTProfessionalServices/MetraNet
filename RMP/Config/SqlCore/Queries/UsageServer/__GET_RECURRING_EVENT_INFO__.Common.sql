
SELECT 
  evt.id_event,
  evt.tx_name,
  evt.tx_type,
  evt.tx_reverse_mode,
  evt.b_multiinstance,
  evt.tx_class_name,
  evt.tx_extension_name,
  evt.tx_config_file,
  evt.dt_activated,
  evt.dt_deactivated,
  evt.tx_display_name,
  evt.tx_desc
FROM t_recevent evt
%%INSTANCE_JOIN%%
WHERE
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
 (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated)
 %%FILTER%%
