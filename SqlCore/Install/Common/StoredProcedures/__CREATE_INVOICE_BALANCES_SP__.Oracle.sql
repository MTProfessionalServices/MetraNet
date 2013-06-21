
/*  populates tmp_acc_amounts, tmp_prev_balance, tmp_adjustments for a given @id_interval */
/*  used by MTSP_INSERTINVOICE and __GET_NON_BILLABLE_ACCOUNTS_WITH_BALANCE__ */
CREATE or replace PROCEDURE MTSP_INSERTINVOICE_BALANCES(
  p_id_billgroup int,
  p_exclude_billable char, /* '1' to only return non-billable accounts, '0' to return all accounts */
  p_id_run int,
  p_return_code OUT int )
  AS
  v_debug_flag number(1) :=1; /* yes */
  v_SQLError int;
  v_ErrMsg varchar2(200);
  FatalError exception;
  v_dummy_datamart varchar2(10);
  id_sess_min int;
  id_sess_max int;
BEGIN
    delete from tmp_all_accounts;
    delete from tmp_acc_amounts;
    delete from tmp_prev_balance;
    delete from tmp_invoicenumber;
    delete from tmp_adjustments;    
	
	/* Get Max and Min id_sess values to be used later on the JOIN */
	select min(id_sess), max(id_sess) into id_sess_min, id_sess_max from t_acc_usage 
where id_acc in (select id_acc from t_billgroup_member where id_billgroup = p_id_billgroup)
and id_usage_interval = (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = p_id_billgroup);
    
/*  populate the driver table with account ids  */

begin
  INSERT INTO tmp_all_accounts
     (id_acc,namespace)
SELECT /*DISTINCT*/
bgm.id_acc,
map.nm_space
	FROM t_billgroup_member bgm
	INNER JOIN t_acc_usage au ON au.id_acc = bgm.id_acc
	INNER JOIN t_account_mapper map
	ON map.id_acc = au.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = p_id_billgroup AND
    au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = p_id_billgroup)
  UNION
SELECT /*DISTINCT*/
ads.id_acc,
map.nm_space
	FROM vw_adjustment_summary ads
	INNER JOIN t_billgroup_member bgm ON bgm.id_acc = ads.id_acc
	INNER JOIN t_account_mapper map
	ON map.id_acc = ads.id_acc
	INNER JOIN t_namespace ns
	ON ns.nm_space = map.nm_space
	WHERE ns.tx_typ_space = 'system_mps' AND
	bgm.id_billgroup = p_id_billgroup AND
    ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                     WHERE id_billgroup = p_id_billgroup)
  UNION
  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_billgroup_member bgm on inv.id_acc = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and bgm.id_billgroup = p_id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt))  <> 0;
exception
when others then
  raise FatalError;
end;

begin
/* Populate with accounts that are non-billable but have payers that are billable.
 in specified billing group */
if (p_exclude_billable = '1')
then
	INSERT INTO tmp_all_accounts
	(id_acc, namespace)
	SELECT /*DISTINCT*/
	pr.id_payee,
	map.nm_space
		FROM t_billgroup_member bgm
		INNER JOIN t_payment_redirection pr	ON pr.id_payer = bgm.id_acc
		INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
		INNER JOIN t_account_mapper map	ON map.id_acc = au.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = p_id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM tmp_all_accounts) AND
		au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = p_id_billgroup)
	UNION
	SELECT /*DISTINCT*/
	ads.id_acc,
	map.nm_space
		FROM vw_adjustment_summary ads
		INNER JOIN t_payment_redirection pr	ON pr.id_payee = ads.id_acc
		INNER JOIN t_billgroup_member bgm ON bgm.id_acc = pr.id_payer
		INNER JOIN t_account_mapper map	ON map.id_acc = ads.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
		WHERE ns.tx_typ_space = 'system_mps' AND
		bgm.id_billgroup = p_id_billgroup AND
		pr.id_payee NOT IN (SELECT id_acc FROM tmp_all_accounts) AND
		ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
								WHERE id_billgroup = p_id_billgroup)
	UNION
  select inv.id_acc, inv.namespace from t_invoice inv 
  inner join t_payment_redirection pr on pr.id_payee  = inv.id_acc
  inner join t_billgroup_member bgm on pr.id_payer = bgm.id_acc 
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval  
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and pr.id_payee not in (select id_acc from tmp_all_accounts)
      AND bgm.id_billgroup = p_id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt))  <> 0;
end if;
exception
when others then
  raise FatalError;
end;

/*  populate tmp_acc_amounts with accounts and their invoice amounts */
IF (v_debug_flag = 1 and p_id_run IS NOT NULL) then
  INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'Invoice-Bal: Begin inserting to the tmp_acc_amounts table', dbo.getutcdate) ;
end if;

SELECT value into v_dummy_datamart FROM t_db_values WHERE parameter = N'DATAMART';

if (v_dummy_datamart = 'FALSE' OR v_dummy_datamart = 'false')
then
	begin
		INSERT INTO tmp_acc_amounts
			(TMP_SEQ,
			namespace,
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
		seq_tmp_acc_amounts.NextVal,
		x.namespace,
		x.id_interval,
		x.id_acc,
		x.invoice_currency,
		x.payment_ttl_amt,
		x.postbill_adj_ttl_amt,
		x.ar_adj_ttl_amt,
		x.previous_balance,
		x.tax_ttl_amt,
		x.current_charges,
		x.id_payer,
		x.id_payer_interval
		FROM
	(
			SELECT
			cast(RTRIM(ammps.nm_space) as nvarchar2(40)) namespace,
			au.id_usage_interval id_interval,
			ammps.id_acc,
			avi.c_currency invoice_currency,
			SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE nvl(au.amount,0) END) payment_ttl_amt,
			0 postbill_adj_ttl_amt, /* postbill_adj_ttl_amt */
			SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE nvl(au.amount,0) END) ar_adj_ttl_amt,
			0 previous_balance, /* previous_balance */
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
			(nvl(au.Tax_Federal,0.0)) ELSE 0 END) +
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
			(nvl(au.Tax_State,0.0))ELSE 0 END) +
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
			(nvl(au.Tax_County,0.0))ELSE 0 END) +
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
			(nvl(au.Tax_Local,0.0))ELSE 0 END) +
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
			(nvl(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,
			SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN 
              nvl(au.Amount, 0.0) - 
              /*If implied taxes, then taxes are already included, don't add them again */
              ((CASE WHEN (au.is_implied_tax = 'Y') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0) + 
                  nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) ELSE 0 END)
              /*If informational taxes, then they shouldn't be in the total */
              + (CASE WHEN (au.tax_informational = 'Y') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0) + 
                nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) ELSE 0 END))
		      ELSE 0 END)         
			  current_charges, 
			CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,
			CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval
		FROM  tmp_all_accounts tmpall
		INNER JOIN t_av_internal avi ON avi.id_acc = tmpall.id_acc
		INNER JOIN t_account_mapper ammps ON ammps.id_acc = tmpall.id_acc
		INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space
			AND ns.tx_typ_space = 'system_mps'
		INNER join t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc
		INNER join t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
		AND ui.id_interval IN (SELECT id_usage_interval
																								FROM t_billgroup
																								WHERE id_billgroup = p_id_billgroup)/*= @id_interval*/
		INNER join t_payment_redirection pr ON tmpall.id_acc = pr.id_payee
			AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
		INNER join t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer
		INNER join t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval
						AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE dbo.addsecond(auipay.dt_effective) END AND uipay.dt_end
		LEFT OUTER JOIN
		(SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc, au1.id_view, 
		     au1.is_implied_tax, au1.tax_informational
		FROM t_acc_usage au1
		LEFT OUTER JOIN t_pi_template piTemplated2
		ON piTemplated2.id_template=au1.id_pi_template
		LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
		LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data
		AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
		WHERE au1.id_sess between id_sess_min and id_sess_max 
		AND au1.id_parent_sess is NULL
	AND au1.id_usage_interval IN (SELECT id_usage_interval
																									FROM t_billgroup
																									WHERE id_billgroup = p_id_billgroup) /*= @id_interval*/
		AND ((au1.id_pi_template is null and au1.id_parent_sess is null) or (au1.id_pi_template is not null and piTemplated2.id_template_parent is null))
		) au ON
			au.id_acc = tmpall.id_acc
		/*  join with the tables used for calculating the sums */
		LEFT OUTER JOIN t_view_hierarchy vh
			ON au.id_view = vh.id_view
			AND vh.id_view = vh.id_view_parent
		LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess and au.id_usage_interval=pvar.id_usage_interval
		LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess and au.id_usage_interval=pvpay.id_usage_interval
		/*  non-join conditions */
		WHERE
		(p_exclude_billable = '0' OR avi.c_billable = '0')
		GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable) x;
	end;
else
begin
/* else datamarts are being used. join against t_mv_payer_interval */
      if (table_exists('t_mv_payer_interval')) then
         execute immediate ('INSERT INTO tmp_acc_amounts
                     (tmp_seq, namespace, id_interval, id_acc,
                      invoice_currency, payment_ttl_amt,
                      postbill_adj_ttl_amt, ar_adj_ttl_amt, previous_balance,
                      tax_ttl_amt, current_charges, id_payer,
                      id_payer_interval)
            SELECT seq_tmp_acc_amounts.NEXTVAL, x.namespace, x.id_interval,
                   x.id_acc, x.invoice_currency, x.payment_ttl_amt,
                   x.postbill_adj_ttl_amt, x.ar_adj_ttl_amt,
                   x.previous_balance, x.tax_ttl_amt, x.current_charges,
                   x.id_payer, x.id_payer_interval
              FROM (SELECT   CAST
                                (RTRIM (ammps.nm_space) AS NVARCHAR2 (40)
                                ) namespace,
                             dm.id_usage_interval id_interval, tmpall.id_acc,
                             avi.c_currency invoice_currency,
                             SUM
                                (CASE
                                    WHEN ed.nm_enum_data =
                                                       ''metratech.com/Payment''
                                       THEN NVL (dm.TotalAmount, 0)
                                    ELSE 0
                                 END
                                ) payment_ttl_amt,
                             0 postbill_adj_ttl_amt,
                             SUM
                                (CASE
                                    WHEN ed.nm_enum_data =
                                                  ''metratech.com/ARAdjustment''
                                       THEN NVL (dm.TotalAmount, 0)
                                    ELSE 0
                                 END
                                ) ar_adj_ttl_amt,
                             0 previous_balance,
                             SUM
                                (CASE
                                    WHEN (    ed.nm_enum_data <>
                                                       ''metratech.com/Payment''
                                          AND ed.nm_enum_data <>
                                                  ''metratech.com/ARAdjustment''
                                         )
                                       THEN (NVL (dm.TotalTax,
                                                  0.0
                                                 )
                                            )
                                    ELSE 0
                                 END
                                ) tax_ttl_amt,
                             SUM
                                (CASE
                                    WHEN (    ed.nm_enum_data <>
                                                       ''metratech.com/Payment''
                                          AND ed.nm_enum_data <>
                                                  ''metratech.com/ARAdjustment''
                                         )
                                       THEN (
									   NVL(dm.TotalAmount, 0.0) - NVL(dm.TotalImpliedTax, 0.0) - NVL(dm.TotalInformationalTax, 0.0) + NVL(dm.TotalImplInfTax, 0.0)
                                            )
                                    ELSE 0
                                 END
                                ) current_charges,
                             CASE
                                WHEN avi.c_billable = ''0''
                                   THEN pr.id_payer
                                ELSE tmpall.id_acc
                             END id_payer,
                             CASE
                                WHEN avi.c_billable = ''0''
                                   THEN auipay.id_usage_interval
                                ELSE dm.id_usage_interval
                             END id_payer_interval
                        FROM tmp_all_accounts tmpall INNER JOIN t_av_internal avi ON avi.id_acc =
                                                                                       tmpall.id_acc
                             INNER JOIN t_account_mapper ammps ON ammps.id_acc =
                                                                    tmpall.id_acc
                             INNER JOIN t_namespace ns ON ns.nm_space =
                                                                ammps.nm_space
                                                     AND ns.tx_typ_space =
                                                                  ''system_mps''
                             INNER JOIN t_acc_usage_interval aui ON aui.id_acc =
                                                                      tmpall.id_acc
                             INNER JOIN t_usage_interval ui ON aui.id_usage_interval =
                                                                 ui.id_interval
                                                          AND ui.id_interval IN (
                                                                 SELECT id_usage_interval
                                                                   FROM t_billgroup
                                                                  WHERE id_billgroup = ' || to_char(p_id_billgroup) || ')
                             INNER JOIN t_payment_redirection pr ON tmpall.id_acc =
                                                                      pr.id_payee
                                                               AND ui.dt_end
                                                                      BETWEEN pr.vt_start
                                                                          AND pr.vt_end
                             INNER JOIN t_acc_usage_interval auipay ON auipay.id_acc =
                                                                         pr.id_payer
                             INNER JOIN t_usage_interval uipay ON auipay.id_usage_interval =
                                                                    uipay.id_interval
                                                             AND ui.dt_end
                                                                    BETWEEN CASE
                                                                    WHEN auipay.dt_effective IS NULL
                                                                       THEN uipay.dt_start
                                                                    ELSE dbo.addsecond
                                                                           (auipay.dt_effective
                                                                           )
                                                                 END
                                                                        AND uipay.dt_end
                             LEFT OUTER JOIN t_mv_payer_interval dm
                                             ON dm.id_acc = tmpall.id_acc
                                             AND dm.id_usage_interval IN (SELECT id_usage_interval
                                                                          FROM t_billgroup
                                                                          WHERE id_billgroup =
                                                                          ' || to_char(p_id_billgroup) || ') /*= @id_interval*/
                             LEFT OUTER JOIN t_enum_data ed ON dm.id_view =
                                                                 ed.id_enum_data /*  non-join conditions */
						WHERE ('|| p_exclude_billable ||' = ''0'' OR avi.c_billable = ''0'')
                    GROUP BY ammps.nm_space,
                             tmpall.id_acc,
                             dm.id_usage_interval,
                             avi.c_currency,
                             pr.id_payer,
                             auipay.id_usage_interval,
                             avi.c_billable) x');
      END if;
	end;
end if;

/* populate tmp_adjustments with postbill and prebill adjustments */
begin

/*
  FULL OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc

  Here we're doing a union of two outer joins because FULL outer join seems
  to create and Oracle carsh.
 */

  INSERT INTO tmp_adjustments
   ( id_acc,
     PrebillAdjAmt,
     PrebillTaxAdjAmt,
     PostbillAdjAmt,
     PostbillTaxAdjAmt
   )
  select nvl(adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
         nvl(PrebillAdjAmt, 0) PrebillAdjAmt,
         nvl(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
         nvl(PostbillAdjAmt, 0) PostbillAdjAmt,
         nvl(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  LEFT OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = p_id_billgroup and
     adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = p_id_billgroup)
UNION
  select nvl(adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
         nvl(PrebillAdjAmt, 0) PrebillAdjAmt,
         nvl(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
         nvl(PostbillAdjAmt, 0) PostbillAdjAmt,
         nvl(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  RIGHT OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = p_id_billgroup and
     adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
		                            WHERE id_billgroup = p_id_billgroup);

exception
when others then
  raise FatalError;
end;

/* populate tmp_prev_balance with the previous balance */
begin
  INSERT INTO tmp_prev_balance
    (id_acc,
    previous_balance)
  SELECT id_acc, CAST(SUBSTR(comp,CASE WHEN INSTR(comp,'-') = 0 THEN 10 ELSE INSTR(comp,'-') END,28) as NUMBER(22,10)) previous_balance
  FROM 	(SELECT inv.id_acc,
  nvl(MAX(TO_CHAR(ui.dt_end,'YYYYMMDD')||
        RPAD('0',20-LENGTH(inv.current_balance)) ||
        TO_CHAR(inv.current_balance)),'00000000000') comp
    FROM t_invoice inv
    INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
    INNER JOIN tmp_all_accounts ON inv.id_acc = tmp_all_accounts.id_acc
    GROUP BY inv.id_acc) maxdtend;
exception
when others then
  raise FatalError;
end;

IF (v_debug_flag = 1  and p_id_run IS NOT NULL) then
  INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'Invoice-Bal: Completed successfully', dbo.getutcdate) ;
end if;

p_return_code := 0;
RETURN;
exception
when FatalError then
  IF v_ErrMsg IS NULL then
    v_ErrMsg := 'Invoice-Bal: Stored procedure failed';
  END IF;
  IF (v_debug_flag = 1  and p_id_run IS NOT NULL) then
    INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
  end if;
  p_return_code := -1;
  RETURN;
END;
