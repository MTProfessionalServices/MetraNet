
SELECT
  run.id_run RunID,
  run.tx_type Action,
  run.id_reversed_run ReversedRunID,
  run.dt_start StartDate,
  run.dt_end EndDate,
  run.tx_status Status,
  run.tx_detail Result,
  CASE WHEN details.id_run IS NULL THEN 'N' ELSE 'Y' END HasDetails
FROM t_recevent_run run
LEFT OUTER JOIN 
(
  SELECT DISTINCT id_run
  FROM t_recevent_run_details
) details ON details.id_run = run.id_run
WHERE run.id_instance = %%ID_INSTANCE%%
ORDER BY run.dt_start desc
		