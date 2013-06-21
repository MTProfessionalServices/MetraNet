
declare 
rowcount2 number(10);
begin

/* Cleanup the temporary delta tables */

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval;

/* Insert the changes in temporary table based on payee_session delta table */
Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,
TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,TotalImpliedTax,
        TotalInformationalTax,TotalImplInfTax,PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStatetaxAdjAmt,PrebillCntytaxAdjAmt,
		PrebillLocaltaxAdjAmt,PrebillOthertaxAdjAmt,PrebillTotaltaxAdjAmt,PrebillImpliedTaxAdjAmt,
        PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,NumPrebillAdjustments,
		PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStatetaxAdjAmt,
		PostbillCntytaxAdjAmt,PostbillLocaltaxAdjAmt,PostbillOthertaxAdjAmt,
		PostbillTotaltaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
		NumPostbillAdjustments,PrebillAdjustedAmount,PostbillAdjustedAmount,NumTransactions
)
select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,
am_currency,id_se,
SUM(TotalAmount) TotalAmount,
SUM(TotalFederalTax) TotalFederalTax, 
SUM(TotalCountyTax),
SUM(TotalLocalTax),
SUM(TotalOtherTax),
SUM(TotalStateTax) TotalStateTax, 
SUM(TotalTax) TotalTax, 
SUM(TotalImpliedTax) TotalImpliedTax,
SUM(TotalInformationalTax)      TotalInformationalTax,
SUM(TotalImplInfTax) TotalImplInfTax,
SUM(PrebillAdjAmt) PrebillAdjAmt, 
SUM(PrebillFedTaxAdjAmt) PrebillFedTaxAdjAmt,
SUM(PrebillStateTaxAdjAmt) PrebillStateTaxAdjAmt,
SUM(PrebillCntyTaxAdjAmt) PrebillCntyTaxAdjAmt,
SUM(PrebillLocalTaxAdjAmt) PrebillLocalTaxAdjAmt,
SUM(PrebillOtherTaxAdjAmt) PrebillOtherTaxAdjAmt,
SUM(PrebillTotalTaxAdjAmt) PrebillTotalTaxAdjAmt,
SUM(PrebillImpliedTaxAdjAmt) PrebillImpliedTaxAdjAmt,
SUM(PrebillInformationalTaxAdjAmt) PrebillInformationalTaxAdjAmt,
SUM(PrebillImplInfTaxAdjAmt) PrebillImplInfTaxAdjAmt,
SUM(PostbillAdjAmt) PostbillAdjAmt, 
SUM(PostbillFedTaxAdjAmt) PostbillFedTaxAdjAmt,
SUM(PostbillStateTaxAdjAmt) PostbillStateTaxAdjAmt,
SUM(PostbillCntyTaxAdjAmt) PostbillCntyTaxAdjAmt,
SUM(PostbillLocalTaxAdjAmt) PostbillLocalTaxAdjAmt,
SUM(PostbillOtherTaxAdjAmt) PostbillOtherTaxAdjAmt,
SUM(PostbillTotalTaxAdjAmt) PostbillTotalTaxAdjAmt,
SUM(PostbillImpliedTaxAdjAmt) PostbillImpliedTaxAdjAmt,
SUM(PostbillInformationalTaxAdjAmt) PostbillInformationalTaxAdjAmt,
SUM(PostbillImplInfTaxAdjAmt) PostbillImplInfTaxAdjAmt,
SUM(PrebillAdjustedAmount) PrebillAdjustedAmount, 
SUM(PostbillAdjustedAmount) PostbillAdjustedAmount, 
sum(NumPrebillAdjustments) NumPrebillAdjustments, 
sum(NumPostbillAdjustments) NumPostbillAdjustments, 
sum(NumTransactions) NumTransactions
from %%DELTA_INSERT_PAYEE_SESSION%% 
group by 
id_acc, 
id_dm_acc, 
id_usage_interval, 
id_prod, 
id_view, 
id_pi_instance, 
id_pi_template, 
am_currency, 
id_se;
exec_ddl('ANALYZE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval COMPUTE STATISTICS');      

/* Update the existing rows in the MV table and keep all the changes in the delta_delete and delta_insert mv table */

insert into %%DELTA_DELETE_PAYER_INTERVAL%%  select dm_1.* from %%PAYER_INTERVAL%% dm_1 
inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 on 
			dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
rowcount2 := sql%rowcount;

if (rowcount2 > 0)
then
update %%PAYER_INTERVAL%% dm_1 set
(TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,PrebillAdjAmt,PrebillFedTaxAdjAmt,
 PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,
 PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
 PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
 PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
        PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
 PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,NumPostbillAdjustments,NumTransactions)
 = (select
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
nvl(dm_1.PrebillAdjAmt,0.0) + nvl(tmp2.PrebillAdjAmt, 0.0),
nvl(dm_1.PrebillFedTaxAdjAmt,0.0) + nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillStateTaxAdjAmt,0.0) + nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillCntyTaxAdjAmt,0.0) + nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillLocalTaxAdjAmt,0.0) + nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillOtherTaxAdjAmt,0.0) + nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillTotalTaxAdjAmt,0.0) + nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillImpliedTaxAdjAmt,0.0) + nvl(tmp2.PrebillImpliedTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillInformationalTaxAdjAmt,0.0) + nvl(tmp2.PrebillInformationalTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillImplInfTaxAdjAmt,0.0) + nvl(tmp2.PrebillImplInfTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillAdjAmt,0.0) + nvl(tmp2.PostbillAdjAmt, 0.0), 
nvl(dm_1.PostbillFedTaxAdjAmt,0.0) + nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillStateTaxAdjAmt,0.0) + nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillCntyTaxAdjAmt,0.0) + nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillLocalTaxAdjAmt,0.0) + nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillOtherTaxAdjAmt,0.0) + nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillTotalTaxAdjAmt,0.0) + nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillImpliedTaxAdjAmt,0.0) + nvl(tmp2.PostbillImpliedTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillInformationalTaxAdjAmt,0.0) + nvl(tmp2.PostbillInformationalTaxAdjAmt, 0.0), 
nvl(dm_1.PostbillImplInfTaxAdjAmt,0.0) + nvl(tmp2.PostbillImplInfTaxAdjAmt, 0.0), 
nvl(dm_1.PrebillAdjustedAmount,0.0) + nvl(tmp2.PrebillAdjustedAmount, 0.0), 
nvl(dm_1.PostbillAdjustedAmount,0.0) + nvl(tmp2.PostbillAdjustedAmount, 0.0), 
nvl(dm_1.NumPrebillAdjustments,0.0) + nvl(tmp2.NumPrebillAdjustments, 0.0), 
nvl(dm_1.NumPostbillAdjustments,0.0) + nvl(tmp2.NumPostbillAdjustments, 0.0), 
nvl(dm_1.NumTransactions,0.0) + nvl(tmp2.NumTransactions, 0.0)
from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 where 			
      dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
 where exists (select 1 
from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 where 			
      dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0)); 

insert into %%DELTA_INSERT_PAYER_INTERVAL%%  select dm_1.* from %%PAYER_INTERVAL%% dm_1 
inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 on 
			dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0);
end if;

/* Add the new rows into the MV table from the summary delta table and keep all the changes in MV delta_insert table */
insert into %%DELTA_INSERT_PAYER_INTERVAL%% 
(id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,
TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
 PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
 PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
 PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions)
Select 
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,
TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
TotalImpliedTax,TotalInformationalTax,TotalImplInfTax,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillImpliedTaxAdjAmt,
 PrebillInformationalTaxAdjAmt,PrebillImplInfTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PostbillImpliedTaxAdjAmt,
PostbillInformationalTaxAdjAmt,PostbillImplInfTaxAdjAmt,
PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 
where not exists (select 1 from %%PAYER_INTERVAL%% dm_1 where 
			dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
rowcount2 := sql%rowcount;

if (rowcount2 > 0)
then
	insert into %%PAYER_INTERVAL%%
	(id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,TotalAmount,
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
	select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,TotalAmount,
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
	NumPostbillAdjustments,NumTransactions
	from   %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval tmp2 where not exists 
				(select 1 from %%PAYER_INTERVAL%% dm_1 where 
				dm_1.id_dm_acc=tmp2.id_dm_acc 
				and dm_1.id_acc=tmp2.id_acc 
				and dm_1.id_usage_interval=tmp2.id_usage_interval 
				and dm_1.id_view=tmp2.id_view
				and dm_1.am_currency=tmp2.am_currency 
				and dm_1.id_se=tmp2.id_se
				and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
				and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
				and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
	end if;
end;
			