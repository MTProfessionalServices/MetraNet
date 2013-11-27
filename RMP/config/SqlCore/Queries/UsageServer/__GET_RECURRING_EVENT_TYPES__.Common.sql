
SELECT 
  tx_name "Event",
  tx_type "EventType"
FROM t_recevent 
WHERE 
  /* exlcludes root events since they have internal meaning only */
  %%EXCLUDE_ROOT_EVENTS%%
  /* event is active */
  dt_activated <= %%%SYSTEMDATE%%% AND
  (dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < dt_deactivated)
ORDER BY tx_name ASC
