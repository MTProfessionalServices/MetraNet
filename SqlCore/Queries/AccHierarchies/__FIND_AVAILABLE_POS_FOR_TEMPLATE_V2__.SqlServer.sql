
select distinct
  bp.id_prop,
  bp.n_name,
  bp.n_desc,
  bp.n_display_name,
  bp.nm_name,
  COALESCE(tvbp.nm_desc, bp.nm_desc) nm_desc,
  COALESCE(tvbp.nm_display_name, bp.nm_display_name) nm_display_name,
  b_user_subscribe, b_user_unsubscribe, 
  availdt.id_eff_date Available_Id,
  availdt.n_begintype Available_BeginType,
  availdt.dt_start Available_StartDate,
  availdt.n_beginoffset Available_BeginOffset,
  availdt.n_endtype Available_EndType,
  availdt.dt_end Available_EndDate,
  availdt.n_endoffset Available_EndOffset
from t_base_props bp
	INNER JOIN t_po on bp.id_prop = t_po.id_po
	inner join t_effectivedate availdt on t_po.id_avail = availdt.id_eff_date
	INNER JOIN t_pl_map tplm on ((tplm.id_po = t_po.id_po) AND (tplm.id_pricelist IS NOT NULL))
	INNER JOIN t_pricelist tpl on tpl.id_pricelist = tplm.id_pricelist
	/* Check that the entire availability date range for the PO */
	/* is covered by %%CORPORATEACCOUNT%% payers with same currency as PO. This is needed instead of */
  /* checking currency directly on @id_acc because it could be NULL  */
  /* in case of non payer accounts. Old check will be automatically taken care of */
  /* by self pointer in t_payment_redirection table */
  inner join
  (
	SELECT c_Currency as PayerCurrency, po.id_PO as POid
    FROM t_po po
    inner join t_pricelist pl1 on pl1.id_pricelist = po.id_nonshared_pl
    inner join t_payment_redirection pr ON pr.id_payee = %%CORPORATEACCOUNT%%
    left outer join t_av_internal tav ON tav.id_acc = pr.id_payer AND %%CURRENCYFILTER1%%  /* pl1.nm_currency_code = tav.c_Currency */
    inner join t_effectivedate avail on avail.id_eff_date = po.id_avail
   where 
    tav.c_Currency IS NOT NULL
    /* make sure that there are no payers with currencies different from pricelist */
		/* within the boundaries of PO availability date */
		OR
		(tav.c_Currency IS NULL AND
		((pr.vt_start < avail.dt_start) OR (pr.vt_start > avail.dt_end)) AND 
		((pr.vt_end < avail.dt_start) OR (pr.vt_end > avail.dt_end)))
	GROUP BY c_Currency, po.id_PO
	)
  tmp ON %%CURRENCYFILTER4%%  /* tmp.PayerCurrency = tpl.nm_currency_code */  AND POid = t_po.id_PO
	/* INNER JOIN t_av_internal tavi on tavi.id_acc = %%CORPORATEACCOUNT%% */
	INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_avail AND
	      ((te.dt_end IS NOT NULL AND %%REFDATE%% between te.dt_start AND te.dt_end) or (te.dt_end IS NULL AND %%REFDATE%% >= te.dt_start))
   /* CR 13508 make sure that PO is either wide open or allows template account type */
  LEFT OUTER JOIN t_acc_template at ON id_folder = %%FOLDERACCOUNT%% and id_acc_type = %%ACCOUNT_TYPE%%
  LEFT OUTER JOIN t_po_account_type_map atm ON t_po.id_po = atm.id_po
  LEFT OUTER JOIN t_acc_tmpl_types tp ON tp.id = 1
  LEFT OUTER JOIN t_vw_base_props tvbp ON tvbp.id_prop = bp.id_prop AND tvbp.id_lang_code = %%ID_LANG%%
  where bp.n_kind = 100
/*  
  AND t_po.id_po not in 
  (
    select id_po from t_acc_template_subs_pub ats where ats.id_acc_template = at.id_acc_template and id_group is null
  )

  AND t_po.id_po not in 
  (
    select sub.id_po 
    from t_acc_template_subs_pub asub
    inner join t_group_sub gs on asub.id_group = gs.id_group
    inner join t_sub sub on sub.id_group = gs.id_group
    where asub.id_acc_template = at.id_acc_template
    and asub.id_group is not null
  )   
*/
  AND tpl.nm_currency_code  = tpl.nm_currency_code
 
  AND (atm.id_account_type IS NULL OR atm.id_account_type = %%ACCOUNT_TYPE%% OR tp.all_types = 1)
  
  %%PARTITIONFILTER%%
		