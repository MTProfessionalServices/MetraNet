
-- populates #tmp_acc_amounts, #tmp_prev_balance, #tmp_adjustments for a given @id_interval
-- used by MTSP_INSERTINVOICE and __GET_NON_BILLABLE_ACCOUNTS_WITH_BALANCE__
CREATE  PROCEDURE MTSP_INSERTINVOICE_BALANCES
@id_billgroup int,
@exclude_billable char, -- '1' to only return non-billable accounts, '0' to return all accounts
@id_run int,
@return_code int OUTPUT
AS
BEGIN
DECLARE
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200)
SET NOCOUNT ON
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no

-- Creating bigint id_sess values to set bounds
Declare @id_sess_min bigint
Declare @id_sess_max bigint

select @id_sess_min = min(id_sess), @id_sess_max = max(id_sess) from t_acc_usage with(nolock) 
where id_acc in (select id_acc from t_billgroup_member where id_billgroup = @id_billgroup)
and id_usage_interval = (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = @id_billgroup)


-- populate the driver table with account ids
INSERT INTO #tmp_all_accounts
(id_acc, namespace)
SELECT /*DISTINCT*/
bgm.id_acc,
map.nm_space
	FROM t_billgroup_member bgm
	INNER JOIN t_acc_usage au ON au.id_acc = bgm.id_acc
	INNER JOIN t_account_mapper map with(index(t_account_mapper_idx1))
	ON map.id_acc = au.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

SELECT /*DISTINCT*/
ads.id_acc,
map.nm_space
	FROM vw_adjustment_summary ads
	INNER JOIN t_billgroup_member bgm ON bgm.id_acc = ads.id_acc
	INNER JOIN t_account_mapper map with(index(t_account_mapper_idx1))
	ON map.id_acc = ads.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = @id_billgroup AND
    ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = @id_billgroup)
UNION

  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_billgroup_member bgm on inv.id_acc = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and bgm.id_billgroup = @id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt))  <> 0

-- Populate with accounts that are non-billable but have payers that are billable.
-- in specified billing group
if @exclude_billable = '1'
BEGIN
	INSERT INTO #tmp_all_accounts
	(id_acc, namespace)

	-- Get all payee accounts (for the payers in the given billing group) with usage
	SELECT /*DISTINCT*/
	pr.id_payee,
	map.nm_space
		FROM t_billgroup_member bgm
		INNER JOIN t_payment_redirection pr	ON pr.id_payer = bgm.id_acc
		INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
		INNER JOIN t_account_mapper map	with(index(t_account_mapper_idx1)) ON map.id_acc = au.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

	-- Get all payee accounts (for the payers in the given billing group) with adjustments
	SELECT /*DISTINCT*/
	ads.id_acc,
	map.nm_space
		FROM vw_adjustment_summary ads
		INNER JOIN t_payment_redirection pr	ON pr.id_payee = ads.id_acc
		INNER JOIN t_billgroup_member bgm ON bgm.id_acc = pr.id_payer
		INNER JOIN t_account_mapper map	with(index(t_account_mapper_idx1))ON map.id_acc = ads.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = @id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM #tmp_all_accounts) AND
		ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = @id_billgroup)
	UNION

  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_payment_redirection pr on pr.id_payee  = inv.id_acc
  inner join t_billgroup_member bgm on pr.id_payer = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and pr.id_payee not in (select id_acc from #tmp_all_accounts)
      AND bgm.id_billgroup = @id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt)) <> 0
END

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_acc_amounts with accounts and their invoice amounts
IF (@debug_flag = 1 and @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Begin inserting to the #tmp_acc_amounts table', getutcdate())

-- check if datamarts are being used
-- if no datamarts
-- then...

IF ((SELECT value FROM t_db_values WHERE parameter = N'DATAMART') = 'false')

BEGIN
INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)
SELECT
  RTRIM(ammps.nm_space) namespace,
  au.id_usage_interval id_interval,
  ammps.id_acc,
  avi.c_currency invoice_currency,
  SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Federal,0.0)) ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_State,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_County,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Local,0.0))ELSE 0 END) +
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
	(ISNULL(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,
  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN 
   ISNULL(au.Amount, 0.0) - 
   /*If implied taxes, then taxes are already included, don't add them again */
   ((CASE WHEN (au.is_implied_tax = 'Y') THEN (ISNULL(au.Tax_Federal,0.0) + ISNULL(au.Tax_State,0.0) + 
          ISNULL(au.Tax_County,0.0) + ISNULL(au.Tax_Local,0.0) + ISNULL(au.Tax_Other,0.0)) ELSE 0 END)
/*If informational taxes, then they shouldn't be in the total */
    + (CASE WHEN (au.tax_informational = 'Y') THEN (ISNULL(au.Tax_Federal,0.0) + ISNULL(au.Tax_State,0.0) + 
          ISNULL(au.Tax_County,0.0) + ISNULL(au.Tax_Local,0.0) + ISNULL(au.Tax_Other,0.0)) ELSE 0 END))
		  ELSE 0 END) current_charges,
  CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,
  CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval
FROM  #tmp_all_accounts tmpall
INNER JOIN t_av_internal avi with(READCOMMITTED) ON avi.id_acc = tmpall.id_acc
INNER JOIN t_account_mapper ammps with(index(t_account_mapper_idx1))ON ammps.id_acc = tmpall.id_acc
INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space
	AND ns.tx_typ_space = 'system_mps'
INNER join t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc
INNER join t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                                               FROM t_billgroup
                                               WHERE id_billgroup = @id_billgroup)/*= @id_interval*/
INNER join t_payment_redirection pr with(READCOMMITTED) ON tmpall.id_acc = pr.id_payee
	AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
INNER join t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer
INNER join t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval
        AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE dateadd(s, 1, auipay.dt_effective) END AND uipay.dt_end

LEFT OUTER JOIN
(SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc, 
    au1.id_view, au1.is_implied_tax, au1.tax_informational
FROM t_acc_usage au1
LEFT OUTER JOIN t_pi_template piTemplated2
ON piTemplated2.id_template=au1.id_pi_template
LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data
AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or (enumd2.nm_enum_data) NOT LIKE '%_TEMP')

WHERE au1.id_sess between @id_sess_min and @id_sess_max 
AND au1.id_parent_sess is NULL
AND au1.id_usage_interval IN (SELECT id_usage_interval
                                                 FROM t_billgroup
                                                 WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
AND ((au1.id_pi_template is null and au1.id_parent_sess is null) or (au1.id_pi_template is not null and piTemplated2.id_template_parent is null))
) au ON

	au.id_acc = tmpall.id_acc
-- join with the tables used for calculating the sums
LEFT OUTER JOIN t_view_hierarchy vh
	ON au.id_view = vh.id_view
	AND vh.id_view = vh.id_view_parent
LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess and au.id_usage_interval=pvar.id_usage_interval
LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess and au.id_usage_interval=pvpay.id_usage_interval
-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable


SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
---------------------------------------------------------------

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
select ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
   INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
   FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
   WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)
  /* where adjtrx.id_usage_interval = @id_interval*/

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

ELSE

-- else datamarts are being used.
-- join against t_mv_payer_interval
BEGIN

INSERT INTO #tmp_acc_amounts
  (namespace,
  id_interval,
  id_acc,
  invoice_currency,
  payment_ttl_amt,
  postbill_adj_ttl_amt,
  ar_adj_ttl_amt,
  previous_balance,
  tax_ttl_amt,
  current_charges,
  id_payer,
  id_payer_interval
)

SELECT

  RTRIM(ammps.nm_space) namespace,
  dm.id_usage_interval id_interval,
  tmpall.id_acc, -- changed
  avi.c_currency invoice_currency,
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/Payment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) payment_ttl_amt,
  0, --postbill_adj_ttl_amt
  SUM(CASE WHEN ed.nm_enum_data = 'metratech.com/ARAdjustment' THEN ISNULL(dm.TotalAmount, 0) ELSE 0 END) ar_adj_ttl_amt,
  0, --previous_balance
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
                 AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
           THEN
           (ISNULL(dm.TotalTax,0.0))
           ELSE 0
           END),  --tax_ttl_amt
  SUM(CASE WHEN (ed.nm_enum_data <> 'metratech.com/Payment'
		AND ed.nm_enum_data <> 'metratech.com/ARAdjustment')
		/*Subtract out implied taxes and informational taxes, then add back their intersection, because it would have been subtracted twice*/
        THEN  (ISNULL(dm.TotalAmount, 0.0) - ISNULL(dm.TotalImpliedTax, 0.0) - ISNULL(dm.TotalInformationalTax, 0.0) + ISNULL(dm.TotalImplInfTax, 0.0))
	    ELSE 0
      END) current_charges,
  CASE WHEN avi.c_billable = '0'
       THEN pr.id_payer
       ELSE tmpall.id_acc
       END id_payer,
  CASE WHEN avi.c_billable = '0'
       THEN auipay.id_usage_interval
       ELSE dm.id_usage_interval
       END id_payer_interval

FROM  #tmp_all_accounts tmpall

-- added
INNER JOIN t_av_internal avi
ON avi.id_acc = tmpall.id_acc

-- Select accounts which are of type 'system_mps'
INNER JOIN t_account_mapper ammps with(index(t_account_mapper_idx1))
ON ammps.id_acc = tmpall.id_acc

INNER JOIN t_namespace ns
ON ns.nm_space = ammps.nm_space
   AND ns.tx_typ_space = 'system_mps'

-- Select accounts which belong
-- to the given usage interval
INNER join t_acc_usage_interval aui
ON aui.id_acc = tmpall.id_acc

INNER join t_usage_interval ui
ON aui.id_usage_interval = ui.id_interval
	AND ui.id_interval IN (SELECT id_usage_interval
                           FROM t_billgroup
                           WHERE id_billgroup = @id_billgroup)/*= @id_interval*/

--
INNER join t_payment_redirection pr
ON tmpall.id_acc = pr.id_payee
   AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end

INNER join t_acc_usage_interval auipay
ON auipay.id_acc = pr.id_payer

INNER join t_usage_interval uipay
ON auipay.id_usage_interval = uipay.id_interval
   AND ui.dt_end BETWEEN
     CASE WHEN auipay.dt_effective IS NULL
          THEN uipay.dt_start
          ELSE dateadd(s, 1, auipay.dt_effective)
          END
     AND uipay.dt_end

LEFT OUTER JOIN t_mv_payer_interval dm
ON dm.id_acc = tmpall.id_acc AND dm.id_usage_interval IN (SELECT id_usage_interval
														  FROM t_billgroup
							                              WHERE id_billgroup = @id_billgroup) /*= @id_interval*/
LEFT OUTER JOIN t_enum_data ed
ON dm.id_view = ed.id_enum_data

-- non-join conditions
WHERE
(@exclude_billable = '0' OR avi.c_billable = '0')
GROUP BY  ammps.nm_space, tmpall.id_acc, dm.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

-- populate #tmp_adjustments with postbill and prebill adjustments
INSERT INTO #tmp_adjustments
 ( id_acc,
   PrebillAdjAmt,
   PrebillTaxAdjAmt,
   PostbillAdjAmt,
   PostbillTaxAdjAmt
 )
select ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc,
       ISNULL(PrebillAdjAmt, 0) PrebillAdjAmt,
       ISNULL(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
       ISNULL(PostbillAdjAmt, 0) PostbillAdjAmt,
       ISNULL(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = @id_billgroup AND
   adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = @id_billgroup)

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

END

-- populate #tmp_prev_balance with the previous balance
INSERT INTO #tmp_prev_balance
  (id_acc,
  previous_balance)
SELECT id_acc, CONVERT(DECIMAL(22,10), SUBSTRING(comp,CASE WHEN PATINDEX('%-%',comp) = 0 THEN 10 ELSE PATINDEX('%-%',comp) END,28)) previous_balance
FROM 	(SELECT inv.id_acc,
ISNULL(MAX(CONVERT(CHAR(8),ui.dt_end,112)+
			REPLICATE('0',20-LEN(inv.current_balance)) +
			CONVERT(CHAR,inv.current_balance)),'00000000000') comp
	FROM t_invoice inv
	INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
	INNER JOIN #tmp_all_accounts ON inv.id_acc = #tmp_all_accounts.id_acc
	GROUP BY inv.id_acc) maxdtend

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF (@debug_flag = 1  and @id_run IS NOT NULL)
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
    VALUES (@id_run, 'Debug', 'Invoice-Bal: Completed successfully', getutcdate())

SET @return_code = 0

RETURN 0

FatalError:
  IF @ErrMsg IS NULL
    SET @ErrMsg = 'Invoice-Bal: Stored procedure failed'
  IF (@debug_flag = 1  and @id_run IS NOT NULL)
    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate())

  SET @return_code = -1

  RETURN -1

END
