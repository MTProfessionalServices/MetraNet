
CREATE FUNCTION POContainsBillingCycleRelative
(
  @id_po INT  -- product offering ID
)
RETURNS INT  -- 1 if the PO contains BCR PIs, otherwise 0
AS
BEGIN
  DECLARE @found INT

  -- checks for billing cycle relative discounts
	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
	FROM t_pl_map plm 
	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template
  INNER JOIN t_discount disc ON disc.id_prop = bp.id_prop
	WHERE 
    plm.id_po = @id_po AND
    disc.id_usage_cycle IS NULL

  IF @found = 1
	  RETURN @found

  -- checks for billing cycle relative recurring charges
	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
	FROM t_pl_map plm 
	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template
  INNER JOIN t_recur rc ON rc.id_prop = bp.id_prop
	WHERE 
    plm.id_po = @id_po AND
    (rc.tx_cycle_mode = 'BCR' OR rc.tx_cycle_mode = 'BCR Constrained')

  IF @found = 1
	  RETURN @found

  -- checks for billing cycle relative aggregate charges
	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
	FROM t_pl_map plm 
	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template
  INNER JOIN t_aggregate agg ON agg.id_prop = bp.id_prop
	WHERE 
    plm.id_po = @id_po AND
    agg.id_usage_cycle IS NULL

  RETURN @found
END
	