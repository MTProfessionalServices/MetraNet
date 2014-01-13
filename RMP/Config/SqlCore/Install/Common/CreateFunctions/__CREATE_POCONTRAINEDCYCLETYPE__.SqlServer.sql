
-- returns the required cycle type of a BCR Constrained PO or zero if there is none
CREATE FUNCTION poConstrainedCycleType(@offeringID INTEGER)
RETURNS INTEGER
AS
BEGIN
	DECLARE @retval AS INTEGER

  SELECT
    @retval = MAX(result.id_cycle_type)
  FROM (
    SELECT
      CASE WHEN t_recur.id_cycle_type IS NOT NULL AND
                t_recur.tx_cycle_mode = 'BCR Constrained' THEN
        t_recur.id_cycle_type
      ELSE
        CASE WHEN t_discount.id_cycle_type IS NOT NULL THEN
      t_discount.id_cycle_type
        ELSE
          CASE WHEN t_aggregate.id_cycle_type IS NOT NULL THEN
            t_aggregate.id_cycle_type
          ELSE
            NULL
          END
        END
      END AS id_cycle_type
    FROM t_pl_map
      LEFT OUTER JOIN t_recur ON t_recur.id_prop = t_pl_map.id_pi_template OR
                                 t_recur.id_prop = t_pl_map.id_pi_instance
      LEFT OUTER JOIN t_discount ON t_discount.id_prop = t_pl_map.id_pi_template OR
                                    t_discount.id_prop = t_pl_map.id_pi_instance
      LEFT OUTER JOIN t_aggregate ON t_aggregate.id_prop = t_pl_map.id_pi_template OR
                                     t_aggregate.id_prop = t_pl_map.id_pi_instance
	WHERE
  t_pl_map.id_po = @offeringID
  and t_pl_map.id_paramtable is null
  ) result

  IF (@retval is NULL) BEGIN
   	SET @retval = 0
  END
  RETURN @retval
END
	