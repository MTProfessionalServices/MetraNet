
SELECT 
  evt.tx_name "Event",
  depevt.tx_name "DependsOn"
FROM t_recevent_dep dep
INNER JOIN t_recevent evt ON evt.id_event = dep.id_event
INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
WHERE 
  /* only consider the explicit dependencies */
  n_distance = 1 AND
  /* exlcludes root events since they have internal meaning only */
  %%EXCLUDE_ROOT_EVENTS%%
  /* excludes dependencies on root events */
  %%EXCLUDE_DEPS_ON_ROOT_EVENTS%%
  /* event is active */
  evt.dt_activated <= %%%SYSTEMDATE%%% AND
  (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated)
ORDER BY evt.tx_name ASC
