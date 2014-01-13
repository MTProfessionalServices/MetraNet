
create function checksubscriptionconflicts (
@id_acc            INT,
@id_po             INT,
@real_begin_date   DATETIME,
@real_end_date     DATETIME,
@id_sub            INT,
@allow_acc_po_curr_mismatch INT = 0,
@allow_multiple_pi_sub_rcnrc INT = 0
)
RETURNS INT
AS
begin
declare @status int
declare @cycle_type int
declare @po_cycle int
declare @conflicting_usagepi_count int


SELECT @status = COUNT (t_sub.id_sub)
FROM t_sub 
WHERE t_sub.id_acc = @id_acc
 AND t_sub.id_po = @id_po
 AND t_sub.id_sub <> @id_sub
 AND dbo.overlappingdaterange (t_sub.vt_start,t_sub.vt_end,@real_begin_date,@real_end_date)= 1
IF (@status > 0)
	begin
 -- MTPCUSER_CONFLICTING_PO_SUBSCRIPTION
  RETURN (-289472485)
	END
select @status = dbo.overlappingdaterange(@real_begin_date,@real_end_date,te.dt_start,te.dt_end)
from t_po
INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
where id_po = @id_po
if (@status <> 1)
	begin
	-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
	return (-289472472)
	end

SELECT @status = COUNT (id_pi_template)
FROM t_pl_map
WHERE 
  t_pl_map.id_po = @id_po AND
  t_pl_map.id_paramtable IS NULL AND
  t_pl_map.id_pi_template IN
           (SELECT id_pi_template
            FROM t_pl_map
            WHERE 
              id_paramtable IS NULL AND
              id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> @id_sub
                            AND subs.id_acc = @id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    @real_begin_date,
                                    @real_end_date
                                 ) = 1))
IF (@status > 0 AND @allow_multiple_pi_sub_rcnrc <> 1)
	BEGIN
		return (-289472484)
	END

IF (@status > 0 AND @allow_multiple_pi_sub_rcnrc = 1)
BEGIN
	-- Check whether conflicting subscription has any Non RC/NRC PIs in it
	SELECT @conflicting_usagepi_count = COUNT (id_pi_template)
	FROM t_pl_map
	JOIN t_base_props bp1 on t_pl_map.id_pi_template = bp1.id_prop 
	WHERE 
	t_pl_map.id_po = @id_po AND
	t_pl_map.id_paramtable IS NULL AND
	bp1.n_kind in (10,40) AND
	t_pl_map.id_pi_template IN
           (SELECT id_pi_template
            FROM t_pl_map
            WHERE 
              id_paramtable IS NULL AND
              id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> @id_sub
                            AND subs.id_acc = @id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    @real_begin_date,
                                    @real_end_date
                                 ) = 1))


	IF @conflicting_usagepi_count > 0
		BEGIN 
			return (-289472484)
		END
END

-- CR 10872: make sure account and po have the same currency

-- BP - actually we need to check if a payer has different currency
-- In Kona we allow non billable accounts to be created with no currency
--if (dbo.IsAccountAndPOSameCurrency(@id_acc, @id_po) = '0')
--If Allow Account PO Currency Mismatch is true then don't execute the following code 

IF @allow_acc_po_curr_mismatch <> 1
BEGIN 

if EXISTS
(
SELECT 1 FROM t_payment_redirection pr
INNER JOIN t_av_internal avi on avi.id_acc = pr.id_payer
INNER JOIN t_po po on  po.id_po = @id_po
INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
WHERE pr.id_payee = @id_acc
AND avi.c_currency <>  pl.nm_currency_code
AND (pr.vt_start <= @real_end_date AND pr.vt_end >= @real_begin_date)
)
begin
	-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
	return (-486604729)
end
END
-- Check for MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
-- BR violation
if
  exists (
    SELECT 1
    FROM  t_account tacc 
    INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
    WHERE tacc.id_acc = @id_acc AND tacctype.b_CanSubscribe = '0'
  )
begin
  return(-289472434) -- MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 
end

-- check that account type of the account is compatible with the product offering
-- since the absense of ANY mappings for the product offering means that PO is "wide open"
-- we need to do 2 EXISTS queries
if
exists (
SELECT 1
FROM t_po_account_type_map atmap 
WHERE atmap.id_po = @id_po
)
--PO is not wide open - see if subscription is permitted for the account type
AND
not exists (
SELECT 1
FROM  t_account tacc 
INNER JOIN t_po_account_type_map atmap on atmap.id_po = @id_po AND atmap.id_account_type = tacc.id_type
 WHERE  tacc.id_acc = @id_acc
)
begin
 return (-289472435) -- MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE
end


RETURN (1)
END
	