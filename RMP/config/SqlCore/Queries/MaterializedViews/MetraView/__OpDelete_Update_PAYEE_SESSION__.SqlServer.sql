
/* Following variables are used for checking the existence of data before executing script and added for performance reasons to avoid
running the unnecessary code */
declare @rowcount1 int
declare @dummy_var int
declare @dummy_var1 int
begin
set @dummy_var	= 0
set @dummy_var1	= 0
set @rowcount1 = 0

/* Cleanup the temporary delta table */
delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session

/* If we backput data then save the records in temporary table based on t_acc_usage delta table, we are using temp table since 
the code will summarize the adjustments in next steps and then we will insert into MV table based on this temp table */

if object_id ('%%DELTA_DELETE_T_ACC_USAGE%%') is not null
begin
	select @dummy_var = count(*) from %%DELTA_DELETE_T_ACC_USAGE%%
	if (@dummy_var > 0)
	begin
		Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
		TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,
		PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
		PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
		PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
		NumPostbillAdjustments,PrebillAdjustedAmount,PostbillAdjustedAmount,NumTransactions
		)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,
		au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,au.am_currency,au.id_se,convert(datetime,convert(char(10),au.dt_session,120)) as dt_session,
		SUM(isnull(au.Amount, 0.0)) TotalAmount,
		SUM(isnull(au.Tax_Federal, 0.0)) TotalFederalTax,
		SUM(isnull(au.Tax_County, 0.0)) Tax_County,
		SUM(isnull(au.Tax_Local, 0.0)) Tax_Local,
		SUM(isnull(au.Tax_Other, 0.0)) Tax_Other,
		SUM(isnull(au.Tax_State, 0.0)) TotalStateTax,
		SUM(isnull(au.Tax_Federal, 0.0)) + SUM(isnull(au.Tax_State, 0.0)) + SUM(isnull(au.Tax_County, 0.0)) + 
		SUM(isnull(au.Tax_Local, 0.0)) + SUM(isnull(au.Tax_Other, 0.0)) TotalTax,
		SUM(CASE WHEN (au.is_implied_tax = 'N') THEN 0.0 ELSE 
			 isnull(au.Tax_Federal, 0.0) + isnull(au.Tax_State, 0.0) + isnull(au.Tax_County, 0.0) + 
			 isnull(au.Tax_Local, 0.0) + isnull(au.Tax_Other, 0.0) end) TotalImpliedTax,
		SUM(CASE WHEN (au.tax_informational = 'N') THEN 0.0 ELSE 
			 isnull(au.Tax_Federal, 0.0) + isnull(au.Tax_State, 0.0) + isnull(au.Tax_County, 0.0) + 
			 isnull(au.Tax_Local, 0.0) + isnull(au.Tax_Other, 0.0) end) TotalInformationalTax,
		SUM(CASE WHEN (au.tax_informational = 'Y' AND au.is_implied_tax = 'Y') THEN
			 isnull(au.Tax_Federal, 0.0) + isnull(au.Tax_State, 0.0) + isnull(au.Tax_County, 0.0) + 
			 isnull(au.Tax_Local, 0.0) + isnull(au.Tax_Other, 0.0) else 0.0 end) TotalInformationalImpliedTax,
	    cast (0.0 as numeric(38,6)) as PrebillAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillFedTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillCntyTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PrebillLocalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillTotalTaxAdjAmt,
        cast (0.0 as numeric(38,6)) as PrebillImpliedTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillInformationalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillImplInfTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as NumPrebillAdjustments,cast (0.0 as numeric(38,6)) as PostbillAdjAmt,cast (0.0 as numeric(38,6)) as PostbillFedTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillCntyTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillLocalTaxAdjAmt,
		cast (0.0 as numeric(38,6)) as PostbillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillTotalTaxAdjAmt,
        cast (0.0 as numeric(38,6)) as PostbillImpliedTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillInformationalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillImplInfTaxAdjAmt,
        cast (0.0 as numeric(38,6)) as NumPostbillAdjustments,
		SUM(isnull(au.Amount,0.0)) PrebillAdjustedAmount,
		SUM(isnull(au.Amount,0.0)) PostbillAdjustedAmount,
		COUNT(*) NumTransactions
		from %%DELTA_DELETE_T_ACC_USAGE%% au  inner join t_dm_account acc on au.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		where id_parent_sess is null
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,convert(datetime,convert(char(10),au.dt_session,120)),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se
		set @dummy_var1 = @@rowcount
		/* Running the update statistics on the temporary delta table for performance reasons */
		update statistics %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session with fullscan
	end
end

set @dummy_var = 0

/* Following code is only executed if we deleted adjustments and records exists in adjustment delta table */

if object_id ('%%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%') is not null
begin
	select @dummy_var = count(*) from %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%%
	if (@dummy_var > 0)
	begin
		truncate table %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session
		Insert into %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
		PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
		PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,
		PrebillImpliedTaxAdjAmt,PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,
		NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,PostbillImpliedTaxAdjAmt,
		PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,NumPostbillAdjustments
		)
		select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
		au.am_currency,au.id_se,convert(datetime,convert(char(10),au.dt_session,120)),
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
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		0,0,0,
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
		SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL) THEN billajs.AdjustmentAmount
		ELSE 0 END),
		0,0,0,
		SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=1) THEN 1 ELSE 0 END) + 
		SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1)  THEN 1 ELSE 0 END)
		from
		T_ACC_USAGE au1 inner join t_dm_account acc on au1.id_payee=acc.id_acc
		and dt_session between vt_start and vt_end
		inner join %%DELTA_DELETE_T_ADJUSTMENT_TRANSACTION%% billajs on billajs.id_sess=au1.id_sess AND billajs.c_status = 'A'
		inner join T_ACC_USAGE au on au.id_sess=isnull(au1.id_parent_sess,au1.id_sess)
		where au1.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		and au.id_usage_interval not in (select id_interval from t_archive where
		status = 'A' and tt_end = dbo.mtmaxdate())
		group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,convert(datetime,convert(char(10),au.dt_session,120)),au.id_prod,au.id_view, 
		au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se

		if (@dummy_var1 > 0)
		begin
			update dm_1 set 
					dm_1.PrebillAdjAmt = IsNULL(dm_1.PrebillAdjAmt,0.0) + IsNULL(tmp2.PrebillAdjAmt, 0.0),
					dm_1.PrebillFedTaxAdjAmt = IsNULL(dm_1.PrebillFedTaxAdjAmt,0.0) + IsNULL(tmp2.PrebillFedTaxAdjAmt, 0.0), 
					dm_1.PrebillStatetaxAdjAmt = IsNULL(dm_1.PrebillStatetaxAdjAmt,0.0) + IsNULL(tmp2.PrebillStatetaxAdjAmt, 0.0), 
					dm_1.PrebillCntytaxAdjAmt = IsNULL(dm_1.PrebillCntytaxAdjAmt,0.0) + IsNULL(tmp2.PrebillCntytaxAdjAmt, 0.0), 
					dm_1.PrebillLocaltaxAdjAmt = IsNULL(dm_1.PrebillLocaltaxAdjAmt,0.0) + IsNULL(tmp2.PrebillLocaltaxAdjAmt, 0.0), 
					dm_1.PrebillOthertaxAdjAmt = IsNULL(dm_1.PrebillOthertaxAdjAmt,0.0) + IsNULL(tmp2.PrebillOthertaxAdjAmt, 0.0), 
					dm_1.PrebillTotaltaxAdjAmt = IsNULL(dm_1.PrebillTotaltaxAdjAmt,0.0) + IsNULL(tmp2.PrebillTotaltaxAdjAmt, 0.0), 
					dm_1.PrebillImpliedTaxAdjAmt = IsNULL(dm_1.PrebillImpliedTaxAdjAmt,0.0) + IsNULL(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
					dm_1.PrebillInformationalTaxAdjAmt = IsNULL(dm_1.PrebillInformationalTaxAdjAmt,0.0) + IsNULL(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
					dm_1.PrebillImplInfTaxAdjAmt = IsNULL(dm_1.PrebillImplInfTaxAdjAmt,0.0) + IsNULL(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
					dm_1.PostbillAdjAmt = IsNULL(dm_1.PostbillAdjAmt,0.0) + IsNULL(tmp2.PostbillAdjAmt, 0.0), 
					dm_1.PostbillFedTaxAdjAmt = IsNULL(dm_1.PostbillFedTaxAdjAmt,0.0) + IsNULL(tmp2.PostbillFedTaxAdjAmt, 0.0), 
					dm_1.PostbillStatetaxAdjAmt = IsNULL(dm_1.PostbillStatetaxAdjAmt,0.0) + IsNULL(tmp2.PostbillStatetaxAdjAmt, 0.0), 
					dm_1.PostbillCntytaxAdjAmt = IsNULL(dm_1.PostbillCntytaxAdjAmt,0.0) + IsNULL(tmp2.PostbillCntytaxAdjAmt, 0.0), 
					dm_1.PostbillLocaltaxAdjAmt = IsNULL(dm_1.PostbillLocaltaxAdjAmt,0.0) + IsNULL(tmp2.PostbillLocaltaxAdjAmt, 0.0), 
					dm_1.PostbillOthertaxAdjAmt = IsNULL(dm_1.PostbillOthertaxAdjAmt,0.0) + IsNULL(tmp2.PostbillOthertaxAdjAmt, 0.0), 
					dm_1.PostbillTotaltaxAdjAmt = IsNULL(dm_1.PostbillTotaltaxAdjAmt,0.0) + IsNULL(tmp2.PostbillTotaltaxAdjAmt, 0.0), 
					dm_1.PrebillAdjustedAmount = IsNULL(dm_1.PrebillAdjustedAmount,0.0) + IsNULL(tmp2.PrebillAdjustedAmount, 0.0), 
					dm_1.PostbillAdjustedAmount = IsNULL(dm_1.PostbillAdjustedAmount,0.0) + IsNULL(tmp2.PostbillAdjustedAmount, 0.0), 
					dm_1.PostbillImpliedTaxAdjAmt = IsNULL(dm_1.PostbillImpliedTaxAdjAmt,0.0) + IsNULL(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
					dm_1.PostbillInformationalTaxAdjAmt = IsNULL(dm_1.PostbillInformationalTaxAdjAmt,0.0) + IsNULL(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
					dm_1.PostbillImplInfTaxAdjAmt = IsNULL(dm_1.PostbillImplInfTaxAdjAmt,0.0) + IsNULL(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
					dm_1.NumPrebillAdjustments = IsNULL(dm_1.NumPrebillAdjustments,0.0) + IsNULL(tmp2.NumPrebillAdjustments, 0.0), 
					dm_1.NumPostbillAdjustments = IsNULL(dm_1.NumPostbillAdjustments,0.0) + IsNULL(tmp2.NumPostbillAdjustments, 0.0), 
					dm_1.NumTransactions = IsNULL(dm_1.NumTransactions,0.0) + IsNULL(tmp2.NumTransactions, 0.0) 
					from %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session dm_1 inner join  %%%NETMETERSTAGE_PREFIX%%%tmp_delete_payee_session tmp2 
					on dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
					and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
					and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0)
				set @dummy_var1 = @dummy_var1 + @@rowcount
		end
		else
		begin
			Insert into %%%NETMETERSTAGE_PREFIX%%%SUMM_DELTA_I_PAYEE_SESSION 
			(
			id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
			PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,
			PrebillImpliedTaxAdjAmt,PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,
		    NumPrebillAdjustments,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
			PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
			PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,
			PostbillImpliedTaxAdjAmt,PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
		    NumPostbillAdjustments
			)
			select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
			isnull(PrebillAdjAmt, 0.0), isnull(PrebillFedTaxAdjAmt, 0.0), isnull(PrebillStateTaxAdjAmt, 0.0),
							isnull(PrebillCntyTaxAdjAmt, 0.0), isnull(PrebillLocalTaxAdjAmt, 0.0), isnull(PrebillOtherTaxAdjAmt, 0.0), 
							isnull(PrebillTotalTaxAdjAmt, 0.0), isnull(PrebillAdjustedAmount, 0.0), 
							isnull(PrebillImpliedTaxAdjAmt, 0.0),isnull(PrebillInformationalTaxAdjAmt, 0.0),isnull(PrebillImplInfTaxAdjAmt, 0.0),
		                    isnull(NumPrebillAdjustments, 0.0),
							isnull(PostbillAdjAmt, 0.0),isnull(PostbillFedTaxAdjAmt, 0.0), isnull(PostbillStateTaxAdjAmt, 0.0),
							isnull(PostbillCntyTaxAdjAmt, 0.0),isnull(PostbillLocalTaxAdjAmt, 0.0), 
							isnull(PostbillOtherTaxAdjAmt, 0.0),isnull(PostbillTotalTaxAdjAmt, 0.0),
							isnull(PostbillAdjustedAmount, 0.0),
							isnull(PostbillImpliedTaxAdjAmt, 0.0),isnull(PostbillInformationalTaxAdjAmt, 0.0),isnull(PostbillImplInfTaxAdjAmt, 0.0),
		                    isnull(NumPostbillAdjustments, 0.0)
							from  %%%NETMETERSTAGE_PREFIX%%%tmp_insert_payee_session
			set @dummy_var1 = @dummy_var1 + @@rowcount
		end			
		
		Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session
		(
		id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,
		PrebillImpliedTaxAdjAmt,PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,
		NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
		)
		select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
		PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
		PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
		PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
		PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,
		PostbillImpliedTaxAdjAmt,PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
		NumPostbillAdjustments
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
					and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
					and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
					and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0))
		set @dummy_var1 = @dummy_var1 + @@rowcount

	end
end

set @dummy_var = 0

/* Following code is only executed if we backout usage */

if (@dummy_var1 > 0)
begin
	/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv tables, These delta_delete and delta_insert tables will
		be used by MV depending on payee_session and currently payer_interval depends on payee_session */

	insert into %%DELTA_DELETE_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
	inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
				on dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view 
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se 
				and dm_1.dt_session=tmp2.dt_session
				and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
				and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
				and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0)
	set	@rowcount1 = @@rowcount

	if (@rowcount1 > 0)
	begin
		update dm_1 set 
		dm_1.TotalAmount = IsNULL(dm_1.TotalAmount,0.0) - IsNULL(tmp2.TotalAmount, 0.0),
		dm_1.TotalFederalTax = IsNULL(dm_1.TotalFederalTax,0.0) - IsNULL(tmp2.TotalFederalTax, 0.0),
		dm_1.TotalCountyTax = IsNULL(dm_1.TotalCountyTax,0.0) - IsNULL(tmp2.TotalCountyTax, 0.0),
		dm_1.TotalLocalTax = IsNULL(dm_1.TotalLocalTax,0.0) - IsNULL(tmp2.TotalLocalTax, 0.0),
		dm_1.TotalOtherTax = IsNULL(dm_1.TotalOtherTax,0.0) - IsNULL(tmp2.TotalOtherTax, 0.0),
		dm_1.TotalStateTax = IsNULL(dm_1.TotalStateTax,0.0) - IsNULL(tmp2.TotalStateTax, 0.0),
		dm_1.TotalTax = IsNULL(dm_1.TotalTax,0.0) - IsNULL(tmp2.TotalTax, 0.0),
		dm_1.PrebillAdjAmt = IsNULL(dm_1.PrebillAdjAmt,0.0) - IsNULL(tmp2.PrebillAdjAmt, 0.0),
		dm_1.PrebillFedTaxAdjAmt = IsNULL(dm_1.PrebillFedTaxAdjAmt,0.0) - IsNULL(tmp2.PrebillFedTaxAdjAmt, 0.0), 
		dm_1.PrebillStatetaxAdjAmt = IsNULL(dm_1.PrebillStatetaxAdjAmt,0.0) - IsNULL(tmp2.PrebillStatetaxAdjAmt, 0.0), 
		dm_1.PrebillCntytaxAdjAmt = IsNULL(dm_1.PrebillCntytaxAdjAmt,0.0) - IsNULL(tmp2.PrebillCntytaxAdjAmt, 0.0), 
		dm_1.PrebillLocaltaxAdjAmt = IsNULL(dm_1.PrebillLocaltaxAdjAmt,0.0) - IsNULL(tmp2.PrebillLocaltaxAdjAmt, 0.0), 
		dm_1.PrebillOthertaxAdjAmt = IsNULL(dm_1.PrebillOthertaxAdjAmt,0.0) - IsNULL(tmp2.PrebillOthertaxAdjAmt, 0.0), 
		dm_1.PrebillTotaltaxAdjAmt = IsNULL(dm_1.PrebillTotaltaxAdjAmt,0.0) - IsNULL(tmp2.PrebillTotaltaxAdjAmt, 0.0), 
		dm_1.PrebillImpliedTaxAdjAmt = IsNULL(dm_1.PrebillImpliedTaxAdjAmt,0.0) - IsNULL(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
		dm_1.PrebillInformationalTaxAdjAmt = IsNULL(dm_1.PrebillInformationalTaxAdjAmt,0.0) - IsNULL(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
		dm_1.PrebillImplInfTaxAdjAmt = IsNULL(dm_1.PrebillImplInfTaxAdjAmt,0.0) - IsNULL(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
		dm_1.PostbillAdjAmt = IsNULL(dm_1.PostbillAdjAmt,0.0) + IsNULL(tmp2.PostbillAdjAmt, 0.0), 
		dm_1.PostbillFedTaxAdjAmt = IsNULL(dm_1.PostbillFedTaxAdjAmt,0.0) - IsNULL(tmp2.PostbillFedTaxAdjAmt, 0.0), 
		dm_1.PostbillStatetaxAdjAmt = IsNULL(dm_1.PostbillStatetaxAdjAmt,0.0) - IsNULL(tmp2.PostbillStatetaxAdjAmt, 0.0), 
		dm_1.PostbillCntytaxAdjAmt = IsNULL(dm_1.PostbillCntytaxAdjAmt,0.0) - IsNULL(tmp2.PostbillCntytaxAdjAmt, 0.0), 
		dm_1.PostbillLocaltaxAdjAmt = IsNULL(dm_1.PostbillLocaltaxAdjAmt,0.0) - IsNULL(tmp2.PostbillLocaltaxAdjAmt, 0.0), 
		dm_1.PostbillOthertaxAdjAmt = IsNULL(dm_1.PostbillOthertaxAdjAmt,0.0) - IsNULL(tmp2.PostbillOthertaxAdjAmt, 0.0), 
		dm_1.PostbillTotaltaxAdjAmt = IsNULL(dm_1.PostbillTotaltaxAdjAmt,0.0) - IsNULL(tmp2.PostbillTotaltaxAdjAmt, 0.0), 
		dm_1.PrebillAdjustedAmount = IsNULL(dm_1.PrebillAdjustedAmount,0.0) - IsNULL(tmp2.PrebillAdjustedAmount, 0.0), 
		dm_1.PostbillAdjustedAmount = IsNULL(dm_1.PostbillAdjustedAmount,0.0) - IsNULL(tmp2.PostbillAdjustedAmount, 0.0), 
		dm_1.PostbillImpliedTaxAdjAmt = IsNULL(dm_1.PostbillImpliedTaxAdjAmt,0.0) - IsNULL(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
		dm_1.PostbillInformationalTaxAdjAmt = IsNULL(dm_1.PostbillInformationalTaxAdjAmt,0.0) - IsNULL(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
		dm_1.PostbillImplInfTaxAdjAmt = IsNULL(dm_1.PostbillImplInfTaxAdjAmt,0.0) - IsNULL(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
		dm_1.NumPrebillAdjustments = IsNULL(dm_1.NumPrebillAdjustments,0.0) - IsNULL(tmp2.NumPrebillAdjustments, 0.0), 
		dm_1.NumPostbillAdjustments = IsNULL(dm_1.NumPostbillAdjustments,0.0) - IsNULL(tmp2.NumPostbillAdjustments, 0.0), 
		dm_1.NumTransactions = IsNULL(dm_1.NumTransactions,0.0) - IsNULL(tmp2.NumTransactions, 0.0) 
		from %%PAYEE_SESSION%% dm_1 inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 on 
		dm_1.id_dm_acc=tmp2.id_dm_acc 
		and dm_1.id_acc=tmp2.id_acc 
		and dm_1.id_usage_interval=tmp2.id_usage_interval 
		and dm_1.id_view=tmp2.id_view 
		and dm_1.am_currency=tmp2.am_currency 
		and dm_1.id_se=tmp2.id_se 
		and dm_1.dt_session=tmp2.dt_session
		and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
		and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
		and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0)

		/* Delete the MV rows that have NumTransactions=0 i.e. corresponding rows in the base tables are deleted */
 		/* ESR-2908 delete with same predicate as previous update */
		delete dm_1 from %%PAYEE_SESSION%% dm_1
		inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 on 
			dm_1.id_dm_acc = tmp2.id_dm_acc 
			and dm_1.id_acc=tmp2.id_acc
			and dm_1.id_usage_interval=tmp2.id_usage_interval 
			and dm_1.id_view=tmp2.id_view
			and dm_1.am_currency=tmp2.am_currency 
			and dm_1.id_se=tmp2.id_se
			and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
			and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
			and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0) 			
			and dm_1.NumTransactions <= 0

		insert into %%DELTA_INSERT_PAYEE_SESSION%% Select dm_1.* from %%PAYEE_SESSION%% dm_1
		inner join %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payee_session tmp2 
					on dm_1.id_dm_acc=tmp2.id_dm_acc 
					and dm_1.id_acc=tmp2.id_acc 
					and dm_1.id_usage_interval=tmp2.id_usage_interval 
					and dm_1.id_view=tmp2.id_view 
					and dm_1.am_currency=tmp2.am_currency 
					and dm_1.id_se=tmp2.id_se 
					and dm_1.dt_session=tmp2.dt_session
					and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
					and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
					and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0)
	end

end
end
			