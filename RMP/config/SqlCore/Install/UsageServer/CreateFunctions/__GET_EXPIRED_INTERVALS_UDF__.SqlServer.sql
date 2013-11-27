
/* ===========================================================
   Returns the expired intervals based on the given datetime. 
   If @not_materialized is '1', then return only those intervals which have not been materialized.
   Otherwise, the materialization status of the interval does not matter.
=========================================================== */
CREATE FUNCTION GetExpiredIntervals
(
   @dt_now DATETIME,
   @not_materialized INT
)
RETURNS @retIntervals TABLE (id_interval INT)
AS

BEGIN

INSERT @retIntervals
SELECT ui.id_interval  
FROM t_usage_interval ui
INNER JOIN t_usage_cycle uc 
   ON uc.id_usage_cycle = ui.id_usage_cycle
INNER JOIN t_usage_cycle_type uct 
   ON uct.id_cycle_type = uc.id_cycle_type
WHERE
  -- if the not_materialized flag is '1' 
  -- then
  --    return only those intervals which have not been materialized
  -- else 
  --    the materialization status of the interval does not matter
  CASE WHEN @not_materialized = 1
           THEN (SELECT COUNT(id_materialization) 
                      FROM t_billgroup_materialization 
                      WHERE id_usage_interval = ui.id_interval)
           ELSE 0
           END = 0 
  AND
  CASE WHEN uct.n_grace_period IS NOT NULL 
            THEN ui.dt_end + uct.n_grace_period -- take into account the cycle type's grace period
            ELSE @dt_now -- the grace period has been disabled, so don't close this interval
            END < @dt_now

    RETURN

END
   