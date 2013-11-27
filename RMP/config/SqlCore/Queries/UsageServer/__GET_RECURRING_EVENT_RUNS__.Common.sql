
SELECT
  run.id_run RunID,
  run.id_instance InstanceID,
  run.tx_type Action,
  run.id_reversed_run ReversedRunID,
  run.dt_start StartDate,
  run.dt_end EndDate,
  run.tx_status Status,
  run.tx_detail Result,
  run.tx_machine Machine,
  CASE WHEN details.id_run IS NULL THEN 'N' ELSE 'Y' END HasDetails,
  case when batch.total is null then 0 else batch.total end Batches
FROM t_recevent_run run
LEFT OUTER JOIN 
(
  /* determines if this run has additional details */
  SELECT DISTINCT id_run
  FROM t_recevent_run_details
) details ON details.id_run = run.id_run
LEFT OUTER JOIN
(
  /* gets the number of batches associated with the run */
  SELECT 
    id_run,
    COUNT(*) total
  FROM t_recevent_run_batch
  GROUP BY id_run
) batch ON batch.id_run = run.id_run
%%OPTIONAL_WHERE_CLAUSE%%
ORDER BY run.dt_start desc
		