
	select 
	/* __GET_BYACCOUNTBYPRODUCTFORPAYER__
		 DATAMART disabled */
	bpd2.nm_display_name as ProductOfferingName,
	bp2d2.nm_display_name as PriceableItemName,
	bp3d2.nm_display_name as PriceableItemInstanceName,
	descd2.tx_desc as ViewName,
	au.id_prod as ProductOfferingId,
	au.id_pi_instance as PriceableItemInstanceId,
	au.id_pi_template as PriceableItemTemplateId,
	CASE pi_type_props.n_kind WHEN 15 THEN 'Y' ELSE 'N' END as IsAggregate,
	au.id_view as ViewId,
	au.am_currency as Currency,
	piTemplated2.id_template_parent as PriceableItemParentId,
	SUM({fn IFNULL(au.Amount, 0.0)}) as TotalAmount,
	SUM({fn IFNULL(au.Tax_Federal, 0.0)}) as TotalFederalTax,
	SUM({fn IFNULL(au.Tax_State, 0.0)}) as TotalStateTax,
  SUM({fn IFNULL(au.Tax_County, 0.0)}) as TotalCountyTax, 
  SUM({fn IFNULL(au.Tax_Local, 0.0)}) as TotalLocalTax,
  SUM({fn IFNULL(au.Tax_Other, 0.0)}) as TotalOtherTax,
	SUM({fn IFNULL(au.Tax_Federal,0.0)}) + SUM({fn IFNULL(au.Tax_State,0.0)}) + SUM({fn IFNULL(au.Tax_County,0.0)}) + SUM({fn IFNULL(au.Tax_Local,0.0)}) + SUM({fn IFNULL(au.Tax_Other,0.0)}) as TotalTax,
	SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)}) as PrebillAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillAdjAmt, 0.0)}) as PostbillAdjAmt,  
  SUM({fn IFNULL(au.CompoundPrebillFedTaxAdjAmt, 0.0)}) as PrebillFedTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPrebillStateTaxAdjAmt, 0.0)}) as PrebillStateTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPrebillCntyTaxAdjAmt, 0.0)}) as PrebillCntyTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPrebillLocalTaxAdjAmt, 0.0)}) as PrebillLocalTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPrebillOtherTaxAdjAmt, 0.0)}) as PrebillOtherTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPrebillTotalTaxAdjAmt, 0.0)}) as PrebillTotalTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillFedTaxAdjAmt, 0.0)}) as PostbillFedTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillStateTaxAdjAmt, 0.0)}) as PostbillStateTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillCntyTaxAdjAmt, 0.0)}) as PostbillCntyTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillLocalTaxAdjAmt, 0.0)}) as PostbillLocalTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillOtherTaxAdjAmt, 0.0)}) as PostbillOtherTaxAdjAmt,
  SUM({fn IFNULL(au.CompoundPostbillTotalTaxAdjAmt, 0.0)}) as PostbillTotalTaxAdjAmt,  
  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)}) as PrebillAdjustedAmount,
  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)})
  + SUM({fn IFNULL(au.CompoundPostbillAdjAmt, 0.0)}) as PostbillAdjustedAmount,
  SUM(CASE WHEN (au.IsPrebillAdjusted = 'Y' OR au.NumPrebillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPrebillAdjustments,
  SUM(CASE WHEN (au.IsPostbillAdjusted = 'Y' OR au.NumPostbillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPostbillAdjustments,
	COUNT(*) as NumTransactions
	from
	vw_aj_info au
	inner join t_view_hierarchy vh on au.id_view = vh.id_view
	left outer join t_vw_base_props bp2d2 on au.id_pi_template=bp2d2.id_prop and bp2d2.id_lang_code=%%ID_LANG%%
	left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
	left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
	inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
	inner join t_description descd2 on au.id_view=descd2.id_desc
	left outer join t_vw_base_props bpd2 on au.id_prod=bpd2.id_prop and bpd2.id_lang_code=%%ID_LANG%%
	left outer join t_vw_base_props bp3d2 on au.id_pi_instance=bp3d2.id_prop and bp3d2.id_lang_code=%%ID_LANG%%
	inner join t_account_ancestor s1 on s1.id_descendent=au.id_payee and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session
	where
  vh.id_view = vh.id_view_parent
  and
	au.id_acc = %%ID_PAYER%%
	and
	descd2.id_lang_code=%%ID_LANG%%
	and 
	((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
	and
	(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) %%LIKE_OR_NOT_LIKE%% '%_TEMP')
	and
	%%TIME_PREDICATE%%
	and
	s1.id_ancestor = %%ID_ACC%% and s1.num_generations between 0 and 0
	and
	s1.vt_start <= %%DT_END%% and s1.vt_end >= %%DT_BEGIN%%
	/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
	 should take care of this with a composite time slice. */
	and %%DT_BEGIN%% <= au.dt_session and %%DT_END%% >= au.dt_session
	group by
	au.id_prod,
	bpd2.nm_display_name,
	bp2d2.nm_display_name,
	bp3d2.nm_display_name,
	au.id_pi_instance,
	au.id_pi_template,
	piTemplated2.id_template_parent,
	au.id_view,
	descd2.tx_desc,
	pi_type_props.n_kind,
  au.am_currency
	order by
	ProductOfferingName,
	piTemplated2.id_template_parent,
	ViewName,
	PriceableItemName
	