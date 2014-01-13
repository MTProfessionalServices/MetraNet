
	select
	/*  __GET_AJ_BYACCOUNTALLPRODUCTS__ */
	s1.id_descendent as AccountId,
	s1.vt_start as AccountStart,
	s1.vt_end as AccountEnd,
	SUM({fn IFNULL(au.Amount, 0.0)}) as TotalAmount,
	SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustmentAmount,
  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustedAmount,
	SUM({fn IFNULL(au.Tax_Federal, 0.0)}) as TotalFederalTax,
	SUM({fn IFNULL(au.Tax_State, 0.0)}) as TotalStateTax,
	SUM({fn IFNULL(au.Tax_County, 0.0)}) as TotalCountyTax,
  SUM({fn IFNULL(au.Tax_Local, 0.0)}) as TotalLocalTax,
	SUM({fn IFNULL(au.Tax_Other, 0.0)}) as TotalOtherTax,
	SUM({fn IFNULL(au.Tax_Federal,0.0)}) + SUM({fn IFNULL(au.Tax_State,0.0)}) + SUM({fn IFNULL(au.Tax_County,0.0)}) + SUM({fn IFNULL(au.Tax_Local,0.0)}) + SUM({fn IFNULL(au.Tax_Other,0.0)}) as TotalTax,
	COUNT(*) as NumTransactions,
  au.am_currency as Currency
	from
	t_account_ancestor s1 
	inner join t_account_ancestor d1 on s1.id_descendent=d1.id_ancestor
	inner join vw_mps_acc_mapper mapd1 on d1.id_ancestor=mapd1.id_acc
	/* Join usage to the originator in effect when the usage was generated. */

	inner join t_acc_usage au on d1.id_descendent=au.id_payee and d1.vt_start <= au.dt_session and d1.vt_end >= au.dt_session and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session 
	inner join vw_adjustment_details ajdetails on au.id_sess = ajdetails.id_sess
	where
  /* Calculate the summary over each account that was a descendent
	 during any part of the report interval */
	d1.num_generations >= 0 
	and
	d1.vt_start <= %%DT_END%% and d1.vt_end >= %%DT_BEGIN%%
	/* Calculate a summary for each child that was beneath me
	 at any time during the report interval (have to handle both
	 usage interval an date range cases!) */
	and
	s1.id_ancestor= %%ID_ACC%% and s1.num_generations between 0 and 1
	and
	s1.vt_start <= %%DT_END%% and s1.vt_end >= %%DT_BEGIN%%
	/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
	 should take care of this with a composite time slice. */
	and %%DT_BEGIN%% <= au.dt_session and %%DT_END%% >= au.dt_session
	/* next clause is not needed for adjustments because: 
	 1. non-prodcat usage is not adjustable (pi_type_props.n_kind IS NULL)
	 2. aggregates are only post bill adjustable (pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data)
	 and
	 (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) */
	and 
	%%TIME_PREDICATE%%
	group by
	s1.id_descendent,
	s1.vt_start,
	s1.vt_end,
	au.am_currency
		