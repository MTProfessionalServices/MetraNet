
          begin
           
           open :result0 for
			select
			/* DATAMART enabled */
			acc.id_acc as AccountId,
			case when s1.num_generations = 0 then dbo.mtmindate() else acc.vt_start end as AccountStart,
			case when s1.num_generations = 0 then dbo.mtmaxdate() else acc.vt_end end as AccountEnd,
			mapd1.hierarchydisplayname as AccountName,
			SUM({fn IFNULL(TotalAmount,0)}) as Amount,
			SUM({fn IFNULL(TotalFederalTax,0)}) as TotalFederalTax,
			SUM({fn IFNULL(TotalStateTax,0)}) as TotalStateTax,
		SUM({fn IFNULL(TotalCountyTax,0)}) as TotalCountyTax,
			SUM({fn IFNULL(TotalLocalTax,0)}) as TotalLocalTax,
			SUM({fn IFNULL(TotalOtherTax,0)}) as TotalOtherTax,
			SUM({fn IFNULL(TotalTax,0)}) as TotalTax,
			SUM({fn IFNULL(TotalImpliedTax,0)}) as TotalImpliedTax,
			SUM({fn IFNULL(TotalInformationalTax,0)}) as TotalInformationalTax,
			SUM({fn IFNULL(TotalImplInfTax,0)}) as TotalImplInfTax,
			SUM({fn IFNULL(PrebillAdjAmt,0)}) as PrebillAdjAmt,
 			SUM({fn IFNULL(PostbillAdjAmt,0)}) as PostbillAdjAmt,
 			SUM({fn IFNULL(PrebillAdjustedAmount,0)}) as PrebillAdjustedAmount,
			SUM({fn IFNULL(PostbillAdjustedAmount,0)}) as PostbillAdjustedAmount,
 			SUM({fn IFNULL(NumPrebillAdjustments,0)}) as NumPrebillAdjustments,
 			SUM({fn IFNULL(NumPostbillAdjustments,0)}) as NumPostbillAdjustments,
			SUM({fn IFNULL(NumTransactions,0)}) as NumTransactions,
 			au.am_currency as Currency,
 			SUM({fn IFNULL(PrebillFedTaxAdjAmt,0)}) as PrebillFedTaxAdjAmt,
			SUM({fn IFNULL(PrebillStateTaxAdjAmt,0)}) as PrebillStateTaxAdjAmt,
			SUM({fn IFNULL(PrebillCntyTaxAdjAmt,0)}) as PrebillCntyTaxAdjAmt,
			SUM({fn IFNULL(PrebillLocalTaxAdjAmt,0)}) as PrebillLocalTaxAdjAmt,
			SUM({fn IFNULL(PrebillOtherTaxAdjAmt,0)}) as PrebillOtherTaxAdjAmt,
			SUM({fn IFNULL(PrebillTotalTaxAdjAmt,0)}) as PrebillTotalTaxAdjAmt,
			SUM({fn IFNULL(PrebillImpliedTaxAdjAmt,0)}) as PrebillImpliedTaxAdjAmt,
			SUM({fn IFNULL(PrebillInformationalTaxAdjAmt,0)}) as PrebillInformationalTaxAdjAmt,
			SUM({fn IFNULL(PrebillImplInfTaxAdjAmt,0)}) as PrebillImplInfTaxAdjAmt,
			SUM({fn IFNULL(PostbillFedTaxAdjAmt,0)}) as PostbillFedTaxAdjAmt,
			SUM({fn IFNULL(PostbillStateTaxAdjAmt,0)}) as PostbillStateTaxAdjAmt,
			SUM({fn IFNULL(PostbillCntyTaxAdjAmt,0)}) as PostbillCntyTaxAdjAmt,
			SUM({fn IFNULL(PostbillLocalTaxAdjAmt,0)}) as PostbillLocalTaxAdjAmt,
			SUM({fn IFNULL(PostbillOtherTaxAdjAmt,0)}) as PostbillOtherTaxAdjAmt,
			SUM({fn IFNULL(PostbillTotalTaxAdjAmt,0)}) as PostbillTotalTaxAdjAmt,
			SUM({fn IFNULL(PostbillImpliedTaxAdjAmt,0)}) as PostbillImpliedTaxAdjAmt,
			SUM({fn IFNULL(PostbillInformationalTaxAdjAmt,0)}) as PostbillInformationalTaxAdjAmt,
			SUM({fn IFNULL(PostbillImplInfTaxAdjAmt,0)}) as PostbillImplInfTaxAdjAmt
			from
			t_dm_account_ancestor s1 
			inner join t_dm_account_ancestor d1 on s1.id_dm_descendent=d1.id_dm_ancestor
			inner join t_dm_account acc on acc.id_dm_acc=s1.id_dm_descendent
			inner join vw_mps_acc_mapper mapd1 on acc.id_acc=mapd1.id_acc
			/* Join usage to the originator in effect when the usage was generated. */
			inner join t_mv_payee_session au on d1.id_dm_descendent=au.id_dm_acc
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
			/* Calculate a summary for each child that was beneath me
			 at any time during the report interval (have to handle both
			 usage interval an date range cases!) */
			and
			s1.id_dm_ancestor in (
			select id_dm_acc from t_dm_account
			where id_acc=:idAcc
			and vt_start <= :dtEnd and vt_end >= :dtBegin)
			and s1.num_generations = :numGenerations
			and
			(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) %%LIKE_OR_NOT_LIKE%% '%_TEMP')
			/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
			 should take care of this with a composite time slice. */
			and :dtBegin <= au.dt_session and :dtEnd >= au.dt_session
			and 
			%%TIME_PREDICATE%%
			group by
			acc.id_acc,
			case when s1.num_generations = 0 then dbo.mtmindate() else acc.vt_start end,
			case when s1.num_generations = 0 then dbo.mtmaxdate() else acc.vt_end end,
			mapd1.hierarchydisplayname,
 			au.am_currency
			order by
			AccountName;

      open :result1 for
		select
 		/* DATAMART enabled */
		acc.id_acc as AccountId,
		mapd1.hierarchydisplayname as AccountName,
		bpd2.nm_display_name as ProductOfferingName,
		bp2d2.nm_display_name as PriceableItemName,
		bp2d2.id_prop as PriceableItemId,
		bp3d2.nm_display_name as PriceableItemInstanceName,
		descd2.tx_desc as ViewName,
		au.id_prod as ProductOfferingId,
		au.id_pi_instance as PriceableItemInstanceId,
		au.id_pi_template as PriceableItemTemplateId,
		CASE pi_type_props.n_kind WHEN 15 THEN 'Y' ELSE 'N' END as IsAggregate,
		au.id_view as ViewId,
		au.am_currency as Currency,
		piTemplated2.id_template_parent as PriceableItemParentId,
	  SUM({fn IFNULL(TotalAmount, 0.0)}) as Amount,
		SUM({fn IFNULL(TotalFederalTax,0)}) as TotalFederalTax,
		SUM({fn IFNULL(TotalStateTax,0)}) as TotalStateTax,
		SUM({fn IFNULL(TotalCountyTax,0)}) as TotalCountyTax,
		SUM({fn IFNULL(TotalLocalTax,0)}) as TotalLocalTax,
		SUM({fn IFNULL(TotalOtherTax,0)}) as TotalOtherTax,
		SUM({fn IFNULL(TotalTax,0)}) as TotalTax,
        SUM({fn IFNULL(TotalImpliedTax,0)}) as TotalImpliedTax,
		SUM({fn IFNULL(TotalInformationalTax,0)}) as TotalInformationalTax,
		SUM({fn IFNULL(TotalImplInfTax,0)}) as TotalImplInfTax,
		SUM({fn IFNULL(PrebillAdjAmt,0)}) as PrebillAdjAmt,
	  SUM({fn IFNULL(PostbillAdjAmt,0)}) as PostbillAdjAmt,
 		SUM({fn IFNULL(PrebillAdjustedAmount,0)}) as PrebillAdjustedAmount,
		SUM({fn IFNULL(PostbillAdjustedAmount,0)}) as PostbillAdjustedAmount,
 		SUM({fn IFNULL(NumPrebillAdjustments,0)}) as NumPrebillAdjustments,
 		SUM({fn IFNULL(NumPostbillAdjustments,0)}) as NumPostbillAdjustments,
		SUM({fn IFNULL(NumTransactions,0)}) as NumTransactions,
		SUM({fn IFNULL(PrebillFedTaxAdjAmt,0)}) as PrebillFedTaxAdjAmt,
		SUM({fn IFNULL(PrebillStateTaxAdjAmt,0)}) as PrebillStateTaxAdjAmt,
		SUM({fn IFNULL(PrebillCntyTaxAdjAmt,0)}) as PrebillCntyTaxAdjAmt,
		SUM({fn IFNULL(PrebillLocalTaxAdjAmt,0)}) as PrebillLocalTaxAdjAmt,
		SUM({fn IFNULL(PrebillOtherTaxAdjAmt,0)}) as PrebillOtherTaxAdjAmt,
		SUM({fn IFNULL(PrebillTotalTaxAdjAmt,0)}) as PrebillTotalTaxAdjAmt,
		SUM({fn IFNULL(PrebillImpliedTaxAdjAmt,0)}) as PrebillImpliedTaxAdjAmt,
		SUM({fn IFNULL(PrebillInformationalTaxAdjAmt,0)}) as PrebillInformationalTaxAdjAmt,
		SUM({fn IFNULL(PrebillImplInfTaxAdjAmt,0)}) as PrebillImplInfTaxAdjAmt,
		SUM({fn IFNULL(PostbillFedTaxAdjAmt,0)}) as PostbillFedTaxAdjAmt,
		SUM({fn IFNULL(PostbillStateTaxAdjAmt,0)}) as PostbillStateTaxAdjAmt,
		SUM({fn IFNULL(PostbillCntyTaxAdjAmt,0)}) as PostbillCntyTaxAdjAmt,
		SUM({fn IFNULL(PostbillLocalTaxAdjAmt,0)}) as PostbillLocalTaxAdjAmt,
		SUM({fn IFNULL(PostbillOtherTaxAdjAmt,0)}) as PostbillOtherTaxAdjAmt,
		SUM({fn IFNULL(PostbillTotalTaxAdjAmt,0)}) as PostbillTotalTaxAdjAmt,
		SUM({fn IFNULL(PostbillImpliedTaxAdjAmt,0)}) as PostbillImpliedTaxAdjAmt,
		SUM({fn IFNULL(PostbillInformationalTaxAdjAmt,0)}) as PostbillInformationalTaxAdjAmt,
		SUM({fn IFNULL(PostbillImplInfTaxAdjAmt,0)}) as PostbillImplInfTaxAdjAmt
		from
		t_mv_payee_session au
		inner join t_view_hierarchy vh on au.id_view = vh.id_view
		inner join t_dm_account acc on au.id_dm_acc=acc.id_dm_acc
		inner join t_dm_account_ancestor d1 on d1.id_dm_descendent=acc.id_dm_acc
		inner join vw_mps_acc_mapper mapd1 on acc.id_acc=mapd1.id_acc
		left outer join t_vw_base_props bp2d2 on au.id_pi_template=bp2d2.id_prop and bp2d2.id_lang_code=:idLang
		left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
		left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
		inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
		inner join t_description descd2 on au.id_view=descd2.id_desc
		left outer join t_vw_base_props bpd2 on au.id_prod=bpd2.id_prop and bpd2.id_lang_code=:idLang
		left outer join t_vw_base_props bp3d2 on au.id_pi_instance=bp3d2.id_prop and bp3d2.id_lang_code=:idLang
		where
	  vh.id_view = vh.id_view_parent
	  and
		d1.id_dm_ancestor in (
		select id_dm_acc from t_dm_account
		where id_acc=:idAcc
		and vt_start <= :dtEnd and vt_end >= :dtBegin)
		and d1.num_generations = 0
		and
	  descd2.id_lang_code=:idLang
		and
		(pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) %%LIKE_OR_NOT_LIKE%% '%_TEMP')
		/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
		 should take care of this with a composite time slice. */
		and :dtBegin <= au.dt_session and :dtEnd >= au.dt_session
		and
		%%TIME_PREDICATE%%
		and
		%%CURRENCY%%
		group by
		acc.id_acc,
		mapd1.hierarchydisplayname, 
		/* Dimension 2 properties */
		au.id_prod,
		bpd2.nm_display_name,
		bp2d2.nm_display_name,
		bp2d2.id_prop,
		bp3d2.nm_display_name,
		au.id_pi_instance,
		au.id_pi_template,
		piTemplated2.id_template_parent,
		au.id_view,
		descd2.tx_desc,
		pi_type_props.n_kind,
  		au.am_currency
		order by
		AccountName,
		ProductOfferingName desc,
		piTemplated2.id_template_parent desc,
		ViewName,
		PriceableItemName;

       end;
			