
/* Following variables are used for checking the existence of data before executing script and added for performance reasons to avoid
running the unnecessary code*/
declare 
rowcount number(10);
rowcount1 number(10);
dummy number(10);
dummy1 number(10);

begin
dummy	:= 0;
dummy1	:= 0;
rowcount := 0;
rowcount1 := 0;

/* The following queries will be required for move account */

if (table_exists ('%%DELTA_DELETE_T_DM_ACCOUNT%%') and table_exists ('%%DELTA_INSERT_T_DM_ACCOUNT%%'))
	then
		select count(*) into dummy from %%DELTA_DELETE_T_DM_ACCOUNT%%;
		select count(*) into dummy1 from %%DELTA_INSERT_T_DM_ACCOUNT%%;
		if (dummy > 0 and dummy1 > 0)
		then	
			/* Copying the old MV data to delta_delete table (to be used by all dependents of this MV table) */
			insert into %%DELTA_DELETE_PAYEE_SESSION%%
			SELECT au.* from 
			%%PAYEE_SESSION%% au inner join %%DELTA_DELETE_T_DM_ACCOUNT%% acc on au.id_dm_acc=acc.id_dm_acc
			and au.dt_session between acc.vt_start and acc.vt_end;

			/* Update the MV tables with new changes (required for Move Account) */
			update %%PAYEE_SESSION%% payee set id_dm_acc = (select acc1.id_dm_acc 
			from 
			%%DELTA_DELETE_T_DM_ACCOUNT%% acc 
			inner join %%DELTA_INSERT_T_DM_ACCOUNT%% acc1 on acc.id_acc = acc1.id_acc
			where payee.id_dm_acc= acc.id_dm_acc
			and payee.dt_session between acc.vt_start and acc.vt_end
			and payee.dt_session between acc1.vt_start and acc1.vt_end)
			where exists (select 1 
			from 
			%%DELTA_DELETE_T_DM_ACCOUNT%% acc 
			inner join %%DELTA_INSERT_T_DM_ACCOUNT%% acc1 on acc.id_acc = acc1.id_acc
			where payee.id_dm_acc= acc.id_dm_acc
			and payee.dt_session between acc.vt_start and acc.vt_end
			and payee.dt_session between acc1.vt_start and acc1.vt_end);

			/* Copy the new data to Delta_Insert table (to be used by all dependents of this MV table) */
			insert into %%DELTA_INSERT_PAYEE_SESSION%%
			SELECT au.*
			from %%PAYEE_SESSION%% au inner join %%DELTA_INSERT_T_DM_ACCOUNT%% acc1 on au.id_dm_acc = acc1.id_dm_acc
			and au.dt_session between acc1.vt_start and acc1.vt_end;
		end if;
	end if;
		/* End of moveaccount queries */

dummy	:= 0;
dummy1	:= 0;

/* Cleanup the temporary delta tables */

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session;


/* If we metered data then save the records in temporary table based on t_acc_usage delta table, we are using temp table since 
the code will summarize the adjustments in next steps and then we will insert into MV table based on this temp table */

if table_exists ('%%DELTA_INSERT_T_ACC_USAGE%%')
then
	select count(*) into dummy from %%DELTA_INSERT_T_ACC_USAGE%%;
	if (dummy > 0)
	then
		Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session
		(id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,TotalAmount,
	TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
	TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,PrebillAdjAmt,PrebillFedTaxAdjAmt,
	PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
	PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
    PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,
	PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
	PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
	PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
    PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
    PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments  ,
	NumPostbillAdjustments,NumTransactions)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,
		au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,au.am_currency,au.id_se,trunc(dt_session) as dt_session,
		SUM(nvl(au.Amount, 0.0)) TotalAmount,
		SUM(nvl(au.Tax_Federal, 0.0)) TotalFederalTax,
		SUM(nvl(au.Tax_County, 0.0)),
		SUM(nvl(au.Tax_Local, 0.0)),
		SUM(nvl(au.Tax_Other, 0.0)),
		SUM(nvl(au.Tax_State, 0.0)) TotalStateTax,
		SUM(nvl(au.Tax_Federal, 0.0)) + SUM(nvl(au.Tax_State, 0.0)) + SUM(nvl(au.Tax_County, 0.0)) + 
		SUM(nvl(au.Tax_Local, 0.0)) + SUM(nvl(au.Tax_Other, 0.0)) TotalTax,
		SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0.0 ELSE 
			 (nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) END) TotalImpliedTax,
		SUM(CASE WHEN (au.tax_informational = 'N') THEN 0.0 ELSE 
			(nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) END) TotalInformationalTax,
		SUM(CASE WHEN (au.tax_informational = 'Y' AND au.is_implied_tax = 'Y') THEN  
			(nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) ELSE 0.0 END) TotalImplInfTax,
		cast (0.0 as numeric(38,6)) as PrebillAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillFedTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillCntyTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillLocalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillTotalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillImpliedTaxAdjAmt, cast (0.0 as numeric(38,6)) as PrebillInformationalTaxAdjAmt, cast (0.0 as numeric(38,6)) as PrebillImplInfTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as NumPrebillAdjustments,cast (0.0 as numeric(38,6)) as PostbillAdjAmt,cast (0.0 as numeric(38,6)) as PostbillFedTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillCntyTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillLocalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillTotalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillImpliedTaxAdjAmt, cast (0.0 as numeric(38,6)) as PostbillInformationalTaxAdjAmt, cast (0.0 as numeric(38,6)) as PostbillImplInfTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as NumPostbillAdjustments,
		SUM(nvl(au.Amount,0.0)) PrebillAdjustedAmount,
		SUM(nvl(au.Amount,0.0)) PostbillAdjustedAmount,
		COUNT(*) NumTransactions
		from  %%DELTA_INSERT_T_ACC_USAGE%% au  inner join t_dm_account acc on au.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		where id_parent_sess is null
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(dt_session),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;
		dummy1 := sql%rowcount;
		/* Running the update statistics on the temporary delta table for performance reasons */
		exec_ddl('ANALYZE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session COMPUTE STATISTICS');      
	end if;
end if;

dummy := 0;
	
/* Following code is only executed if we metered adjustments and records exists in adjustment delta table */

if table_exists ('%%DELTA_INSERT_T_ADJUSTMENT_TRANSACTION%%')
then
	select count(*) into dummy from %%DELTA_INSERT_T_ADJUSTMENT_TRANSACTION%%;
	if (dummy > 0)
	then
		exec_ddl ('truncate table %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session');
		Insert into %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
		PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
		NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
		au.am_currency,au.id_se,trunc(au.dt_session),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_federal
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_state
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_county
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_local
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_other
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other)
		ELSE 0 END),
		0,0,0,
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=0)	
		THEN 1 ELSE 0 END) + 
		SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN 1 ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.AdjustmentAmount ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_federal ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_state ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_county ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_local ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_other ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL and billajs.n_adjustmenttype=1) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + 
		billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other) ELSE 0 END),
		0,0,0,
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=1) THEN 1 ELSE 0 END) + 
		SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1)  THEN 1 ELSE 0 END)
		from
		T_ACC_USAGE au1 inner join t_dm_account acc on au1.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		inner join %%DELTA_INSERT_T_ADJUSTMENT_TRANSACTION%% billajs on billajs.id_sess=au1.id_sess AND billajs.c_status = 'A'
		inner join T_ACC_USAGE au on au.id_sess=nvl(au1.id_parent_sess,au1.id_sess)
		where au1.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		and au.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(au.dt_session),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;

		if (dummy1 > 0)
		then
			update %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION dm_1 set (PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,
			PostbillStateTaxAdjAmt,PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,
			NumPostbillAdjustments,NumTransactions) = (select 
			dm_1.PrebillAdjAmt + nvl(tmp2.PrebillAdjAmt, 0.0),
			dm_1.PrebillFedTaxAdjAmt + nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
			dm_1.PrebillStateTaxAdjAmt + nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
			dm_1.PrebillCntyTaxAdjAmt + nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
			dm_1.PrebillLocalTaxAdjAmt + nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
			dm_1.PrebillOtherTaxAdjAmt + nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
			dm_1.PrebillTotalTaxAdjAmt + nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
			dm_1.PrebillImpliedTaxAdjAmt + nvl(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
			dm_1.PrebillInformationalTaxAdjAmt + nvl(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
			dm_1.PrebillImplInfTaxAdjAmt + nvl(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
			dm_1.PostbillAdjAmt + nvl(tmp2.PostbillAdjAmt, 0.0), 
			dm_1.PostbillFedTaxAdjAmt + nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
			dm_1.PostbillStateTaxAdjAmt + nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
			dm_1.PostbillCntyTaxAdjAmt + nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
			dm_1.PostbillLocalTaxAdjAmt + nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
			dm_1.PostbillOtherTaxAdjAmt + nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
			dm_1.PostbillTotalTaxAdjAmt + nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
			dm_1.PostbillImpliedTaxAdjAmt + nvl(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
			dm_1.PostbillInformationalTaxAdjAmt + nvl(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
			dm_1.PostbillImplInfTaxAdjAmt + nvl(tmp2.PostbillImplInfTaxAdjAmt, 0.0),
			dm_1.PrebillAdjustedAmount + nvl(tmp2.PrebillAdjustedAmount, 0.0), 
			dm_1.PostbillAdjustedAmount + nvl(tmp2.PostbillAdjustedAmount, 0.0), 
			dm_1.NumPrebillAdjustments + nvl(tmp2.NumPrebillAdjustments, 0.0), 
			dm_1.NumPostbillAdjustments + nvl(tmp2.NumPostbillAdjustments, 0.0), 
			dm_1.NumTransactions + nvl(tmp2.NumTransactions, 0.0) 
			from  %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session tmp2 
			where dm_1.id_dm_acc=tmp2.id_dm_acc 
			and dm_1.id_acc=tmp2.id_acc 
			and dm_1.id_usage_interval=tmp2.id_usage_interval 
			and dm_1.id_view=tmp2.id_view 
			and dm_1.am_currency=tmp2.am_currency 
			and dm_1.id_se=tmp2.id_se 
			and dm_1.dt_session=tmp2.dt_session
			and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
			and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
			and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
			where exists (select 1
						from  %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session tmp2 
						where dm_1.id_dm_acc=tmp2.id_dm_acc 
						and dm_1.id_acc=tmp2.id_acc 
						and dm_1.id_usage_interval=tmp2.id_usage_interval 
						and dm_1.id_view=tmp2.id_view 
						and dm_1.am_currency=tmp2.am_currency 
						and dm_1.id_se=tmp2.id_se 
						and dm_1.dt_session=tmp2.dt_session
						and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
						and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
						and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
			dummy1 := dummy1 + sql%rowcount;
		else
			Insert into %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION dm_1 
			(
			id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
			NumPrebillAdjustments,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
			PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
			)
			select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			nvl(PrebillAdjAmt, 0.0), nvl(PrebillFedTaxAdjAmt, 0.0), nvl(PrebillStateTaxAdjAmt, 0.0),
							nvl(PrebillCntyTaxAdjAmt, 0.0), nvl(PrebillLocalTaxAdjAmt, 0.0), nvl(PrebillOtherTaxAdjAmt, 0.0), 
							nvl(PrebillTotalTaxAdjAmt, 0.0), nvl(PrebillImpliedTaxAdjAmt, 0.0),
							nvl(PrebillInformationalTaxAdjAmt, 0.0),nvl(PrebillImplInfTaxAdjAmt, 0.0),
							nvl(PrebillAdjustedAmount, 0.0), nvl(NumPrebillAdjustments, 0.0),
							nvl(PostbillAdjAmt, 0.0),nvl(PostbillFedTaxAdjAmt, 0.0), nvl(PostbillStateTaxAdjAmt, 0.0),
							nvl(PostbillCntyTaxAdjAmt, 0.0),nvl(PostbillLocalTaxAdjAmt, 0.0), 
							nvl(PostbillOtherTaxAdjAmt, 0.0),nvl(PostbillTotalTaxAdjAmt, 0.0),nvl(PostbillImpliedTaxAdjAmt, 0.0),
							nvl(PostbillInformationalTaxAdjAmt, 0.0),nvl(PostbillImplInfTaxAdjAmt, 0.0),
							nvl(PostbillAdjustedAmount, 0.0),nvl(NumPostbillAdjustments, 0.0)
							from  %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session;
			dummy1 := dummy1 + sql%rowcount;
		end if;			

		Insert into %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		)
		select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		from
		%%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session tmp2 where not exists 
					(select 1 from %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION dm_1 where 
					dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
					dummy1 := dummy1 + sql%rowcount;
	end if;
end if;

dummy := 0;

/* Following code is only executed if we metered usage and set the dummy1 to non-zero value */

if (dummy1 > 0)
then
	/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table,These delta_delete 
	   and delta_insert tables will be used by MV depending on payee_session and currently payer_interval depends on payee_session */
	insert into %%DELTA_DELETE_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
	inner join %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION tmp2 
				on dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
	rowcount := sql%rowcount;

	if (rowcount > 0)
	then
	update %%PAYEE_SESSION%% dm_1 set (TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
	TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
	PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
	PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
    PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,
	PostbillStateTaxAdjAmt,PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
	PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
    PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,
	NumPostbillAdjustments,NumTransactions) = (select
	nvl(dm_1.TotalAmount,0.0) + nvl(tmp2.TotalAmount, 0.0),
	nvl(dm_1.TotalFederalTax,0.0) + nvl(tmp2.TotalFederalTax, 0.0),
	nvl(dm_1.TotalCountyTax,0.0) + nvl(tmp2.TotalCountyTax, 0.0),
	nvl(dm_1.TotalLocalTax,0.0) + nvl(tmp2.TotalLocalTax, 0.0),
	nvl(dm_1.TotalOtherTax,0.0) + nvl(tmp2.TotalOtherTax, 0.0),
	nvl(dm_1.TotalStateTax,0.0) + nvl(tmp2.TotalStateTax, 0.0),
	nvl(dm_1.TotalTax,0.0) + nvl(tmp2.TotalTax, 0.0), 
	nvl(dm_1.TotalImpliedTax,0.0) + nvl(tmp2.TotalImpliedTax, 0.0), 
	nvl(dm_1.TotalInformationalTax,0.0) + nvl(tmp2.TotalInformationalTax, 0.0), 
	nvl(dm_1.TotalImplInfTax,0.0) + nvl(tmp2.TotalImplInfTax, 0.0), 
	dm_1.PrebillAdjAmt + nvl(tmp2.PrebillAdjAmt, 0.0),
				dm_1.PrebillFedTaxAdjAmt + nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
				dm_1.PrebillStateTaxAdjAmt + nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
				dm_1.PrebillCntyTaxAdjAmt + nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
				dm_1.PrebillLocalTaxAdjAmt + nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
				dm_1.PrebillOtherTaxAdjAmt + nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
				dm_1.PrebillTotalTaxAdjAmt + nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
				dm_1.PrebillImpliedTaxAdjAmt + nvl(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
				dm_1.PrebillInformationalTaxAdjAmt + nvl(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
				dm_1.PrebillImplInfTaxAdjAmt + nvl(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
				dm_1.PostbillAdjAmt + nvl(tmp2.PostbillAdjAmt, 0.0), 
				dm_1.PostbillFedTaxAdjAmt + nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
				dm_1.PostbillStateTaxAdjAmt + nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
				dm_1.PostbillCntyTaxAdjAmt + nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
				dm_1.PostbillLocalTaxAdjAmt + nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
				dm_1.PostbillOtherTaxAdjAmt + nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
				dm_1.PostbillTotalTaxAdjAmt + nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
				dm_1.PostbillImpliedTaxAdjAmt + nvl(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
				dm_1.PostbillInformationalTaxAdjAmt + nvl(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
				dm_1.PostbillImplInfTaxAdjAmt + nvl(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
				dm_1.PrebillAdjustedAmount + nvl(tmp2.PrebillAdjustedAmount, 0.0), 
				dm_1.PostbillAdjustedAmount + nvl(tmp2.PostbillAdjustedAmount, 0.0), 
				dm_1.NumPrebillAdjustments + nvl(tmp2.NumPrebillAdjustments, 0.0), 
				dm_1.NumPostbillAdjustments + nvl(tmp2.NumPostbillAdjustments, 0.0), 
				dm_1.NumTransactions + nvl(tmp2.NumTransactions, 0.0) 
				from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
				where dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
	where exists (select 1
				from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
				where dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0)); 
			    
		insert into %%DELTA_INSERT_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
		inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
					on dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
	end if;

	/* Add the new rows into the MV table from the %%%NETMETERSTAGE_PREFIX%%%summary delta table and keep all the changes in MV delta_insert table */
	insert into %%DELTA_INSERT_PAYEE_SESSION%% 
	(id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
	TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
	TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
	PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
	PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
    PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
	PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
	PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
	PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
    PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions)
	Select 
	id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
	TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
	TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
	PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
	PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
    PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
	PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
	PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
	PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
    PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
	from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
		where not exists 
				(select 1 from %%PAYEE_SESSION%% dm_1 
				where dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
	rowcount := sql%rowcount;

	if (rowcount > 0)
	then
		Insert into %%PAYEE_SESSION%%
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
		TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
	    PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
	    PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
		)
		select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		nvl(TotalAmount,0),nvl(TotalFederalTax,0),nvl(TotalCountyTax,0),nvl(TotalLocalTax,0),nvl(TotalOtherTax,0),
		nvl(TotalStateTax,0),nvl(TotalTax,0),nvl(TotalImpliedTax,0),nvl(TotalInformationalTax,0),nvl(TotalImplInfTax,0),PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
		PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
		from
		%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 where not exists 
					(select 1 from %%PAYEE_SESSION%% dm_1 
					where dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
	end if;

end if;

dummy	:= 0;
dummy1	:= 0;

/* Cleanup the temporary delta delete table*/
delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session;

/* Following code is checking if we have backout usage and store the records in temporary delta insert table based on delta delete t_acc_usage */

if table_exists ('%%DELTA_DELETE_T_ACC_USAGE%%')
then
	select count(*) into dummy from %%DELTA_DELETE_T_ACC_USAGE%%;
	if (dummy > 0)
	then
		Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session
		(id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
		TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
	    PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
	    PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,
		au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,au.am_currency,au.id_se,trunc(dt_session) as dt_session,
		SUM(nvl(au.Amount, 0.0)) TotalAmount,
		SUM(nvl(au.Tax_Federal, 0.0)) TotalFederalTax,
		SUM(nvl(au.Tax_County, 0.0)),
		SUM(nvl(au.Tax_Local, 0.0)),
		SUM(nvl(au.Tax_Other, 0.0)),
		SUM(nvl(au.Tax_State, 0.0)) TotalStateTax,
		SUM(nvl(au.Tax_Federal, 0.0)) + SUM(nvl(au.Tax_State, 0.0)) + SUM(nvl(au.Tax_County, 0.0)) + 
		SUM(nvl(au.Tax_Local, 0.0)) + SUM(nvl(au.Tax_Other, 0.0)) TotalTax,
		SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0.0 ELSE 
			 (nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) END) TotalImpliedTax,
		SUM(CASE WHEN (au.tax_informational = 'N') THEN 0.0 ELSE 
			(nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) END) TotalInformationalTax,
		SUM(CASE WHEN (au.tax_informational = 'Y' AND au.is_implied_tax = 'Y') THEN  
			(nvl(au.Tax_Federal, 0.0) + nvl(au.Tax_State, 0.0) + nvl(au.Tax_County, 0.0) + 
			  nvl(au.Tax_Local, 0.0) + nvl(au.Tax_Other, 0.0)) else 0.0 END) TotalImplInfTax,
		cast (0.0 as numeric(38,6)) as PrebillAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillFedTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillCntyTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillLocalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillTotalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillImpliedTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillInformationalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillImplInfTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as NumPrebillAdjustments,cast (0.0 as numeric(38,6)) as PostbillAdjAmt,cast (0.0 as numeric(38,6)) as PostbillFedTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillCntyTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillLocalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillTotalTaxAdjAmt,cast (0.0 as numeric(38,6)) as NumPostbillAdjustments,
		cast (0.0 as numeric(38,6)) as PostbillImpliedTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillInformationalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillImplInfTaxAdjAmt,
		SUM(nvl(au.Amount,0.0)) PrebillAdjustedAmount,
		SUM(nvl(au.Amount,0.0)) PostbillAdjustedAmount,
		COUNT(*) NumTransactions
		from %%DELTA_DELETE_T_ACC_USAGE%% au  inner join t_dm_account acc on au.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		where id_parent_sess is null
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(dt_session),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;
		dummy1 := sql%rowcount;
		exec_ddl('ANALYZE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session COMPUTE STATISTICS');      
	end if;
end if;

dummy := 0;

/* Following code is only executed if we deleted adjustments and records exists in adjustment delta delete table */

if table_exists ('%%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%')
then
	select count(*) into dummy from %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%;
	if (dummy > 0)
	then
		exec_ddl ('truncate table %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session');
		Insert into %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
		PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
		NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
		au.am_currency,au.id_se,trunc(au.dt_session),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_federal
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_state
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_county
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_local
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_other
		ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other)
		ELSE 0 END),
		0,0,0,
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=0)	
		THEN 1 ELSE 0 END) + 
		SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN 1 ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.AdjustmentAmount ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_federal ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_state ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_county ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_local ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_other ELSE 0 END),
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL and billajs.n_adjustmenttype=1) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + 
		billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other) ELSE 0 END),
		0,0,0,
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=1) THEN 1 ELSE 0 END) + 
		SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1)  THEN 1 ELSE 0 END)
		from
		T_ACC_USAGE au1 inner join t_dm_account acc on au1.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		inner join %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% billajs on billajs.id_sess=au1.id_sess AND billajs.c_status = 'A'
		inner join T_ACC_USAGE au on au.id_sess=nvl(au1.id_parent_sess,au1.id_sess)
		where au1.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		and au.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(au.dt_session),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;

		if (dummy1 > 0)
		then
			update %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session dm_1 set (PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,
			PostbillStateTaxAdjAmt,PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
			PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,
			NumPostbillAdjustments,NumTransactions) = (select 
			dm_1.PrebillAdjAmt + nvl(tmp2.PrebillAdjAmt, 0.0),
						dm_1.PrebillFedTaxAdjAmt + nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
						dm_1.PrebillStateTaxAdjAmt + nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
						dm_1.PrebillCntyTaxAdjAmt + nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
						dm_1.PrebillLocalTaxAdjAmt + nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
						dm_1.PrebillOtherTaxAdjAmt + nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
						dm_1.PrebillTotalTaxAdjAmt + nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
						dm_1.PrebillImpliedTaxAdjAmt + nvl(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
						dm_1.PrebillInformationalTaxAdjAmt + nvl(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
						dm_1.PrebillImplInfTaxAdjAmt + nvl(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
						dm_1.PostbillAdjAmt + nvl(tmp2.PostbillAdjAmt, 0.0), 
						dm_1.PostbillFedTaxAdjAmt + nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
						dm_1.PostbillStateTaxAdjAmt + nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
						dm_1.PostbillCntyTaxAdjAmt + nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
						dm_1.PostbillLocalTaxAdjAmt + nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
						dm_1.PostbillOtherTaxAdjAmt + nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
						dm_1.PostbillTotalTaxAdjAmt + nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
						dm_1.PostbillImpliedTaxAdjAmt + nvl(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
						dm_1.PostbillInformationalTaxAdjAmt + nvl(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
						dm_1.PostbillImplInfTaxAdjAmt + nvl(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
						dm_1.PrebillAdjustedAmount + nvl(tmp2.PrebillAdjustedAmount, 0.0), 
						dm_1.PostbillAdjustedAmount + nvl(tmp2.PostbillAdjustedAmount, 0.0), 
						dm_1.NumPrebillAdjustments + nvl(tmp2.NumPrebillAdjustments, 0.0), 
						dm_1.NumPostbillAdjustments + nvl(tmp2.NumPostbillAdjustments, 0.0), 
						dm_1.NumTransactions + nvl(tmp2.NumTransactions, 0.0) 
						from  %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session tmp2 
						where dm_1.id_dm_acc=tmp2.id_dm_acc 
						and dm_1.id_acc=tmp2.id_acc 
						and dm_1.id_usage_interval=tmp2.id_usage_interval 
						and dm_1.id_view=tmp2.id_view 
						and dm_1.am_currency=tmp2.am_currency 
						and dm_1.id_se=tmp2.id_se 
						and dm_1.dt_session=tmp2.dt_session
						and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
						and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
						and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
						where exists (select 1
						from  %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session tmp2 
						where dm_1.id_dm_acc=tmp2.id_dm_acc 
						and dm_1.id_acc=tmp2.id_acc 
						and dm_1.id_usage_interval=tmp2.id_usage_interval 
						and dm_1.id_view=tmp2.id_view 
						and dm_1.am_currency=tmp2.am_currency 
						and dm_1.id_se=tmp2.id_se 
						and dm_1.dt_session=tmp2.dt_session
						and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
						and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
						and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
						dummy1 := dummy1 + sql%rowcount;
		else
			Insert into %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION dm_1 
			(
			id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
			NumPrebillAdjustments,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
			PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
			)
			select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			nvl(PrebillAdjAmt, 0.0), nvl(PrebillFedTaxAdjAmt, 0.0), nvl(PrebillStateTaxAdjAmt, 0.0),
							nvl(PrebillCntyTaxAdjAmt, 0.0), nvl(PrebillLocalTaxAdjAmt, 0.0), nvl(PrebillOtherTaxAdjAmt, 0.0), 
							nvl(PrebillTotalTaxAdjAmt, 0.0), nvl(PrebillImpliedTaxAdjAmt, 0.0),
							nvl(PrebillInformationalTaxAdjAmt, 0.0),nvl(PrebillImplInfTaxAdjAmt, 0.0),
							nvl(PrebillAdjustedAmount, 0.0), nvl(NumPrebillAdjustments, 0.0),
							nvl(PostbillAdjAmt, 0.0),nvl(PostbillFedTaxAdjAmt, 0.0), nvl(PostbillStateTaxAdjAmt, 0.0),
							nvl(PostbillCntyTaxAdjAmt, 0.0),nvl(PostbillLocalTaxAdjAmt, 0.0), 
							nvl(PostbillOtherTaxAdjAmt, 0.0),nvl(PostbillTotalTaxAdjAmt, 0.0),nvl(PostbillImpliedTaxAdjAmt, 0.0),
							nvl(PostbillInformationalTaxAdjAmt, 0.0),nvl(PostbillImplInfTaxAdjAmt, 0.0),
							nvl(PostbillAdjustedAmount, 0.0),nvl(NumPostbillAdjustments, 0.0)
							from  %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session;
			dummy1 := dummy1 + sql%rowcount;
		end if;
		
		Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
			NumPrebillAdjustments,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
			PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		)
		select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
            PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,
			NumPrebillAdjustments,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
			PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
            PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		from
		%%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session tmp2 where not exists 
					(select 1 from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session dm_1 where 
					dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
		dummy1 := dummy1 + sql%rowcount;

	end if;
end if;

dummy := 0;

/* Following code is only executed if we backout usage, dummy1 is set to non-zero value*/

if (dummy1 > 0)
then
	/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table */
	insert into %%DELTA_DELETE_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
	inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
				on dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
	rowcount1 := sql%rowcount;

	if (rowcount1 > 0)
	then
		update %%PAYEE_SESSION%% dm_1 set (TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
		TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
		PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
		PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,
		PostbillStateTaxAdjAmt,PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,
		NumPostbillAdjustments,NumTransactions) = (select
		nvl(dm_1.TotalAmount,0.0) - nvl(tmp2.TotalAmount, 0.0),
		nvl(dm_1.TotalFederalTax,0.0) - nvl(tmp2.TotalFederalTax, 0.0),
		nvl(dm_1.TotalCountyTax,0.0) - nvl(tmp2.TotalCountyTax, 0.0),
		nvl(dm_1.TotalLocalTax,0.0) - nvl(tmp2.TotalLocalTax, 0.0),
		nvl(dm_1.TotalOtherTax,0.0) - nvl(tmp2.TotalOtherTax, 0.0),
		nvl(dm_1.TotalStateTax,0.0) - nvl(tmp2.TotalStateTax, 0.0),
		nvl(dm_1.TotalTax,0.0) - nvl(tmp2.TotalTax, 0.0), 
		nvl(dm_1.TotalImpliedTax,0.0) - nvl(tmp2.TotalImpliedTax, 0.0), 
		nvl(dm_1.TotalInformationalTax,0.0) - nvl(tmp2.TotalInformationalTax, 0.0), 
		nvl(dm_1.TotalImplInfTax,0.0) - nvl(tmp2.TotalImplInfTax, 0.0), 
		dm_1.PrebillAdjAmt - nvl(tmp2.PrebillAdjAmt, 0.0),
					dm_1.PrebillFedTaxAdjAmt - nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
					dm_1.PrebillStateTaxAdjAmt - nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
					dm_1.PrebillCntyTaxAdjAmt - nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
					dm_1.PrebillLocalTaxAdjAmt - nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
					dm_1.PrebillOtherTaxAdjAmt - nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
					dm_1.PrebillTotalTaxAdjAmt - nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
					dm_1.PrebillImpliedTaxAdjAmt - nvl(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
					dm_1.PrebillInformationalTaxAdjAmt - nvl(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
					dm_1.PrebillImplInfTaxAdjAmt - nvl(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
					dm_1.PostbillAdjAmt - nvl(tmp2.PostbillAdjAmt, 0.0), 
					dm_1.PostbillFedTaxAdjAmt - nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
					dm_1.PostbillStateTaxAdjAmt - nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
					dm_1.PostbillCntyTaxAdjAmt - nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
					dm_1.PostbillLocalTaxAdjAmt - nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
					dm_1.PostbillOtherTaxAdjAmt - nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
					dm_1.PostbillTotalTaxAdjAmt - nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
					dm_1.PostbillImpliedTaxAdjAmt - nvl(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
					dm_1.PostbillInformationalTaxAdjAmt - nvl(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
					dm_1.PostbillImplInfTaxAdjAmt - nvl(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
					dm_1.PrebillAdjustedAmount - nvl(tmp2.PrebillAdjustedAmount, 0.0), 
					dm_1.PostbillAdjustedAmount - nvl(tmp2.PostbillAdjustedAmount, 0.0), 
					dm_1.NumPrebillAdjustments - nvl(tmp2.NumPrebillAdjustments, 0.0), 
					dm_1.NumPostbillAdjustments - nvl(tmp2.NumPostbillAdjustments, 0.0), 
					dm_1.NumTransactions - nvl(tmp2.NumTransactions, 0.0) 
					from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
					where dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
		where exists (select 1
					from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
					where dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0)); 

			/* Delete the MV rows that have NumTransactions=0 i.e. corresponding rows in the base tables are deleted */
        	/* ESR-2908 delete from PAYEE_SESSION with the same predicate that was used to do previous update of payee_session */ 					 
			delete from %%PAYEE_SESSION%% dm_1					 
				where exists (select 1
					from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
					where dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
					and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
					and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0)
					and dm_1.NumTransactions <=0);					 										 					 
					 

			insert into %%DELTA_INSERT_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
			inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
						on dm_1.id_dm_acc=tmp2.id_dm_acc 
						and dm_1.id_acc=tmp2.id_acc 
						and dm_1.id_usage_interval=tmp2.id_usage_interval 
						and dm_1.id_view=tmp2.id_view 
						and dm_1.am_currency=tmp2.am_currency 
						and dm_1.id_se=tmp2.id_se 
						and dm_1.dt_session=tmp2.dt_session
						and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
						and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
						and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
	end if;

end if;

end;
			