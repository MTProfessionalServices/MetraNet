
	select 
	/* __GET_AJ_BYPRODUCTALLACCOUNTS__ */
	SUM({fn IFNULL(au.Amount, 0.0)}) as TotalAmount,
  SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustmentAmount,
  SUM({fn IFNULL(au.Amount, 0.0)}) + SUM({fn IFNULL(ajdetails.PrebillAdjAmt, 0.0)}) as AdjustedAmount,
  au.am_currency as Currency
	from
	t_acc_usage au
	inner join vw_adjustment_details ajdetails on au.id_sess = ajdetails.id_sess
	inner join t_account_ancestor s1 on s1.id_descendent=au.id_payee and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session
	where
	%%TIME_PREDICATE%%
  and
	s1.id_ancestor = %%ID_ACC%% and s1.num_generations >= 0
	and
	s1.vt_start <= %%DT_END%% and s1.vt_end >= %%DT_BEGIN%%
	/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
	 should take care of this with a composite time slice. */
	and %%DT_BEGIN%% <= au.dt_session and %%DT_END%% >= au.dt_session
	GROUP BY
	au.am_currency
