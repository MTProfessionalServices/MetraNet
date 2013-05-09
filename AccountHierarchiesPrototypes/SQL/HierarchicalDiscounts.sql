

-- HD with ad-hoc discount group.


/*

Open questions:

What is the effective interval on when someone can leave and join an ad-hoc discount hierarchy?


*/


/*
 steps:

Find all of the members of the discount group.
New members can join the discount group but only at billing cycle boundaries

Join in the tables that are use to qualify the discount
Join in the tables that are used for the discount target

-- qualifier could be number of fax pages
-- target is total rated amount of all fax page usage charges
-- distribution is proportional

Goals:
Generate the qualifer amount for all accounts that are contributing
Generate the target amount for accounts that are contributing (optional)

Generate the fixed distribution amount  (if distributing discounts)
Generate the proportional distribution amount (if using proportional distribution)


Given a particular HD in a product offering, it will have a single rate for a HD
This rate can be passed into the query that determines the discount.

1) lookup all HD discounts sorted by product offering
2) For each HD discount template, meter a session for a particular product offering
3) Compute the qualifier & targets for the PO
4) Lookup the rate for the product offering given the qualifier. (remember, these are tiered discounts)

5a) proportional percentage distribution: generate all the discount records for each contributing account,
applying the percentage.  This could be modelled as a insert into select from.

5b) proportional flat rate distribution: Compute the account percentage that contributed to the qualifer and 
multiply it by the flat amount. This could be modelled as a insert into select from.

5c) fixed percentage distribution: Calculate the rated amount of all accounts contributing to the discount.  
Apply the percentage to this amount.  Divide this amount by the total number of contributors and store records for each account.  
This could be a query followed by a insert into select from.

5d) fixed flat amount distribution: divide the flat amount by the total number of contributors.  Generate a
record with this amount for each contributing user.  This could be modelled as an insert into select from.

5) Assume their is no target, rather it is a percent or flat discount
6) 



*/



/*

What is the subscription like metaphor for HD's and HAPI's??????? 


1) The CSR needs to go to the HD subscription and manage the group membership.
2) The CSR needs to see who contributes to the discount (subordinate or group)
3) HD's and HAPI's are fundamentally different and are not normal product offerings
4) HD's and HAPI's have explicit rules around who is that only folders (or accounts that contain children) may subscribe


Some names:
Group Offerings
Union offering
Confederate discount


Is there a concept of a group subscription?

a) Group is subscribed to a product offering.  ICB rates are only against the group.
b) Who can administer the group rates??? group administrator or any CSR. at some
level there should be a warning that you are administering group rates.
c) The CSR should be able to see the group subscriptions as seperate from normal subscriptions
d) 


Don't want to duplicate the grouping.... therefore there is the concept of having a group subscription that 
contains HD's and HAPIs as well as non recurring charge, recurring charges, usage, etc.  All the stuff
that is part of a normal subscription.

Remember, the hard part is managing the group!!

Is it a group subscription or a "subscribable group?"

Does it make more sense to identify to call out a group and then assign a bunch of stuff to it?
For instance, 


account groups have an effective dates on group membership.


What are the rules for group subscriptions:

The group subscription conflict rules are the same as normal subscriptions




*/


sp_help t_account_ancestor


drop table t_account_group
go
create table t_account_group (
 id_group int identity(1,1) PRIMARY KEY,
 b_subordinate char(1) NOT NULL,
 nm_name varchar(256) not null UNIQUE,
 nm_display_name varchar(256),
 b_visable char(1) NOT NULL,
 CONSTRAINT t_account_group_check1 CHECK (b_subordinate = 'Y' OR b_subordinate = 'N'),
 CONSTRAINT t_account_group_check2 chECK (b_visable = 'Y' OR b_visable = 'N')
)


-- remove unused foreign keys

insert into t_sub (id_acc,id_eff_date,id_po,id_group) values (NULL,144,92,NULL)


--proposed changes for the t_sub table

sp_help t_sub
select * from t_sub
select * from t_effectivedate where id_eff_date = 51
select * from t_sub_backup
update t_sub_backup set id_eff_date = 206
alter table t_sub drop t_sub_constraint_1


select * from t_sub_backup,t_effectivedate te where te.id_eff_date = t_sub_backup.id_eff_date

alter table t_sub add  id_eff_date int

-- drop t_base_props reference
alter table t_sub drop t_sub_FK1
-- remove the b_active flag
alter table t_sub drop column b_active
-- temporarily remove the foreign key on t_pl_map
alter table t_pl_map drop t_sub_t_pl_map_FK1
-- drop the PK
alter table t_sub drop t_sub_pk
-- backup all the data into another column
select * into t_sub_backup from t_sub
-- drop the data
truncate table t_sub
-- drop the effective date reference
go
alter table t_sub drop t_effectivedate_t_sub_FK1
alter table t_sub drop column id_eff_date
alter table t_sub add vt_start datetime
alter table t_sub add vt_end datetime
-- make the t_sub table support identity columns

go
alter table t_sub drop column id_sub
go
alter table t_sub add id_sub int identity(1,1) PRIMARY KEY
go
declare @max_id as int
select @max_id = MAX(id_sub)+1 from t_sub_backup
DBCC CHECKIDENT ('t_sub', reseed,@max_id)
-- add the data back to the t_sub table
set IDENTITY_INSERT t_sub ON
insert into t_sub (id_acc,id_po,dt_crt,id_sub,vt_start,vt_end) 
select id_acc,id_po,dt_crt,id_sub,
te.dt_start,
dt_end = case when te.dt_end is NULL then dbo.MTMaxDate() else te.dt_end end
from t_sub_backup,t_effectivedate te where t_sub_backup.id_eff_date = te.id_eff_date
set IDENTITY_INSERT t_sub OFF

-- add grouping support
alter table t_sub add id_group int NULL
alter table t_sub add constraint t_sub_t_account_group_fk FOREIGN KEY (id_group) references t_account_group(id_group)
-- recreate the foreign key for t_pl_map
alter table t_pl_map add constraint t_sub_t_pl_map_FK1 foreign key (id_sub) references t_sub (id_sub)  
-- drop the backup table
drop table t_sub_backup
-- change id_acc to be null able
alter table t_sub  ALTER COLUMN id_acc int NULL
-- add a constraint so that both id_ACC and id_group can not be NULL
alter table t_sub add constraint t_sub_constraint_1 CHECK ((id_acc is not NULL AND id_group is NULL) OR (id_acc is NULL and id_group is not NULL))

select * from t_sub_backup

----------------------------------------------------------------------------------
-- group list table

drop table t_account_grouplist

create table t_account_grouplist (id_group int,
	id_acc int not NULL,
	b_subordinate char(1) default 'N',
	vt_start datetime not NULL default dbo.MTMinDate(),
	vt_end datetime not NULL default dbo.MTMaxDate(),
	tt_start datetime default GetUTCDate(),
	tt_end datetime default dbo.MTMaxDate(),
--	constraint t_account_grouplist_fk1 FOREIGN KEY (id_acc) references t_account_ancestor(id_descendent),
	constraint t_account_grouplist_check1 CHECK (b_subordinate = 'Y' OR b_subordinate = 'N'),
	constraint t_account_grouplist_fk2 FOREIGN KEY (id_group) references t_account_group(id_group)
)

----------------------------------------------------------------------------------

insert into t_account_group (b_subordinate,nm_name,nm_display_name) values ('N','random accounts','Random Account Group List')

insert into t_account_grouplist (id_group,id_acc)
	select
	1,n_num
	from t_random where n_num > 0 AND n_num <= 100


create index t_account_grouplist_idx1 on t_account_grouplist(id_group)


select * from t_account_group tg ,t_account_grouplist tgl where tg.id_group = tgl.id_group

delete from t_account_grouplist
	

select max(n_num) from t_random






sp_helptext GenHierarchyOnAcc


create procedure GenHierarchyOnAcc @id_acc as int  
as  
select @id_acc parent_id,child.nm_name child,child.id_acc,  
 bChildren = case when (select count(id_descendent) from t_account_ancestor   
 where t_account_ancestor.id_ancestor = child.id_acc AND t_account_ancestor.num_generations = 1) > 1  
 then 'Y' else 'N' end  
 from t_account_ancestor,t_account_test child  
 where  
 t_account_ancestor.id_ancestor = @id_acc AND  
 child.id_acc = t_account_ancestor.id_Descendent AND  
 t_account_ancestor.num_generations = 1  


sp_help t_account_mapper



select * from t_account,t_account_mapper where t_account.id_acc = t_account_mapper.id_acc


-----------------------------------------------------------------------------------
-- a sample hierarchical discount

drop proc LookupHDQualifier_forHDTypeXXX

create proc LookupHDQualifier_forHDTypeXXX(@id_pi_template int,@dt_start datetime,@dt_end datetime)
as

-- step : determine the list of subscriptions to the HD

-- step : for each subscription, find the account list and build a query
-- using the counter to determine the qualifiers.  Use the group subscription to identify
-- the ICB rates.

-- hmm.... does the group account have a cycle ID??? 

-- step : determine the rate schedule (information required:  @id_acc
-- @acc_cycle_id
-- @default_pl
-- @RecordDate
--@id_pi_template) ----------XXXX hmm..... seems like we need to something
-- different for account groups.... we don't really have an account or cycle ID.
-- You also can't really have billing cycle relative effective dates for group subscriptions.

-- step : figure out the rate from the parameter table (perhaps call generated rate lookup stored
-- proceure??

-- step : Generate the discount amount

-- step : If using 100% to parent, find who the parent is in the group

-- step : apply the rate to the hierarchy or proportional to everyone

-- step : redirect the discount?? (either on an individual basis or the 100% to parent)
-- (requires paying account ID, paying account billing cycle)

-- step : insert the t_acc_usage information (id_acc,id_view,id_usage_interval,id_prod,id_svc,amount,currency,
-- instance, template

-- step : insert the productview data (do I get the id_sess by doing an insert into select from 
-- from t_acc_usage based on the batch ID??)

-----------------------------------------------------------------

-- alternative approach using the pipeline

-- step : calculate the amount to determine the discount based on the group list and 
-- the counter information.


-- if the discount is configured to distribute 100% to the parent, only meter one record to
-- the pipeline.  The rated is computed once.

-- if the discount is configured for proportional distribution, meter in all the contributing accounts.
-- the discount target is also metered in which is used to determine the rate.  Note that the rate
-- is calculated for each user (althrough it should always be the same).


select * from t_pi_template ,t_base_props tb where id_template = id_prop

select * from t_discount
select * from t_aggregate


select * from t_sub


insert into t_account_group (b_subordinate,nm_name,nm_display_name,b_visable) values ('N','test group','test group display name','Y')
select @@identity
insert into t_account_grouplist values (1,124,'N',GetUTCDate(),dbo.MTMaxDate(),GetUTCDate(),dbo.MTMaxDate())

select * from t_account_group tg,t_account_grouplist tgl
where 
tg.id_group = tgl.id_group


select * from t_sub
sp_help t_effectivedate

select * from t_effectivedate
insert into t_effectivedate (n_begintype,dt_start,n_endtype,dt_end) values (1,getUTCDate(),4,NULL)
insert into t_sub (id_eff_date,id_po,id_group) values (206,92,1)

-- how do we do both single account and group resolution
--------------------------------------------------------------------------------------

select id_acc from t_sub,t_effectivedate te where id_po = 92 AND 
	te.dt_start <= GetUTCDate() AND id_group is NULL AND
	te.id_eff_date = t_sub.id_eff_date
UNION ALL
select tgl.id_acc id_acc from 
t_sub,t_effectivedate te,t_account_grouplist tgl where t_sub.id_group is not NULL
AND te.dt_start <= GetUTCDate() AND te.id_eff_date = t_sub.id_eff_date  AND
tgl.id_group = t_sub.id_group AND id_po = 92



----------------------------------------------------------------------------------------

select * from t_account_grouplist
update t_sub set id_group = 1 where id_acc is NULL


select * from t_sub
update t_sub set vt_start = GetUTCDate() - 1 where id_group = 1

--------------------------------------------------------------
-- best query for finding dates


select 
id_acc = case when sub.id_group is NULL then sub.id_acc else tgl.id_acc end
from
t_sub as sub
LEFT OUTER JOIN t_account_grouplist tgl on tgl.id_group = sub.id_group AND tgl.vt_start <= GetUTCDate()
where
sub.vt_start <= GetUTCDate() AND sub.id_po = 92 




----------------------------------------------------------------------------------------
-- view for subscriptions

select * from t_sub

select * from t_sub

drop view vw_all_sub
go
create view vw_all_sub as
select id_acc = case when sub.id_group is NULL then sub.id_acc else tgl.id_acc end,
id_po,id_sub,dt_crt,
sub.vt_start,sub.vt_end,
membership_start = case when sub.id_group is NULL then sub.vt_start else tgl.vt_start end,
membership_end = case when sub.id_group is NULL then sub.vt_end else tgl.vt_end end 
from
t_sub as sub
LEfT OUTER JOIN t_account_grouplist tgl on tgl.id_group = sub.id_group

select * from vw_all_sub

select NEWID()

select * from t_sub

----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------



select * from vw_all_sub where dt_start <= GetutCDate() AND GetUTCDate() < dt_end AND 
vt_start <= GetUTCDate() AND GetUTCDate() < vt_end AND id_po = 92


select * from t_account_grouplist
insert into t_account_grouplist values (1,125,'N',GetuTCDate()-100,GetUTCDate() -50,GetuTCDate()-100,dbo.MTMaxDate())

sp_help 


sp_help t_account_group
sp_help t_account_grouplist

select * from t_account


select * from t_description where id_desc = 307












-----------------------------------------------------------------


drop proc GetRateFrom_t_pt_flatrate
go
create proc GetRateFrom_t_pt_flatrate(@id_po_sched int,
	@id_pl_sched int,
	@id_ICB_sched int,
	-- generated inputs
	@c_totalBytes_in numeric(18,9),
	-- generated outputs
	@c_totalSongs_in numeric(18,9),
	@c_rate_out numeric(18,9) OUTPUT,
	@c_ConnectionFee_out numeric(18,9) OUTPUT)
as

	select @c_rate_out = list.c_rate,@c_ConnectionFee_out = list.c_ConnectionFee
	from (
		select  TOP 1 id_sched,n_order,
		rank = case id_sched 
			-- pricelist chaining rules would mean that we would
			-- omit either po & default PL or just default PL
			when @id_ICB_sched then 1 -- ICB
			when @id_po_sched then 2 -- PO
			when @id_pl_sched then 3 -- default account PL
			else 10
		end,
		c_rate,c_ConnectionFee
		from t_pt_songdownloads 
		where
		-- static rules
		@c_totalBytes_in < c_TotalBytes AND
		-- dynamic rules
		(c_totalSongs_op = '<' AND @c_totalSongs_in < c_TotalSongs) OR
		(c_totalSongs_op = '>' AND @c_totalSongs_in > c_TotalSongs) OR
		(c_totalSongs_op = '<=' AND @c_totalSongs_in <= c_TotalSongs) OR
		(c_totalSongs_op = '>=' AND @c_totalSongs_in >= c_TotalSongs) OR
		(c_totalSongs_op = '!=' AND @c_totalSongs_in <> c_TotalSongs) AND
		id_sched in (@id_po_sched,@id_pl_sched,@id_ICB_sched)
	--	group by id_sched
		order by n_order,rank
		) list


sp_help t_pt_songdownloads

-- end sproc
-----------------------------------------------------------------


-- test the stored procedure

select * from t_pt_songdownloads

declare @id_po_sched int
declare @id_pl_sched int
declare @id_ICB_sched int
declare @bytesin numeric(18,9)
declare @c_totalSongs numeric(18,9)
declare @rate numeric(18,9)
declare @connectionfee numeric(18,9)

set @id_po_sched = NULL	
set @id_pl_sched = null
set @id_ICB_sched = 202

set @bytesin = 800000
set @c_totalSongs = 4

exec GetRateFrom_t_pt_flatrate @id_po_sched,@id_pl_sched,@id_ICB_sched,@bytesin,@c_totalSongs,
	@c_rate_out = @rate OUTPUT,@c_ConnectionFee_out = @connectionfee OUTPUT
select @rate,@connectionfee


--------------------------------------------------------------------------

select * from t_pt_songdownloads

-- query that returns the best rates for the given paramtable and rate schedules

declare @bytesin decimal
declare @c_totalSongs decimal

set @bytesin = 80000
set @c_totalSongs = 4


	select /*TOP 1 id_sched */ n_order,/*MIN(n_order) n_order,*/
	rank = case id_sched 
		-- pricelist chaining rules would mean that we would
		-- omit either po & default PL or just default PL
		when 202 then 1 -- ICB
		when NULL then 2 -- PO
		when NULL then 3 -- default account PL
		else 10
	end,
	c_rate,c_ConnectionFee

	from t_pt_songdownloads 
	where
	-- static rules
	@bytesin < c_TotalBytes AND
	-- dynamic rules
	(c_totalSongs_op = '<' AND @c_totalSongs < c_TotalSongs) OR
	(c_totalSongs_op = '>' AND @c_totalSongs > c_TotalSongs) OR
	(c_totalSongs_op = '<=' AND @c_totalSongs <= c_TotalSongs) OR
	(c_totalSongs_op = '>=' AND @c_totalSongs >= c_TotalSongs) OR
	(c_totalSongs_op = '!=' AND @c_totalSongs <> c_TotalSongs) AND
	id_sched in (NULL,NULL,202) 

--	group by id_sched
	order by n_order,rank

declare @id_ICB_sched as int
declare @id_po_sched as int
declare @id_pl_sched as int
declare @c_rate_out as numeric(16,9)
declare @c_ConnectionFee_out as numeric(16,9)
declare @c_totalBytes_in as numeric(16,9)
declare @c_totalSongs_in as numeric(16,9)

set @id_ICB_sched = 202
set @id_po_sched = NULL
set @id_pl_sched = NULL


set @c_totalBytes_in = 800000
set @c_totalSongs_in = 4

	select @c_rate_out = list.c_rate,@c_ConnectionFee_out = list.c_ConnectionFee
	from (
		select  TOP 1 id_sched,n_order,
		rank = case id_sched 
			-- pricelist chaining rules would mean that we would
			-- omit either po & default PL or just default PL
			when @id_ICB_sched then 1 -- ICB
			when @id_po_sched then 2 -- PO
			when @id_pl_sched then 3 -- default account PL
		end,
		c_rate,c_ConnectionFee
		from t_pt_songdownloads 
		where
		-- static rules
		@c_totalBytes_in < c_TotalBytes AND
		-- dynamic rules
		(c_totalSongs_op = '<' AND @c_totalSongs_in < c_TotalSongs) OR
		(c_totalSongs_op = '>' AND @c_totalSongs_in > c_TotalSongs) OR
		(c_totalSongs_op = '<=' AND @c_totalSongs_in <= c_TotalSongs) OR
		(c_totalSongs_op = '>=' AND @c_totalSongs_in >= c_TotalSongs) OR
		(c_totalSongs_op = '!=' AND @c_totalSongs_in <> c_TotalSongs) AND
		id_sched in (@id_po_sched,@id_pl_sched,@id_ICB_sched)
	--	group by id_sched
		order by n_order,rank
		) list

select @c_rate_out,@c_ConnectionFee_out


update t_pl_map set b_canICB = 'Y'



--	group by
--	id_sched,c_rate,c_connectionfee,n_order


--	order by id_sched,n_order)

---

select * from 





@c_totalBytes_in = @bytesin OUTPUT,
	@c_totalSongs_in = @c_totalsongs 


select * from t_pt_songdownloads

sp_help GetRateFrom_t_pt_flatrate
--------------------------------------------------------------------------

select GetUTCDate()
declare @cdate as datetime
declare @var as varchar(256)
set @cdate = '2001-11-08 18:38:33.840'


exec sp_executesql N'if(GetUTCDate() > @cdate)  begin 
	select ''hi''
end',
N'@cdate datetime',@cdate = '2001-11-08 18:38:33.840'

113,133



select * from t_sub


select distinct(id_pi_template) from t_pl_map where id_po = 92

sp_help GetRateSchedules

select * from t_acc_usage_cycle
select * from t_av_internal

declare @cdate as datetime
set @cdate = GetUTCDate()
exec GetRateSchedules 123,30,104,@cdate,67


sp_help t_acc_usage




-- run the qualifiers through the pcrate plugin

sp_help t_acc_usage

select * from t_pt_ldrate

select * from t_rulesetdefinition,t_base_props tb where tb.id_prop = id_paramtable

select * from t_pt_rateconn


select * from t_pt_percentdiscount where id_sched = 127 order by n_order asc

sp_executesql N'select * from t_effectivedate'

sp_executesql N' 
declare @var as int
declare @name as varchar(256)
set @var = 1
select @name = nm_name from t_base_props where id_prop = @var
if @name = ''metratech.com/basetransportrate'' begin
	select ''We Win!!''	
end

'

declare @var as int
declare @name as varchar(256)
set @var = 1
select @name = nm_name from t_base_props where id_prop = @var
if @name = 'metratech.com/basetransportrate' begin
	select 'We Win!!'	
end

select * from t_base_props

sp_executesql N'






