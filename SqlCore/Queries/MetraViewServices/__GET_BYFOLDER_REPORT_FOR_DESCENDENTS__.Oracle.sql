

       begin

       open :result0 for
		select
		/* DATAMART disabled */
		s1.tx_path as HierarchyPath,		
		s1.id_descendent as AccountId,
		s1.vt_start as AccountStart,
		s1.vt_end as AccountEnd,
		mapd1.hierarchydisplayname as AccountName, 
		SUM({fn IFNULL(au.Amount, 0.0)}) as Amount,
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
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE {fn IFNULL(au.CompoundPrebillTotalTaxAdjAmt, 0.0)} END) as PrebillImpliedTaxAdjAmt,
      0.0 as PrebillInformationalTaxAdjAmt,
	  0.0 as PrebillImplInfTaxAdjAmt,
	  
	  SUM({fn IFNULL(au.CompoundPostbillFedTaxAdjAmt, 0.0)}) as PostbillFedTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillStateTaxAdjAmt, 0.0)}) as PostbillStateTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillCntyTaxAdjAmt, 0.0)}) as PostbillCntyTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillLocalTaxAdjAmt, 0.0)}) as PostbillLocalTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillOtherTaxAdjAmt, 0.0)}) as PostbillOtherTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillTotalTaxAdjAmt, 0.0)}) as PostbillTotalTaxAdjAmt,
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE {fn IFNULL(au.CompoundPostbillTotalTaxAdjAmt, 0.0)} END) as PostbillImpliedTaxAdjAmt,
      0.0 as PostbillInformationalTaxAdjAmt,
	  0.0 as PostbillImplInfTaxAdjAmt,
	  
	  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)}) as PrebillAdjustedAmount,
	  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)})
	  + SUM({fn IFNULL(au.CompoundPostbillAdjAmt, 0.0)}) as PostbillAdjustedAmount,
	  SUM(CASE WHEN (au.IsPrebillAdjusted = 'Y' OR au.NumPrebillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPrebillAdjustments,
	  SUM(CASE WHEN (au.IsPostbillAdjusted = 'Y' OR au.NumPostbillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPostbillAdjustments,
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  END) as TotalImpliedTax,
	  SUM(CASE WHEN (au.tax_informational = 'N') THEN 0 ELSE 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  END) as TotalInformationalTax,
	  SUM(CASE WHEN (au.tax_informational = 'Y' AND au.is_implied_tax = 'Y') THEN 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  ELSE 0 END) as TotalImplInfTax,
      COUNT(*) as NumTransactions,
	  au.am_currency as Currency
		from
		t_account_ancestor s1 
		inner join t_account_ancestor d1 on s1.id_descendent=d1.id_ancestor
		inner join vw_mps_acc_mapper mapd1 on d1.id_ancestor=mapd1.id_acc
		/* Join usage to the originator in effect when the usage was generated. */
		inner join vw_aj_info au on d1.id_descendent=au.id_payee and d1.vt_start <= au.dt_session and d1.vt_end >= au.dt_session and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session 
		inner join t_view_hierarchy vh on au.id_view = vh.id_view
		left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
		left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
		inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
		where
	  vh.id_view = vh.id_view_parent
	  and
		/* Calculate the summary over each account that was a descendent
		 during any part of the report interval */
		d1.num_generations >= 0 
		and
		d1.vt_start <= :dtEnd and d1.vt_end >= :dtBegin
		/* Calculate a summary for each child that was beneath me
		 at any time during the report interval (have to handle both
		 usage interval an date range cases!) */
		and
		s1.id_ancestor= :idAcc and s1.num_generations = :numGenerations
		and
		s1.vt_start <= :dtEnd and s1.vt_end >= :dtBegin
		and
		(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) %%LIKE_OR_NOT_LIKE%% '%_TEMP')
		and
		au.id_parent_sess IS NULL
		/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
		 should take care of this with a composite time slice. */
		and :dtBegin <= au.dt_session and :dtEnd >= au.dt_session
		and 
		%%TIME_PREDICATE%%
		group by
		s1.tx_path,
		s1.id_descendent,
		s1.vt_start,
		s1.vt_end,
		mapd1.hierarchydisplayname,
	  au.am_currency
		order by
		AccountName;

       open :result1 for
		select 
		/* DATAMART disabled */
		au.id_payee as AccountId,
		mapd1.hierarchydisplayname as AccountName, 
		COALESCE (bpd2.nm_display_name, po_default_name.nm_name) as ProductOfferingName,
		COALESCE (bp2d2.nm_display_name, pi_type.nm_name) as PriceableItemName,
		pi_type.id_prop as PriceableItemId,
		COALESCE (bp3d2.nm_display_name, pi_type_instance_props.nm_name) as PriceableItemInstanceName,
		COALESCE (descd2.tx_desc, pi_type.nm_name) as ViewName,
		au.id_prod as ProductOfferingId,
		au.id_pi_instance as PriceableItemInstanceId,
		au.id_pi_template as PriceableItemTemplateId,
		CASE pi_type_props.n_kind WHEN 15 THEN 'Y' ELSE 'N' END as IsAggregate,
		au.id_view as ViewId,
		au.am_currency as Currency,
		piTemplated2.id_template_parent as PriceableItemParentId,
		SUM({fn IFNULL(au.Amount, 0.0)}) as Amount,
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
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE {fn IFNULL(au.CompoundPrebillTotalTaxAdjAmt, 0.0)} END) as PrebillImpliedTaxAdjAmt,
      0.0 as PrebillInformationalTaxAdjAmt,
	  0.0 as PrebillImplInfTaxAdjAmt,
	  
	  SUM({fn IFNULL(au.CompoundPostbillFedTaxAdjAmt, 0.0)}) as PostbillFedTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillStateTaxAdjAmt, 0.0)}) as PostbillStateTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillCntyTaxAdjAmt, 0.0)}) as PostbillCntyTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillLocalTaxAdjAmt, 0.0)}) as PostbillLocalTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillOtherTaxAdjAmt, 0.0)}) as PostbillOtherTaxAdjAmt,
	  SUM({fn IFNULL(au.CompoundPostbillTotalTaxAdjAmt, 0.0)}) as PostbillTotalTaxAdjAmt,
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE {fn IFNULL(au.CompoundPostbillTotalTaxAdjAmt, 0.0)} END) as PostbillImpliedTaxAdjAmt,
      0.0 as PostbillInformationalTaxAdjAmt,
	  0.0 as PostbillImplInfTaxAdjAmt,
	  
	  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)}) as PrebillAdjustedAmount,
	  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(au.CompoundPrebillAdjAmt, 0.0)})
	  + SUM({fn IFNULL(au.CompoundPostbillAdjAmt, 0.0)}) as PostbillAdjustedAmount,
	  SUM(CASE WHEN (au.IsPrebillAdjusted = 'Y' OR au.NumPrebillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPrebillAdjustments,
	  SUM(CASE WHEN (au.IsPostbillAdjusted = 'Y' OR au.NumPostbillAdjustedChildren > 0) THEN 1 ELSE 0 END) as NumPostbillAdjustments,
	  SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0 ELSE 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  END) as TotalImpliedTax,
	  SUM(CASE WHEN (au.tax_informational = 'N') THEN 0 ELSE 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  END) as TotalInformationalTax,
	  SUM(CASE WHEN (au.tax_informational = 'Y' AND au.is_implied_tax = 'Y') THEN 
				  ({fn IFNULL(au.Tax_Federal,0.0)} + {fn IFNULL(au.Tax_State,0.0)} + {fn IFNULL(au.Tax_County,0.0)} + {fn IFNULL(au.Tax_Local,0.0)} + {fn IFNULL(au.Tax_Other,0.0)}) 
				  ELSE 0 END) as TotalImplInfTax,
	  COUNT(*) as NumTransactions
		from
		vw_aj_info au
		inner join t_view_hierarchy vh on au.id_view = vh.id_view
		inner join vw_mps_acc_mapper mapd1 on au.id_payee=mapd1.id_acc
		left outer join t_vw_base_props bp2d2 on au.id_pi_template=bp2d2.id_prop and bp2d2.id_lang_code=:idLang
		left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
		left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
		inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
    
		left outer join t_description descd2 on au.id_view=descd2.id_desc and descd2.id_lang_code=:idLang
		left outer join t_base_props pi_type on pi_type.id_prop = au.id_pi_template
    
		left outer join t_vw_base_props bpd2 on au.id_prod=bpd2.id_prop and bpd2.id_lang_code=:idLang
		left outer join t_base_props po_default_name on au.id_prod=po_default_name.id_prop

		left outer join t_vw_base_props bp3d2 on au.id_pi_instance=bp3d2.id_prop and bp3d2.id_lang_code=:idLang
		left outer join t_base_props pi_type_instance_props on pi_type_instance_props.id_prop = au.id_pi_instance       
		where
	  vh.id_view = vh.id_view_parent
	  and
		au.id_payee = :idAcc
		
	/*	and
		d1.vt_start <= :dtEnd and d1.vt_end >= :dtBegin */
		and 
		((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
		and
		(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) %%LIKE_OR_NOT_LIKE%% '%_TEMP')
		/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
		should take care of this with a composite time slice. */
		and :dtBegin <= au.dt_session and :dtEnd >= au.dt_session
		and
		%%TIME_PREDICATE%%
		group by
		au.id_payee,
		mapd1.hierarchydisplayname, 
		/* Dimension 2 properties */
		au.id_prod,
		COALESCE (bpd2.nm_display_name, po_default_name.nm_name),
		COALESCE (bp2d2.nm_display_name, pi_type.nm_name),
		pi_type.id_prop,
		COALESCE (bp3d2.nm_display_name, pi_type_instance_props.nm_name),
		au.id_pi_instance,
		au.id_pi_template,
		piTemplated2.id_template_parent,
		au.id_view,
		COALESCE (descd2.tx_desc, pi_type.nm_name),
		pi_type_props.n_kind,
	  au.am_currency
		order by
		AccountName,
		ProductOfferingName desc,
		piTemplated2.id_template_parent desc,
		ViewName,
		PriceableItemName;

        end;
		  