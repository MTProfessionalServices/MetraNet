
	select 
	/* __GET_AJ_BYACCOUNTALLPRODUCTSFORPAYER_DATAMART__ */
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
	inner join t_acc_usage au on s1.id_descendent=au.id_payee and s1.vt_start <= au.dt_session and s1.vt_end >= au.dt_session
	inner join vw_adjustment_details_datamart ajdetails on au.id_sess = ajdetails.id_sess
	where
  au.id_acc = %%ID_PAYER%%
	and 
	%%TIME_PREDICATE%%
	and
	s1.id_ancestor = %%ID_ACC%% 
	and
	s1.vt_start <= %%DT_END%% and s1.vt_end >= %%DT_BEGIN%%
	/* HACK: The 0 generation record does not have a valid effective date, therefore we pass it in.  Probably
	 should take care of this with a composite time slice. */
	and %%DT_BEGIN%% <= au.dt_session and %%DT_END%% >= au.dt_session
	GROUP BY
	au.am_currency
