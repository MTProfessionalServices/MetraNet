
	select 
	/* __GET_AJ_BYACCOUNTBYPRODUCT__ */
	au.id_payee as AccountId,
	SUM({fn IFNULL(au.Amount, 0.0)}) as TotalAmount,
	SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustmentAmount,
  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustedAmount
	from
	t_acc_usage au
	left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
	inner join t_account_ancestor d1 on d1.id_descendent=au.id_payee
	inner join vw_mps_acc_mapper mapd1 on au.id_payee=mapd1.id_acc
	inner join vw_adjustment_details_datamart ajdetails on au.id_sess = ajdetails.id_sess
	where
  d1.id_ancestor = %%ID_ACC%% and d1.num_generations = 0
	and
	d1.vt_start <= %%DT_END%% and d1.vt_end >= %%DT_BEGIN%%
	/* next clause is not needed for adjustments because: 
	 1. non-prodcat usage is not adjustable (pi_type_props.n_kind IS NULL)
	 2. aggregates are only post bill adjustable (pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data)
	 and
	 (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or %%%UPPER%%%(enumd2.nm_enum_data) */
	and %%DT_BEGIN%% <= au.dt_session and %%DT_END%% >= au.dt_session
	/*  %%ID_LANG%% */
	and
	%%TIME_PREDICATE%%
	group by
	au.id_payee
	order by
	au.id_payee
	              