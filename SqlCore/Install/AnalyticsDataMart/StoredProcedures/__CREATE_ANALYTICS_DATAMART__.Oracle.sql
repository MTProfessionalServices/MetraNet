create or replace
PROCEDURE 
CreateAnalyticsDataMart(p_dt_now date, p_id_run int, p_nm_currency nvarchar2, p_nm_instance nvarchar2, p_n_months int, p_STAGINGDB_prefix nvarchar2)
   AUTHID CURRENT_USER
IS
  l_tmp_tbl varchar2(61);
  l_count number;
  l_billTo number;
BEGIN

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Cleaning out temporary tables');
end if;

l_tmp_tbl := UPPER('tmp_accs');
IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs_linked'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('all_rcs_by_month'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('sum_rcs_by_month'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF; l_tmp_tbl := UPPER('tmp_previous_two_months'); IF (TABLE_EXISTS(l_tmp_tbl)) THEN
    EXEC_DDL('DROP TABLE ' || l_tmp_tbl); END IF;


execute immediate 'create table tmp_accs (id_ancestor int not null, id_descendent int not null)';

execute immediate 'create table all_rcs (InstanceId varchar2(64), SubscriptionId int not null, PayerId int not null, PayeeId int not null, StartDate date, EndDate date, ActionType nvarchar2(255), Currency nvarchar2(3), ProratedDailyRate number(22,10), DailyRate number(22,10), Rate number(22,10), ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, MRR number(22,10))';

execute immediate 'create table all_rcs_linked (InstanceId varchar2(64), SubscriptionId int not null, PayerId int not null, PayeeId int not null, StartDate date, EndDate date, ActionType nvarchar2(255), Currency nvarchar2(3), ProratedDailyRate number(22,10), DailyRate number(22,10), Rate number(22,10), ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, MRR number(22,10), OldRate number(22,10), OldDailyRate number(22,10), OldProratedDailyRate number(22,10), OldSubscriptionStartDate date, OldSubscriptionEndDate date)';

execute immediate 'create table all_rcs_by_month (InstanceId varchar2(64), SubscriptionId int not null, ProductOfferingId int, PriceableItemTemplateId int, PriceableItemInstanceId int, SubscriptionStartDate date, SubscriptionEndDate date, Currency nvarchar2(3), ActionType nvarchar2(255), Year int, Month int, DailyRate number(22,10), Rate number(22,10), OldDailyRate number(22,10), OldRate number(22,10), OldProratedDailyRate number(22,10), OldSubscriptionStartDate date, OldSubscriptionEndDate date, Days int)';

execute immediate 'create table sum_rcs_by_month (InstanceId varchar2(64), SubscriptionId int not null, PriceableItemTemplateId int, PriceableItemInstanceId int, Currency nvarchar2(3), Year int, Month int, DaysInMonth int, DaysActiveInMonth int, TotalAmount number(22,10), OldAmount number(22,10), NewAmount number(22,10))';

execute immediate 'create table tmp_previous_two_months (InstanceId varchar2(64), Year int, Month int, FirstDayOfMonth date, LastDayOfMonth date)';

execute immediate 'create or replace procedure CreateADMInternal (p_dt_now date, p_id_run int, p_nm_currency nvarchar2, p_nm_instance nvarchar2, p_n_months int, p_STAGINGDB_prefix nvarchar2)
   AUTHID CURRENT_USER
IS
BEGIN

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL, sysdate, ''Debug'', ''Starting Analytics DataMart'');
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL, sysdate, ''Debug'', ''Flushing Analytics datamart tables'');
END IF;
end;';

execute immediate ('TRUNCATE TABLE Customer');
execute immediate ('TRUNCATE TABLE SalesRep');
execute immediate ('TRUNCATE TABLE SubscriptionsByMonth');
execute immediate ('TRUNCATE TABLE SubscriptionUnits');
execute immediate ('TRUNCATE TABLE SubscriptionSummary');
execute immediate ('TRUNCATE TABLE CurrencyExchangeMonthly');
execute immediate ('TRUNCATE TABLE ProductOffering');
execute immediate ('TRUNCATE TABLE SubscriptionParticipants');

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating Customers DataMart');
END IF;


/* customers datamart */
insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with root_accts as
(
	select /* corporate accounts */
	a.id_acc
	from t_account a
	inner join t_account_type t on t.id_type = a.id_type
	where 1=1
	and t.b_iscorporate = 1
	and t.b_isvisibleinhierarchy = 1
),
tmp_corps as
(
select
r.id_acc id_ancestor, aa.id_descendent, aa.num_generations
from root_accts r
inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc and p_dt_now between aa.vt_start and aa.vt_end
where 1=1
),
my_gens as
(
	select
	id_descendent, max(num_generations) num_generations
	from tmp_corps
	group by id_descendent
)
select
max(a.id_ancestor) id_ancestor, a.id_descendent
from tmp_corps a
inner join my_gens g on a.id_descendent = g.id_descendent and a.num_generations = g.num_generations
where 1=1
group by a.id_descendent
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	 INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found Corporate Hierarchy Accounts: ' || nvl(l_count, 0));
END IF;

insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with root_accts as
(
	select
	aa.id_descendent id_acc
	from t_account_ancestor aa
	inner join t_account a on a.id_acc = aa.id_descendent
	inner join t_account_type t on t.id_type = a.id_type and (t.b_iscorporate = 0 or t.b_isvisibleinhierarchy = 0)
	where 1=1
	and p_dt_now between aa.vt_start and aa.vt_end
	and aa.id_ancestor = 1
	and aa.num_generations = 1
	and aa.b_children = 'Y'
)
select
r.id_acc id_ancestor, aa.id_descendent
from root_accts r
inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc and p_dt_now between aa.vt_start and aa.vt_end
left outer join tmp_accs a on aa.id_descendent = a.id_descendent
where 1=1
and a.id_descendent is null
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Corporate Hierarchy Accounts, Total Now: ' || nvl(l_count, 0));
END IF;

/* non-corporate nodes without hierarchy */
insert into tmp_accs (id_ancestor, id_descendent)
select
a.id_acc, a.id_acc
from t_account a
left outer join tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa on aa.id_descendent = a.id_acc and p_dt_now between aa.vt_start and aa.vt_end and aa.id_ancestor = 1 and aa.num_generations > 0
where 1=1
and b.id_descendent is null
;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Corporate Non-Hierarchy Accounts, Total Now: ' || nvl(l_count, 0));
END IF;

/* unrooted nodes */
insert into tmp_accs (id_ancestor, id_descendent)
select * from (
with tmp_unrooted as
(
select
aa.id_ancestor, aa.id_descendent, aa.num_generations
from t_account a
left outer join tmp_accs b on a.id_acc = b.id_descendent
inner join t_account_ancestor aa on aa.id_descendent = a.id_acc and p_dt_now between aa.vt_start and aa.vt_end
where 1=1
and b.id_descendent is null
),
my_unrooted as
(
	select id_descendent, max(num_generations) num_generations
	from tmp_unrooted
	group by id_descendent
)
select
b.id_ancestor, b.id_descendent
from my_unrooted a
inner join tmp_unrooted b on a.id_descendent = b.id_descendent and a.num_generations = b.num_generations
where 1=1
) a;

select count(1) into l_count from tmp_accs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Added Non-Rooted Accounts, Total Now: ' || nvl(l_count, 0));
END IF;


select id_enum_data into l_billTo from t_enum_data where upper(nm_enum_data) = 'METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO';

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
from (select
p_nm_instance as InstanceId,
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
substr(ted2.nm_enum_data,20,100) as Country,
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
substr(ted3.nm_enum_data,20,100) as HierarchyCountry,
pav.c_email as HierarchyEmail,
pav.c_phonenumber as HierarchyPhone,
c.dt_crt as StartDate,
case when UPPER(state.status) != 'AC' then state.vt_start else state.vt_end end as EndDate,
DENSE_RANK() OVER (PARTITION BY c.id_acc, p.id_acc ORDER BY cam.nm_space, pam.nm_space) as priority_col		
from tmp_accs r
inner join t_account c on c.id_acc = r.id_descendent
inner join t_account_state state on state.id_acc = c.id_acc
inner join t_account_type ct on ct.id_type = c.id_type
inner join t_account_mapper cam on cam.id_acc = c.id_acc and cam.nm_space not in ('ar')
left outer join t_av_internal cavi on cavi.id_acc = c.id_acc
left outer join t_av_contact cav on c.id_acc = cav.id_acc and cav.c_contactType = l_billTo
left outer join t_enum_data ted2 on ted2.id_enum_data = cav.c_country
inner join t_account p on p.id_acc = r.id_ancestor
inner join t_account_type pt on pt.id_type = p.id_type
inner join t_account_mapper pam on pam.id_acc = p.id_acc and pam.nm_space not in ('ar')
left outer join t_av_internal pavi on pavi.id_acc = p.id_acc
left outer join t_av_contact pav on p.id_acc = pav.id_acc and pav.c_contactType = l_billTo
left outer join t_enum_data ted3 on ted3.id_enum_data = pav.c_country
where 1=1
) a
where 1=1
and a.priority_col = 1;

select count(1) into l_count from Customer;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Customers: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SalesRep DataMart');
END IF;

/* sales reps */
insert into SalesRep
(	InstanceId,
	MetraNetId,
	ExternalId,
	CustomerId,
	Percentage,
	RelationshipType)
select p_nm_instance as InstanceId,
tao.id_owner as MetraNetId,
am.nm_login as ExternalId,
tao.id_owned as CustomerId,
tao.n_percent as Percentage,
substr(ted.nm_enum_data,37, 100) as RelationshipType
from t_acc_ownership tao
inner join t_enum_data ted on ted.id_enum_data = tao.id_relation_type
inner join t_account_mapper am on am.id_acc = tao.id_owner and am.nm_space = 'system_user'
where 1=1
and p_dt_now between tao.vt_start and tao.vt_end
;

select count(1) into l_count from SalesRep;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Sales Reps: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating CurrencyExchangeMonthly DataMart');
END IF;

insert into CurrencyExchangeMonthly
(	InstanceId,
	StartDate,
	EndDate,
	SourceCurrency,
	TargetCurrency,
	ExchangeRate
)
select p_nm_instance,
	nvl(vt_start, dbo.mtmindate()),
	nvl(vt_end, dbo.mtmaxdate()),
	nm_country_source,
	nm_country_target,
	c_Exchange_Rate
from t_vw_adm_exchange_rates
;
select count(1) into l_count from CurrencyExchangeMonthly;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Currency Exchange Rates: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionsByMonth DataMart');
END IF;

insert into all_rcs
(InstanceId,
SubscriptionId,
PayerId,
PayeeId,
StartDate,
EndDate,
ActionType,
Currency,
ProratedDailyRate,
DailyRate,
Rate,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
MRR
)
select * from (
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
from t_sub sub
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance
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
from t_gsubmember mbr
inner join t_sub sub on sub.id_group = mbr.id_group
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'Y'
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
from t_gsubmember mbr
inner join t_sub sub on sub.id_group = mbr.id_group
inner join t_pl_map plm on plm.id_po = sub.id_po and plm.id_paramtable is null and plm.id_sub is null
inner join t_recur tr on tr.id_prop = plm.id_pi_instance and tr.b_charge_per_participant = 'N'
inner join t_gsub_recur_map grm on grm.id_prop = tr.id_prop and grm.tt_end = dbo.mtmaxdate()
where 1=1
)
select
*
from (
select
p_nm_instance as InstanceId,
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
from t_usage_interval tui
inner join t_pv_flatrecurringcharge pv on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
						and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
union all
select
p_nm_instance as InstanceId,
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
from t_usage_interval tui
inner join t_pv_udrecurringcharge pv on tui.id_interval = pv.id_usage_interval
inner join t_acc_usage au on au.id_usage_interval = pv.id_usage_interval and au.id_sess = pv.id_sess
inner join my_pis svc on svc.id_po = au.id_prod and svc.id_pi_template = au.id_pi_template and svc.id_pi_instance = au.id_pi_instance and svc.id_acc = au.id_payee
						and svc.id_sub = pv.c__SubscriptionID
where 1=1
and au.amount <> 0.0
) A
) a;

select count(1) into l_count from all_rcs;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found RCs: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_all_rcs on all_rcs (InstanceId, SubscriptionId, PayeeId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate, ActionType, Currency)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for RC linkage');
END IF;

insert into all_rcs_linked
(InstanceId,
SubscriptionId,
PayerId,
PayeeId,
StartDate,
EndDate,
ActionType,
Currency,
ProratedDailyRate,
DailyRate,
Rate,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
MRR,
OldRate,
OldDailyRate,
OldProratedDailyRate,
OldSubscriptionStartDate,
OldSubscriptionEndDate
)
select
crc.*,
prc.Rate as OldRate,
prc.DailyRate as OldDailyRate,
prc.ProratedDailyRate as OldProratedDailyRate,
prc.SubscriptionStartDate as OldSubscriptionStartDate,
prc.SubscriptionEndDate as OldSubscriptionEndDate
from all_rcs crc
left outer join all_rcs prc on  crc.InstanceId = prc.InstanceId
                             and crc.SubscriptionId = prc.SubscriptionId
                             and crc.PayeeId = prc.PayeeId
                             and crc.PriceableItemTemplateId = prc.PriceableItemTemplateId
                             and crc.PriceableItemInstanceId = prc.PriceableItemInstanceId
							 and crc.Currency = prc.Currency
                             and prc.EndDate = crc.StartDate - (1/(24*60*60))
                             and prc.ActionType = crc.ActionType
                             and crc.ActionType IN ('Advance','Arrears')
where 1=1
;

select count(1) into l_count from all_rcs_linked;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found Linked RCs: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_all_rcs_linked on all_rcs_linked (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, StartDate, EndDate)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for linked RCs');
END IF;

insert into all_rcs_by_month
(
InstanceId,
SubscriptionId,
ProductOfferingId,
PriceableItemTemplateId,
PriceableItemInstanceId,
SubscriptionStartDate,
SubscriptionEndDate,
Currency,
ActionType,
Year,
Month,
DailyRate,
Rate,
OldDailyRate,
OldRate,
OldProratedDailyRate,
OldSubscriptionStartDate,
OldSubscriptionEndDate,
Days
)
select
*
from
(
WITH MONTHS AS (
  SELECT LEVEL-1 AS num
  FROM DUAL 
  CONNECT BY LEVEL <= 12
)
select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.ProductOfferingId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.SubscriptionStartDate,
rcs.SubscriptionEndDate,
rcs.Currency,
case when months.num <> 0 then to_nchar('NotInitial') else rcs.ActionType end as ActionType,
extract(year from add_months(rcs.startdate, months.num)) as Year,
extract(month from add_months(rcs.startdate, months.num)) as Month,
rcs.DailyRate,
rcs.Rate,
rcs.OldDailyRate,
rcs.OldRate,
rcs.OldProratedDailyRate,
rcs.OldSubscriptionStartDate,
rcs.OldSubscriptionEndDate,
case when months_between(trunc(rcs.enddate,'mon'), trunc(rcs.startdate,'mon')) = months.num then extract(day from rcs.enddate) - case when months.num = 0 then (extract(day from rcs.startdate) - 1) else 0 end
	 else case when extract(month from add_months(rcs.startdate, months.num)) in (4,6,9,11) then 30
	           when extract(month from add_months(rcs.startdate, months.num)) = 2 then case when mod(extract(year from add_months(rcs.startdate, months.num)), 400) = 0 then 29
																					  when mod(extract(year from add_months(rcs.startdate, months.num)), 100) = 0 then 28
																					  when mod(extract(year from add_months(rcs.startdate, months.num)), 4)   = 0 then 29
																					  else 28
																				 end
			   else 31
		  end
		  - case when months.num <> 0 then 0
				 else (extract(day from rcs.startdate) - 1)
			end
end as Days
from all_rcs_linked rcs
inner join months on months.num between 0 and months_between(trunc(rcs.enddate,'mon'), trunc(rcs.startdate,'mon'))
where 1=1
) a;

select count(1) into l_count from all_rcs_by_month;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Found RCs by month: ' || nvl(l_count, 0));
END IF;

insert into sum_rcs_by_month
(
InstanceId,
SubscriptionId,
PriceableItemTemplateId,
PriceableItemInstanceId,
Currency,
Year,
Month,
DaysInMonth,
DaysActiveInMonth,
TotalAmount,
OldAmount,
NewAmount
)
select
rcs.InstanceId,
rcs.SubscriptionId,
rcs.PriceableItemTemplateId,
rcs.PriceableItemInstanceId,
rcs.Currency,
rcs.Year,
rcs.Month,
case when rcs.Month in (4,6,9,11) then 30 when rcs.Month = 2 then case when mod(rcs.Year, 400) = 0 then 29 when mod(rcs.Year, 100) = 0 then 28 when mod(rcs.Year, 4) = 0 then 29 else 28 end else 31 end as DaysInMonth,
max(rcs.Days) as DaysActiveInMonth,
sum(cast(rcs.DailyRate*rcs.Days as numeric(18,6))) as TotalAmount,
sum(case when rcs.OldRate is null then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
		 when rcs.Rate = rcs.OldRate then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         when rcs.DailyRate = 0 then cast(rcs.DailyRate*rcs.Days as numeric(18,6))
         else cast((rcs.DailyRate*rcs.Days)*(cast(rcs.OldRate/rcs.Rate as numeric(29,17))) as numeric(18,6))
    end) as OldAmount,
sum(case when rcs.OldSubscriptionEndDate is null then rcs.DailyRate*rcs.Days else 0 end) as NewAmount
from all_rcs_by_month rcs
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

select count(1) into l_count from sum_rcs_by_month;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Summarized RCs by month: ' || nvl(l_count, 0));
END IF;

execute immediate 'create index idx_monthly_rcs on sum_rcs_by_month (InstanceId, SubscriptionId, PriceableItemTemplateId, PriceableItemInstanceId, Year, Month, Currency)';

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for summarized subscriptions');
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Debug', 'Created index for exchange rates');
END IF;

insert into SubscriptionsByMonth
(	InstanceId,
	SubscriptionId,
	Year,
	Month,
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
	cMonth.TotalAmount*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPrimaryCurrency,
	cMonth.NewAmount as MRRNew,
	cMonth.NewAmount*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRNewPrimaryCurrency,
	nvl(pMonth.TotalAmount,0) as MRRBase,
	nvl(pMonth.TotalAmount,0)*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRBasePrimaryCurrency,
	0 as MRRRenewal,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRRenewalPrimaryCurrency,
	(cMonth.TotalAmount - cMonth.OldAmount) as MRRPriceChange,
	(cMonth.TotalAmount - cMonth.OldAmount)*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRPriceChangePrimaryCurrency,
	0 as MRRChurn,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRChurnPrimaryCurrency,
	0 as MRRCancelation,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as MRRCancelationPrimaryCurrency,
	0 as SubscriptionRevenue,
	0*(case when p_nm_currency <> cMonth.Currency then exc.ExchangeRate else 1.0 end) as SubscriptionRevPrimaryCurrency,
	cMonth.DaysInMonth,
	cMonth.DaysActiveInMonth,
	p_nm_currency
from sum_rcs_by_month cMonth
left outer join sum_rcs_by_month pMonth on  cMonth.InstanceId = pMonth.InstanceId
										 and cMonth.SubscriptionId = pMonth.SubscriptionId
										 and cMonth.PriceableItemTemplateId = pMonth.PriceableItemTemplateId
										 and cMonth.PriceableItemInstanceId = pMonth.PriceableItemInstanceId
										 and cMonth.Currency = pMonth.Currency
										 and case when cMonth.Month = 1 then cMonth.Year - 1 else cMonth.Year end = pMonth.Year
										 and case when cMonth.Month = 1 then 12 else cMonth.Month - 1 end = pMonth.Month
left outer join CurrencyExchangeMonthly exc on exc.InstanceId = cMonth.InstanceId and exc.SourceCurrency = cMonth.Currency and exc.TargetCurrency = p_nm_currency and p_dt_now between exc.StartDate and exc.EndDate
where 1=1
;

select count(1) into l_count from SubscriptionsByMonth;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscriptions by month: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionSummary DataMart');
END IF;

insert into SubscriptionSummary
(	InstanceId,
	ProductOfferingId,
	Year,
	Month,
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
sum(case when (p_dt_now - sub.vt_start) <= 30 then 1 else 0 end) as NewParticipants,
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
inner join t_sub sub on sub.id_sub = mrr.SubscriptionId
inner join Customer cust on cust.InstanceId = mrr.InstanceId and cust.MetraNetId = sub.id_acc
where 1=1
group by mrr.InstanceId, mrr.Year, mrr.Month, sub.id_po, mrr.DaysInMonth
;

select count(1) into l_count from SubscriptionSummary;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscription summaries: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionUnits DataMart');
END IF;

/* NOTE: this is UDRC''s not decision counters */
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
select p_nm_instance as InstanceId,
rv.id_sub as SubscriptionId,
rv.vt_start as StartDate,
rv.vt_end as EndDate,
bp.id_prop as UdrcId,
nvl(bp.nm_display_name, bp.nm_name) as UdrcName,
nvl(rc.nm_unit_display_name, rc.nm_unit_name) as UnitName,
rv.n_value as Units
from t_recur_value rv
inner join t_base_props bp on bp.id_prop = rv.id_prop
inner join t_recur rc on rc.id_prop = rv.id_prop
where 1=1
and rv.tt_end = dbo.mtmaxdate()
;

select count(1) into l_count from SubscriptionUnits;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Subscription units: ' || nvl(l_count, 0));
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating ProductOffering DataMart');
END IF;

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
p_nm_instance as InstanceId,
po.id_po as ProductOfferingId,
nvl(bp.nm_display_name, bp.nm_name) as ProductOfferingName,
po.b_user_subscribe as IsUserSubscribable,
po.b_user_unsubscribe as IsUserUnsubscribable,
po.b_hidden as IsHidden,
nvl(eff.dt_start, dbo.mtmindate()) as EffectiveStartDate,
nvl(eff.dt_end, dbo.mtmaxdate()) as EffectiveEndDate,
nvl(avl.dt_start, dbo.mtmindate()) as AvailableStartDate,
nvl(avl.dt_end, dbo.mtmaxdate()) as AvailableEndDate
from t_po po
inner join t_effectivedate eff on eff.id_eff_date = po.id_eff_date
inner join t_effectivedate avl on avl.id_eff_date = po.id_avail
inner join t_base_props bp on bp.id_prop = po.id_po
where 1=1
;

select count(1) into l_count from SubscriptionUnits;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Product Offerings: ' || nvl(l_count, 0));
  INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Generating SubscriptionParticipants DataMart');
END IF;

insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select 
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,0)) as Month,
extract(year from ADD_MONTHS(p_dt_now,0)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,0),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,1),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select 
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,-1)) as Month,
extract(year from ADD_MONTHS(p_dt_now,-1)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,-1),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,0),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into tmp_previous_two_months(InstanceId,Month,Year,FirstDayOfMonth,LastDayOfMonth)
select 
p_nm_instance as InstanceId,
extract(month from ADD_MONTHS(p_dt_now,-2)) as Month,
extract(year from ADD_MONTHS(p_dt_now,-2)) as Year,
TRUNC(ADD_MONTHS(p_dt_now,-2),'MON') as FirstDayOfMonth,
TRUNC(ADD_MONTHS(p_dt_now,-1),'MON')-1/60/60/24 as LastDayOfMonth
from dual
;
insert into SubscriptionParticipants
(	InstanceId,
	ProductOfferingId,
	Year,
	Month,
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
from t_vw_effective_subs sub
inner join Customer cust on cust.MetraNetId = sub.id_acc and cust.InstanceId = p_nm_instance 
/*was this subscription active during any part of this month?*/
inner join tmp_previous_two_months months on (sub.dt_end >= months.FirstDayOfMonth and sub.dt_end <= months.LastDayOfMonth) or (sub.dt_start >= months.FirstDayOfMonth and sub.dt_start <= months.LastDayOfMonth) or (sub.dt_start <= months.FirstDayOfMonth and sub.dt_end >= months.LastDayOfMonth)
where 1=1
group by months.InstanceId, months.Year, months.Month, sub.id_po
;

select count(1) into l_count from SubscriptionParticipants;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'SubscriptionParticipants rows: ' || nvl(l_count, 0));
END IF;

if (p_id_run is not null) then
	INSERT INTO t_recevent_run_details (id_run, id_detail, dt_crt, tx_type, tx_detail) VALUES (p_id_run, seq_t_recevent_run_details.NEXTVAL,sysdate, 'Info', 'Finished generating DataMart');
END IF;

end;
