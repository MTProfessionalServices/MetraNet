CREATE PROCEDURE [dbo].[CreateAnalyticsDataMart] @p_dt_now datetime, @p_id_run int, @p_nm_currency nvarchar(3), @p_nm_instance nvarchar(128), @p_n_months int, @p_STAGINGDB_prefix varchar
AS
BEGIN

DECLARE @l_count int;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Starting Analytics DataMart');
end;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Flushing Analytics datamart tables');
end;

TRUNCATE TABLE Customer;
TRUNCATE TABLE SalesRep;
TRUNCATE TABLE SubscriptionsByMonth;
TRUNCATE TABLE SubscriptionUnits;
TRUNCATE TABLE SubscriptionSummary;
TRUNCATE TABLE CurrencyExchangeMonthly;
TRUNCATE TABLE ProductOffering;
TRUNCATE TABLE SubscriptionParticipants;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Cleaning out temporary tables');
end;

IF OBJECT_ID('tempdb..#tmp_unrooted') IS NOT NULL drop table #tmp_unrooted;
IF OBJECT_ID('tempdb..#tmp_all_customers') IS NOT NULL drop table #tmp_all_customers;
IF OBJECT_ID('tempdb..#tmp_corps') IS NOT NULL drop table #tmp_corps;
IF OBJECT_ID('tempdb..#tmp_accs') IS NOT NULL drop table #tmp_accs;
IF OBJECT_ID('tempdb..#all_rcs') IS NOT NULL drop table #all_rcs;
IF OBJECT_ID('tempdb..#all_rcs_linked') IS NOT NULL drop table #all_rcs_linked;
IF OBJECT_ID('tempdb..#all_rcs_by_month') IS NOT NULL drop table #all_rcs_by_month;
IF OBJECT_ID('tempdb..#sum_rcs_by_month') IS NOT NULL drop table #sum_rcs_by_month;
IF OBJECT_ID('tempdb..#tmp_fx') IS NOT NULL drop table #tmp_fx;
IF OBJECT_ID('tempdb..#tmp_previous_two_months') IS NOT NULL drop table #tmp_previous_two_months;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating Customers DataMart');
end;

/* customers datamart */
;with root_accts as
(
	select /* corporate accounts */
	a.id_acc
	from t_account a with(nolock)
	inner join t_account_type t with(nolock) on t.id_type = a.id_type
	where 1=1
	and t.b_iscorporate = 1
	and t.b_isvisibleinhierarchy = 1
)
select
r.id_acc id_ancestor, aa.id_descendent, aa.num_generations
into #tmp_corps
from root_accts r with(nolock)
inner join t_account_ancestor aa with(nolock) on aa.id_ancestor = r.id_acc and @p_dt_now between aa.vt_start and aa.vt_end
where 1=1
OPTION(MAXDOP 1, FORCE ORDER)
;

select @l_count = count(1) from #tmp_corps;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Found Corporate Accounts: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

;with my_gens as
(
	select
	id_descendent, max(num_generations) num_generations
	from #tmp_corps
	group by id_descendent
)
select
max(a.id_ancestor) id_ancestor, a.id_descendent
into #tmp_accs
from #tmp_corps a
inner join my_gens g on a.id_descendent = g.id_descendent and a.num_generations = g.num_generations
where 1=1
group by a.id_descendent
OPTION(MAXDOP 1)
;

select @l_count = count(1) from #tmp_accs;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Found Corporate Hierarchy Accounts: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

; with root_accts as
(
	select
	aa.id_descendent id_acc
	from t_account_ancestor aa with(nolock)
	inner join t_account a with(nolock) on a.id_acc = aa.id_descendent
	inner join t_account_type t with(nolock) on t.id_type = a.id_type and (t.b_iscorporate = 0 or t.b_isvisibleinhierarchy = 0)
	where 1=1
	and @p_dt_now between aa.vt_start and aa.vt_end
	and aa.id_ancestor = 1
	and aa.num_generations = 1
	and aa.b_children = 'Y'
)
insert into #tmp_accs (id_ancestor, id_descendent)
select
r.id_acc id_ancestor, aa.id_descendent
from root_accts r with(nolock)
inner join t_account_ancestor aa with(nolock) on aa.id_ancestor = r.id_acc and @p_dt_now between aa.vt_start and aa.vt_end
left outer join #tmp_accs a on aa.id_descendent = a.id_descendent
where 1=1
and a.id_descendent is null
OPTION(MAXDOP 1, FORCE ORDER)
;

select @l_count = count(1) from #tmp_accs;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Added Non-Corporate Hierarchy Accounts, Total Now: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

/* non-corporate nodes without hierarchy */
insert into #tmp_accs (id_ancestor, id_descendent)
select
a.id_acc, a.id_acc
from t_account a with(nolock)
left outer join #tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa with(nolock) on aa.id_descendent = a.id_acc and @p_dt_now between aa.vt_start and aa.vt_end and aa.id_ancestor = 1 and aa.num_generations > 0
where 1=1
and b.id_descendent is null
;

select @l_count = count(1) from #tmp_accs;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Added Non-Corporate Non-Hierarchy Accounts, Total Now: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

/* unrooted nodes */
select
aa.id_ancestor, aa.id_descendent, aa.num_generations
into #tmp_unrooted
from t_account a with(nolock)
left outer join #tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa with(nolock) on aa.id_descendent = a.id_acc and @p_dt_now between aa.vt_start and aa.vt_end
where 1=1
and b.id_descendent is null
;

;with my_unrooted as
(
	select id_descendent, max(num_generations) num_generations
	from #tmp_unrooted
	group by id_descendent
)
insert into #tmp_accs (id_ancestor, id_descendent)
select
b.id_ancestor, b.id_descendent
from my_unrooted a
inner join #tmp_unrooted b on a.id_descendent = b.id_descendent and a.num_generations = b.num_generations
where 1=1
;

select @l_count = count(1) from #tmp_accs;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Added Non-Rooted Accounts, Total Now: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

declare @billTo int;

select @billTo = id_enum_data from t_enum_data where nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to';

select
@p_nm_instance as InstanceId,
c.id_acc as MetraNetId,
ct.name as AccountType,
cam.nm_login as ExternalId,
cam.nm_space as ExternalIdSpace,
cav.c_firstname as FirstName,
cav.c_middleinitial as MiddleName,
cav.c_lastname as LastName,
cav.c_company as Company,
cavi.c_currency as Currency,
cav.c_city as City,
cav.c_state as State,
cav.c_zip as ZipCode,
substring(ted2.nm_enum_data,20,100) as Country,
cav.c_email as Email,
cav.c_phonenumber as Phone,
p.id_acc as HierarchyMetraNetId,
pt.name as HierarchyAccountType,
pam.nm_login as HierarchyExternalId,
pam.nm_space as HierarchyExternalIdSpace,
pav.c_firstname as HierarchyFirstName,
pav.c_middleinitial as HierarchyMiddleName,
pav.c_lastname as HierarchyLastName,
pav.c_company as HierarchyCompany,
pavi.c_currency as HierarchyCurrency,
pav.c_city as HierarchyCity,
pav.c_state as HierarchyState,
pav.c_zip as HierarchyZipCode,
substring(ted3.nm_enum_data,20,100) as HierarchyCountry,
pav.c_email as HierarchyEmail,
pav.c_phonenumber as HierarchyPhone,
c.dt_crt as StartDate,
case when state.status != 'AC' then state.vt_start else state.vt_end end as EndDate
into #tmp_all_customers
from #tmp_accs r with(nolock)
inner join t_account c with(nolock) on c.id_acc = r.id_descendent
inner join t_account_state state with(nolock) on state.id_acc = c.id_acc and state.vt_end = dbo.MTMaxDate()
inner join t_account_type ct with(nolock) on ct.id_type = c.id_type
inner join t_account_mapper cam with(nolock) on cam.id_acc = c.id_acc and cam.nm_space not in ('ar')
left outer join t_av_internal cavi with(nolock) on cavi.id_acc = c.id_acc
left outer join t_av_contact cav with(nolock) on c.id_acc = cav.id_acc and cav.c_contactType = @billTo
left outer join t_enum_data ted2 with(nolock) on ted2.id_enum_data = cav.c_country
inner join t_account p with(nolock) on p.id_acc = r.id_ancestor
inner join t_account_type pt with(nolock) on pt.id_type = p.id_type
inner join t_account_mapper pam with(nolock) on pam.id_acc = p.id_acc and pam.nm_space not in ('ar')
left outer join t_av_internal pavi with(nolock) on pavi.id_acc = p.id_acc
left outer join t_av_contact pav with(nolock) on p.id_acc = pav.id_acc and pav.c_contactType = @billTo
left outer join t_enum_data ted3 with(nolock) on ted3.id_enum_data = pav.c_country
where 1=1
OPTION(MAXDOP 1, FORCE ORDER)
;

select @l_count = count(1) from #tmp_all_customers;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Reducing duplicate aliases from total: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

insert into Customer
		(InstanceId,
		MetraNetId,
		AccountType,
		ExternalId,
		ExternalIdSpace,
		FirstName,
		MiddleName,
		LastName,
		Company,
		Currency,
		City,
		State,
		ZipCode,
		Country,
		Email,
		Phone,
		HierarchyMetraNetId,
		HierarchyAccountType,
		HierarchyExternalId,
		HierarchyExternalIdSpace,
		HierarchyFirstName,
		HierarchyMiddleName,
		HierarchyLastName,
		HierarchyCompany,
		HierarchyCurrency,
		HierarchyCity,
		HierarchyState,
		HierarchyZipCode,
		HierarchyCountry,
		HierarchyEmail,
		HierarchyPhone,
		StartDate,
		EndDate)
select
		InstanceId,
		MetraNetId,
		AccountType,
		ExternalId,
		ExternalIdSpace,
		FirstName,
		MiddleName,
		LastName,
		Company,
		Currency,
		City,
		State,
		ZipCode,
		Country,
		Email,
		Phone,
		HierarchyMetraNetId,
		HierarchyAccountType,
		HierarchyExternalId,
		HierarchyExternalIdSpace,
		HierarchyFirstName,
		HierarchyMiddleName,
		HierarchyLastName,
		HierarchyCompany,
		HierarchyCurrency,
		HierarchyCity,
		HierarchyState,
		HierarchyZipCode,
		HierarchyCountry,
		HierarchyEmail,
		HierarchyPhone,
		StartDate,
		EndDate
from (select *, 
		DENSE_RANK() OVER (PARTITION BY MetraNetId, HierarchyMetraNetId ORDER BY ExternalIdSpace, HierarchyExternalIdSpace) as [priority_col]		
		FROM #tmp_all_customers) a
where 1=1
and a.[priority_col] = 1

select @l_count = count(1) from Customer;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Customers: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating SalesRep DataMart');
end;

/* sales reps */
insert into SalesRep
(	InstanceId,
	MetraNetId,
	ExternalId,
	CustomerId,
	Percentage,
	RelationshipType)
select @p_nm_instance as InstanceId,
tao.id_owner as MetraNetId,
am.nm_login as ExternalId,
tao.id_owned as CustomerId,
tao.n_percent as Percentage,
substring(ted.nm_enum_data,37, 100) as RelationshipType
from t_acc_ownership tao with(nolock)
inner join t_enum_data ted with(nolock) on ted.id_enum_data = tao.id_relation_type
inner join t_account_mapper am with(nolock) on am.id_acc = tao.id_owner and am.nm_space = 'system_user'
where 1=1
and @p_dt_now between tao.vt_start and tao.vt_end
;

select @l_count = count(1) from SalesRep;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Sales Reps: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating CurrencyExchangeMonthly DataMart');
end;

select
@p_nm_instance as InstanceId,
vt_start as StartDate,
vt_end  as EndDate,
nm_country_source as SourceCurrency,
nm_country_target as TargetCurrency,
c_exchange_rate as ExchangeRate
into #tmp_fx
from t_vw_adm_exchange_rates;

insert into CurrencyExchangeMonthly
(	InstanceId,
	StartDate,
	EndDate,
	SourceCurrency,
	TargetCurrency,
	ExchangeRate
)
select InstanceId,
	StartDate,
	EndDate,
	SourceCurrency,
	TargetCurrency,
	ExchangeRate
from #tmp_fx;

select @l_count = count(1) from CurrencyExchangeMonthly;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Currency Exchange Rates: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating SubscriptionsByMonth DataMart');
end;

;
with my_pis as
(
select distinct
sub.id_sub,
sub.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
sub.vt_start,
sub.vt_end
from t_sub sub with(nolock)
inner join t_pl_map plm with(nolock) on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr with(nolock) on tr.id_prop = plm.id_pi_instance
where 1=1
and sub.id_group is null
union
select distinct
sub.id_sub,
mbr.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
mbr.vt_start,
mbr.vt_end
from t_gsubmember mbr with(nolock)
inner join t_sub sub with(nolock) on sub.id_group = mbr.id_group
inner join t_pl_map plm with(nolock) on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr with(nolock) on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'Y'
where 1=1
union
select distinct
sub.id_sub,
grm.id_acc,
sub.id_po,
plm.id_pi_template,
plm.id_pi_instance,
grm.vt_start,
grm.vt_end
from t_gsubmember mbr with(nolock)
inner join t_sub sub with(nolock) on sub.id_group = mbr.id_group
inner join t_pl_map plm with(nolock) on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr with(nolock) on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'N'
inner join t_gsub_recur_map grm with(nolock) on grm.id_prop = tr.id_prop and grm.tt_end = dbo.mtmaxdate()
where 1=1
)
select
*
into #all_rcs
from (
select
@p_nm_instance as InstanceId,
svc.id_sub as SubscriptionId,
au.id_acc as PayerId,
au.id_payee as PayeeId,
pv.c_ProratedIntervalStart as StartDate,
pv.c_ProratedIntervalEnd as EndDate,
pv.c_RCActionType as ActionType,
au.am_currency as Currency,
pv.c_ProratedDailyRate as ProratedDailyRate,
case when pv.c_prorateddays = 0 then au.amount else au.amount/pv.c_prorateddays end as DailyRate,
pv.c_RCAmount as Rate,
au.id_prod as ProductOfferingId,
au.id_pi_template as PriceableItemTemplateId,
au.id_pi_instance as PriceableItemInstanceId,
svc.vt_start as SubscriptionStartDate,
svc.vt_end as SubscriptionEndDate,
au.amount as MRR
from t_usage_interval tui with(nolock)
inner join t_pv_flatrecurringcharge pv with(nolock) on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au with(nolock) on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc with(nolock) on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
									and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
union all
select
@p_nm_instance as InstanceId,
svc.id_sub as SubscriptionId,
au.id_acc as PayerId,
au.id_payee as PayeeId,
pv.c_ProratedIntervalStart as StartDate,
pv.c_ProratedIntervalEnd as EndDate,
pv.c_RCActionType as ActionType,
au.am_currency as Currency,
pv.c_ProratedDailyRate as ProratedDailyRate,
case when pv.c_prorateddays = 0 then au.amount else au.amount/pv.c_prorateddays end as DailyRate,
pv.c_RCAmount as Rate,
au.id_prod as ProductOfferingId,
au.id_pi_template as PriceableItemTemplateId,
au.id_pi_instance as PriceableItemInstanceId,
svc.vt_start as SubscriptionStartDate,
svc.vt_end as SubscriptionEndDate,
au.amount as MRR
from t_usage_interval tui with(nolock)
inner join t_pv_udrecurringcharge pv with(nolock) on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au with(nolock) on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc with(nolock) on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
									and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
) A
;

select @l_count = count(1) from #all_rcs;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Found RCs: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

create index idx_all_rcs on #all_rcs (InstanceId, SubscriptionId, PayeeId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate, ActionType, Currency);

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Created index for RC linkage');
end;

select
crc.*,
prc.Rate as OldRate,
prc.DailyRate as OldDailyRate,
prc.ProratedDailyRate as OldProratedDailyRate,
prc.SubscriptionStartDate as OldSubscriptionStartDate,
prc.SubscriptionEndDate as OldSubscriptionEndDate
into #all_rcs_linked
from #all_rcs crc
left outer join #all_rcs prc on  crc.InstanceId = prc.InstanceId
                             and crc.SubscriptionId = prc.SubscriptionId
                             and crc.PayeeId = prc.PayeeId
                             and crc.PriceableItemTemplateId = prc.PriceableItemTemplateId
                             and crc.PriceableItemInstanceId = prc.PriceableItemInstanceId
							 and crc.Currency = prc.Currency
                             and prc.EndDate = DATEADD(second,-1, crc.StartDate)
                             and prc.ActionType = crc.ActionType
                             and crc.ActionType IN ('Advance','Arrears')
where 1=1
;

select @l_count = count(1) from #all_rcs_linked;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Found Linked RCs: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

create index idx_all_rcs_linked on #all_rcs_linked (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate);

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Created index for linked RCs');
end;

select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.ProductOfferingId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.SubscriptionStartDate,
rcs.SubscriptionEndDate,
rcs.Currency,
case when months.number <> 0 then 'NotInitial' else rcs.ActionType end as ActionType,
year(dateadd(month, months.number, rcs.startdate)) as Year,
month(dateadd(month, months.number, rcs.startdate)) as Month,
rcs.DailyRate,
rcs.Rate,
rcs.OldDailyRate,
rcs.OldRate,
rcs.OldProratedDailyRate,
rcs.OldSubscriptionStartDate,
rcs.OldSubscriptionEndDate,
case when datediff(month, rcs.startdate, rcs.enddate) = months.number then day(rcs.enddate) - case when months.number = 0 then (day(rcs.startdate) - 1) else 0 end
	 else case when month(dateadd(month, months.number, rcs.startdate)) in (4,6,9,11) then 30
	           when month(dateadd(month, months.number, rcs.startdate)) = 2 then case when year(dateadd(month, months.number, rcs.startdate)) % 400 = 0 then 29
																					  when year(dateadd(month, months.number, rcs.startdate)) % 100 = 0 then 28
																					  when year(dateadd(month, months.number, rcs.startdate)) % 4   = 0 then 29
																					  else 28
																				 end
			   else 31
		  end
		  - case when months.number <> 0 then 0
				 else (day(rcs.startdate) - 1)
			end
end as Days
into #all_rcs_by_month
from #all_rcs_linked rcs
inner join master..spt_values months on months.type='P' and months.number between 0 and DATEDIFF(month,rcs.startdate, rcs.enddate)
where 1=1
;

select @l_count = count(1) from #all_rcs_by_month;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Found RCs by month: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.Currency,
rcs.Year,
rcs.Month,
case when rcs.Month in (4,6,9,11) then 30 when rcs.Month = 2 then case when rcs.Year % 400 = 0 then 29 when rcs.Year % 100 = 0 then 28 when rcs.Year % 4 = 0 then 29 else 28 end else 31 end as DaysInMonth,
max(rcs.Days) as DaysActiveInMonth,
sum(cast(rcs.DailyRate*rcs.Days as numeric(18,6))) as TotalAmount,
sum(case when rcs.OldRate is null then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
		 when rcs.Rate = rcs.OldRate then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         when rcs.DailyRate = 0 then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         else cast((rcs.DailyRate*rcs.Days)*(cast(rcs.OldRate/rcs.Rate as numeric(29,17))) as numeric(18,6))
    end) as OldAmount,
sum(case when rcs.OldSubscriptionEndDate is null then rcs.DailyRate*rcs.Days else 0 end) as NewAmount
into #sum_rcs_by_month
from #all_rcs_by_month rcs
where 1=1
group by
rcs.InstanceId,
rcs.SubscriptionId,
rcs.Currency,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.Year,
rcs.Month
;

select @l_count = count(1) from #sum_rcs_by_month;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Summarized RCs by month: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;

create index idx_monthly_rcs on #sum_rcs_by_month (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, Year, Month, Currency);

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Created index for summarized subscriptions');
end;

create index idx_tmp_fx_rate on #tmp_fx (InstanceId,SourceCurrency,TargetCurrency,StartDate,EndDate);

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Debug', 'Created index for exchange rates');
end;

insert into SubscriptionsByMonth
(	InstanceId,
	SubscriptionId,
	[Year],
	[Month],
	Currency,
	MRR,
	MRRPrimaryCurrency,
	MRRNew,
	MRRNewPrimaryCurrency,
	MRRBase,
	MRRBasePrimaryCurrency,
	MRRRenewal,
	MRRRenewalPrimaryCurrency,
	MRRPriceChange,
	MRRPriceChangePrimaryCurrency,
	MRRChurn,
	MRRChurnPrimaryCurrency,
	MRRCancelation,
	MRRCancelationPrimaryCurrency,
	SubscriptionRevenue,
	SubscriptionRevPrimaryCurrency,
	DaysInMonth,
	DaysActiveInMonth,
	ReportingCurrency
)
select cMonth.InstanceId,
	cMonth.SubscriptionId,
	cMonth.Year,
	cMonth.Month,
	cMonth.Currency,
	cMonth.TotalAmount as MRR,
	cMonth.TotalAmount*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPrimaryCurrency,
	cMonth.NewAmount as MRRNew,
	cMonth.NewAmount*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRNewPrimaryCurrency,
	IsNull(pMonth.TotalAmount,0) as MRRBase,
	IsNull(pMonth.TotalAmount,0)*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRBasePrimaryCurrency,
	0 as MRRRenewal,
	0*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRRenewalPrimaryCurrency,
	(cMonth.TotalAmount - cMonth.OldAmount) as MRRPriceChange,
	(cMonth.TotalAmount - cMonth.OldAmount)*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPriceChangePrimaryCurrency,
	0 as MRRChurn,
	0*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRChurnPrimaryCurrency,
	0 as MRRCancelation,
	0*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRCancelationPrimaryCurrency,
	0 as SubscriptionRevenue,
	0*(case when @p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as SubscriptionRevPrimaryCurrency,
	cMonth.DaysInMonth,
	cMonth.DaysActiveInMonth,
	@p_nm_currency
from #sum_rcs_by_month cMonth
left outer join #sum_rcs_by_month pMonth on  cMonth.InstanceId = pMonth.InstanceId
										 and cMonth.SubscriptionId = pMonth.SubscriptionId
										 and cMonth.PriceableItemTemplateId = pMonth.PriceableItemTemplateId
										 and cMonth.PriceableItemInstanceId = pMonth.PriceableItemInstanceId
										 and cMonth.Currency = pMonth.Currency
										 and case when cMonth.Month = 1 then cMonth.Year - 1 else cMonth.Year end = pMonth.Year
										 and case when cMonth.Month = 1 then 12 else cMonth.Month - 1 end = pMonth.Month
left outer join #tmp_fx exc on exc.InstanceId = cMonth.InstanceId and exc.SourceCurrency = cMonth.Currency and exc.TargetCurrency = @p_nm_currency and @p_dt_now between exc.StartDate and exc.EndDate
where 1=1
;

select @l_count = count(1) from SubscriptionsByMonth;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Subscriptions by month: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating SubscriptionSummary DataMart');
end;

insert into SubscriptionSummary
(	InstanceId,
	ProductOfferingId,
	[Year],
	[Month],
	TotalParticipants,
	DistinctHierarchies,
	NewParticipants,
	MRRPrimaryCurrency,
	MRRNewPrimaryCurrency,
	MRRBasePrimaryCurrency,
	MRRRenewalPrimaryCurrency,
	MRRPriceChangePrimaryCurrency,
	MRRChurnPrimaryCurrency,
	MRRCancelationPrimaryCurrency,
	SubscriptionRevPrimaryCurrency,
	DaysInMonth)
select
mrr.InstanceId,
sub.id_po as ProductOfferingId,
mrr.Year,
mrr.Month,
count(1) as TotalParticipants,
count(distinct cust.HierarchyMetraNetId) as DistinctHierarchies,
sum(case when datediff(day, sub.dt_start, @p_dt_now) <= 30 then 1 else 0 end) as NewParticipants,
sum(mrr.MRRPrimaryCurrency) as MRRPrimaryCurrency,
sum(mrr.MRRNewPrimaryCurrency) as MRRNewPrimaryCurrency,
sum(mrr.MRRBasePrimaryCurrency) as MRRBasePrimaryCurrency,
sum(mrr.MRRRenewalPrimaryCurrency) as MRRRenewalPrimaryCurrency,
sum(mrr.MRRPriceChangePrimaryCurrency) as MRRPriceChangePrimaryCurrency,
sum(mrr.MRRChurnPrimaryCurrency) as MRRChurnPrimaryCurrency,
sum(mrr.MRRCancelationPrimaryCurrency) as MRRCancelationPrimaryCurrency,
sum(mrr.SubscriptionRevPrimaryCurrency) as SubscriptionRevPrimaryCurrency,
mrr.DaysInMonth
from SubscriptionsByMonth mrr
inner join t_vw_effective_subs sub with(nolock) on sub.id_sub = mrr.SubscriptionId
inner join Customer cust on cust.InstanceId = mrr.InstanceId and cust.MetraNetId = sub.id_acc
where 1=1
group by mrr.InstanceId, mrr.Year, mrr.Month, sub.id_po, mrr.DaysInMonth
;

select @l_count = count(1) from SubscriptionSummary;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Subscription summaries: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating SubscriptionUnits DataMart');
end;

/* NOTE: this is UDRC's not decision counters */
insert into SubscriptionUnits
(	InstanceId,
	SubscriptionId,
	StartDate,
	EndDate,
	UdrcId,
	UdrcName,
	UnitName,
	Units
)
select @p_nm_instance as InstanceId,
rv.id_sub as SubscriptionId,
rv.vt_start as StartDate,
rv.vt_end as EndDate,
bp.id_prop as UdrcId,
isnull(bp.nm_display_name, bp.nm_name) as UdrcName,
IsNull(rc.nm_unit_display_name, rc.nm_unit_name) as UnitName,
rv.n_value as Units
from t_recur_value rv
inner join t_base_props bp on bp.id_prop = rv.id_prop
inner join t_recur rc on rc.id_prop = rv.id_prop
where 1=1
and rv.tt_end = dbo.mtmaxdate()
;

select @l_count = count(1) from SubscriptionUnits;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Subscription units: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating ProductOffering DataMart');
end;

insert into ProductOffering
(	InstanceId,
	ProductOfferingId,
	ProductOfferingName,
	IsUserSubscribable,
	IsUserUnsubscribable,
	IsHidden,
	EffectiveStartDate,
	EffectiveEndDate,
	AvailableStartDate,
	AvailableEndDate)
select
@p_nm_instance as InstanceId,
po.id_po as ProductOfferingId,
IsNull(bp.nm_display_name, bp.nm_name) as ProductOfferingName,
po.b_user_subscribe as IsUserSubscribable,
po.b_user_unsubscribe as IsUserUnsubscribable,
po.b_hidden as IsHidden,
IsNull(eff.dt_start, dbo.mtmindate()) as EffectiveStartDate,
IsNull(eff.dt_end, dbo.mtmaxdate()) as EffectiveEndDate,
IsNull(avl.dt_start, dbo.mtmindate()) as AvailableStartDate,
IsNull(avl.dt_end, dbo.mtmaxdate()) as AvailableEndDate
from t_po po with(nolock)
inner join t_effectivedate eff with(nolock) on eff.id_eff_date = po.id_eff_date
inner join t_effectivedate avl with(nolock) on avl.id_eff_date = po.id_avail
inner join t_base_props bp with(nolock) on bp.id_prop = po.id_po
where 1=1
;

select @l_count = count(1) from SubscriptionUnits;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Product Offerings: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
  INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Generating SubscriptionParticipants DataMart');
end;

select 
@p_nm_instance as InstanceId,
datepart(month,@p_dt_now) as [Month],
datepart(year,@p_dt_now) as [Year],
DATEADD(month, DATEDIFF(month, 0, @p_dt_now), 0) as FirstDayOfMonth,
DATEADD(ss, -1, DATEADD(m, DATEDIFF(m, 0, @p_dt_now) + 1, 0)) as LastDayOfMonth
into #tmp_previous_two_months
;
insert into #tmp_previous_two_months(InstanceId,[Month],[Year],FirstDayOfMonth,LastDayOfMonth)
select 
@p_nm_instance as InstanceId,
datepart(month,dateadd(mm, -1, @p_dt_now)) as [Month],
datepart(year,dateadd(mm, -1, @p_dt_now)) as [Year],
DATEADD(month, DATEDIFF(month, 0,   dateadd(mm, -1, @p_dt_now)), 0) as FirstDayOfMonth,
DATEADD(ss, -1, DATEADD(m, DATEDIFF(m, 0, dateadd(mm, -1, @p_dt_now)) + 1, 0)) as LastDayOfMonth
;
insert into #tmp_previous_two_months(InstanceId,[Month],[Year],FirstDayOfMonth,LastDayOfMonth)
select 
@p_nm_instance as InstanceId,
datepart(month,dateadd(mm, -2, @p_dt_now)) as [Month],
datepart(year,dateadd(mm, -2, @p_dt_now)) as [Year],
DATEADD(month, DATEDIFF(month, 0,   dateadd(mm, -2, @p_dt_now)), 0) as FirstDayOfMonth,
DATEADD(ss, -1, DATEADD(m, DATEDIFF(m, 0, dateadd(mm, -2, @p_dt_now)) + 1, 0)) as LastDayOfMonth
;
insert into SubscriptionParticipants
(	InstanceId,
	ProductOfferingId,
	[Year],
	[Month],
	TotalParticipants,
	DistinctHierarchies,
	NewParticipants,
  UnsubscribedParticipants)
select
months.InstanceId,
sub.id_po as ProductOfferingId,
months.Year,
months.Month,
count(1) as TotalParticipants,
count(distinct cust.HierarchyMetraNetId) as DistinctHierarchies,
sum (case when sub.dt_start >= months.FirstDayOfMonth and sub.dt_start <= months.LastDayOfMonth then 1 else 0 end) as NewParticipants,
sum (case when sub.dt_end >= months.FirstDayOfMonth and sub.dt_end <= months.LastDayOfMonth then 1 else 0 end) as UnsubscribedParticipants
from t_vw_effective_subs sub with(nolock)
inner join Customer cust on cust.MetraNetId = sub.id_acc and cust.InstanceId = @p_nm_instance 
/*was this subscription active during any part of this month?*/
inner join #tmp_previous_two_months months on (sub.dt_end >= months.FirstDayOfMonth and sub.dt_end <= months.LastDayOfMonth) or (sub.dt_start >= months.FirstDayOfMonth and sub.dt_start <= months.LastDayOfMonth) or (sub.dt_start <= months.FirstDayOfMonth and sub.dt_end >= months.LastDayOfMonth)
where 1=1
group by months.InstanceId, months.Year, months.Month, sub.id_po
;

select @l_count = count(1) from SubscriptionParticipants;

if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'SubscriptionParticipants rows: ' + CAST(IsNull(@l_count, 0) AS VARCHAR(64)));
end;


if (@p_id_run is not null)
begin
	INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@p_id_run, @p_dt_now, 'Info', 'Finished generating DataMart');
end;

end;