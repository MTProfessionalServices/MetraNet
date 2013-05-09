sp_help t_account

-------------------------------------------------------------------
-- DDL ------------------------------------------------------------
create table t_acchier (
id_acc int not null,
id_parent int not null,
id_parent_distance int not null)
create CLUSTERED INDEX in_acc on t_acchier(id_acc)


CREATE TABLE t_account_ancestor(id_ancestor INTEGER, id_descendent INTEGER, num_generations INTEGER)

-------------------------------------------------------------------
-------------------------------------------------------------------


drop table t_acchier

select * from t_acchier
delete from t_acchier where id_acc >= 100

-- create a parent parent record.  these records are in the range of 50-100
insert into t_acchier values (50,0,0)

-- create several children records and assign the parent of 50

declare @parent as int
set @parent = 50

insert into t_acchier 
select numbers.n_num,parent.id_parent,parent.id_parent_distance + 1 from 
t_acchier parent,(select n_num from t_num where n_num >= 100 and n_num <= 1000) numbers
 where parent.id_acc = 50 
union all
select t_num.n_num,50,0 from t_num where t_num.n_num >= 100 and t_num.n_num <= 1000

-- create a new parent and promote everyone up the tree (range 25-50)
select * from t_acchier



-- assign the children we just created to the parent 

--- geometric holding pen for numbers 
create table t_num (n_num int,constraint pk_num primary key (n_num))
drop table t_num

delete from t_num
insert into t_num values (1)

declare @i as int
set @i = (select max(n_num) from t_num)
while(@i < 32000) begin
	set @i = (select max(n_num) from t_num)
	insert into t_num select existing.n_num+@i from t_num existing where existing.n_num +@i <= 32000
end


select * from t_num
delete from t_num

select top 200 n_num from t_num


-------------------------------------------------------------------



-- create account hierarchy table
drop table t_account_test
go
drop table t_account_ancestor
go
CREATE TABLE t_account_test(id_acc INTEGER PRIMARY KEY identity(1,1), nm_name VARCHAR(256),id_status INTEGER, 
	dt_start DATETIME default getUTCDate(), dt_end DATETIME default NULL)
go
CREATE TABLE t_account_ancestor(id_ancestor INTEGER, id_descendent INTEGER, num_generations INTEGER)
create index t_account_ancestor_index1 on t_account_ancestor(id_ancestor)
create index t_account_ancestor_index2 on t_account_ancestor(id_descendent)
create index t_account_ancestor_index3 on t_account_ancestor(num_generations)
go
drop procedure AddParent
go

-------------------------------------------------------------------


create procedure AddParent @id_acc int,@ancestor_name varchar(256)
as
SET NOCOUNT ON
insert into t_account_ancestor 
	select id_ancestor,@id_acc,num_generations+1
 		from t_account_ancestor parent_ancestor,t_account_test
	 	where t_account_test.nm_name = @ancestor_name AND parent_ancestor.id_descendent = t_account_test.id_acc AND
		parent_ancestor.id_ancestor <> parent_ancestor.id_descendent
	UNION ALL
	select id_acc,@id_acc,1 from t_account_test where nm_name = @ancestor_name
	UNION ALL
	select @id_acc,@id_acc,0
SET NOCOUNT OFF
go

-------------------------------------------------------------------

go
drop procedure GenHierarchy
go
create procedure GenHierarchy @root as varchar(256)
as
select parent.id_acc parent_id,child.nm_name child,child.id_acc,
	bChildren = case when (select count(id_descendent) from t_account_ancestor where t_account_ancestor.id_ancestor = child.id_acc) > 1
	then 'Y' else 'N' end
	from t_account_ancestor,t_account_test parent,t_account_test child
	where
	parent.nm_name = @root AND 
	t_account_ancestor.id_ancestor = parent.id_acc AND
	child.id_acc = t_account_ancestor.id_Descendent AND
	t_account_ancestor.num_generations = 1
go


exec GenHierarchy 'Account hierarchy Root'
-------------------------------------------------------------------

go
drop procedure MoveAccount
go
create procedure MoveAccount @id_acc int, @id_parent int
as
SET NOCOUNT ON
-- step 1: delete all of the parent records from the account and its
-- children 
delete delete_join
 from t_account_ancestor root_join,t_account_ancestor child_join, t_account_ancestor delete_join
where 
-- parent qualifiers
root_join.id_descendent=@id_acc and root_join.num_generations > 0 and
root_join.id_ancestor=delete_join.id_ancestor and
-- child qualifiers
child_join.id_ancestor=@id_acc and
child_join.id_descendent=delete_join.id_descendent 

-- step 2: delete all of the parents of the root
delete from t_account_ancestor where id_descendent = @id_acc and num_generations > 0
-- step 3: add the new parent records to the child
insert into t_account_ancestor
	select new_parent.id_ancestor,child.id_descendent,
	new_parent.num_generations + child.num_generations + 1 as num_generations
	from 
	t_account_ancestor new_parent,t_account_ancestor child
	where
	-- all of the new parents records
	new_parent.id_descendent = @id_parent AND
	-- children records
	child.id_ancestor = @id_acc


-------------------------------------------------------------------

-- create root node

-- Raju's hierarchy
-- basic users
declare @root as varchar(256)
declare @raju as varchar(256)
declare @carl as varchar(256)
declare @derek as varchar(256)
declare @boris as varchar(256)
declare @travis as varchar(256)
declare @ralf as varchar(256)

set @root = 'Account Hierarchy Root'
set @raju = 'Raju the Remarkable'
set @carl = 'Carl the Curmudgeon'
set @derek = 'Derek the Destructor'
set @travis = 'Travis the Terrible'
set @boris = 'Boris the bombastic'
set @ralf = 'Ralf the Rapacious'

insert into t_account_test (nm_name) values (@root)
insert into t_account_ancestor values (@@identity,@@identity,0)

insert into t_account_test (nm_name) values (@raju)
exec AddParent @@identity,'Account Hierarchy Root'
insert into t_account_test (nm_name) values (@carl)
exec AddParent @@identity,@raju
insert into t_account_test (nm_name) values (@derek)
exec AddParent @@identity,@raju
insert into t_account_test (nm_name) values (@boris)
exec AddParent @@identity,@raju
insert into t_account_test (nm_name) values (@travis)
exec AddParent @@identity,@raju
insert into t_account_test (nm_name) values (@ralf)
exec AddParent @@identity,@raju


exec GenHierarchy 'Raju the Remarkable'
exec GenHierarchy @raju
exec GenHierarchy @carl

exec GenHierarchy 'Account Hierarchy Root'
	
select parent.nm_name parent,child.nm_name child,child.id_acc
	from t_account_ancestor,t_account_test parent,t_account_test child
	where
	parent.nm_name = 'Raju the Remarkable' AND t_account_ancestor.id_ancestor = parent.id_acc AND
	child.id_acc = t_account_ancestor.id_Descendent AND
	t_account_ancestor.num_generations =1 


select * from t_account_test


exec GenHierarchy 'Raju the Remarkable'
exec GenHierarchy 'Ralf the Rapacious'

exec GenHierarchy 'Account hierarchy Root'

select * from t_account_ancestor


exec MoveAccount 7,1
exec MoveAccount 2,7


sp_helptext InsertAccountUsage

   create proc InsertTBar @tx_UID varbinary(16), @id_acc int,    @id_view int, @id_usage_interval int, @id_parent_sess int, @id_svc int,    @dt_session datetime, @amount numeric(18,6), @am_currency varchar(3),    @tax_federal numeric(18,6),
 @tax_state numeric(18,6), @tax_county numeric(18,6),    @tax_local numeric(18,6), @tax_other numeric(18,6), @tx_batch varbinary(16),   @id_prod int, @id_pi_instance int, @id_pi_template int,  @id_sess int OUTPUT as    if (@id_parent_sess = -1)  
 begin   insert 
into t_acc_usage (tx_UID, id_acc, id_view, id_usage_interval,
    id_parent_sess, id_svc, dt_session, amount,
 am_currency, tax_federal, tax_state,   tax_county, tax_local,
 tax_other, tx_batch, id_prod, id_pi_instance, id_pi_template)
 values   (@tx_UID, @id_acc, @id_view, @id_usage_interval,    NULL, @id_svc, @dt_session,
 @amount, @am_currency, @tax_federal, @tax_state,    @tax_county, @tax_local, @tax_other, 
@tx_batch, @id_prod, @id_pi_instance, @id_pi_template)    end   else   begin   insert into t_acc_usage 
(tx_UID, id_acc, id_view, id_usage_interval,    id_parent_sess, id_svc, dt_session, amount, am_currency,
 tax_federal, tax_state,   tax_county, tax_local, tax_other, tx_batch, id_prod, id_pi_instance, id_pi_template) values
   (@tx_UID, @id_acc, @id_view, @id_usage_interval,    @id_parent_sess, @id_svc, @dt_session, @amount,
 @am_currency, @tax_federal, @tax_state,    @tax_county, @tax_local, @tax_other, @tx_batch, @id_prod,
 @id_pi_instance, @id_pi_template)    end   if ((@@error != 0) OR (@@rowcount <> 1))    begin select @id_sess = -99 end select @id_sess = @@identity 


select tb.n_kind template_kind,count(tb.id_prop) num_templates from  
t_pi_template,t_base_props tb where t_pi_template.id_template = tb.id_prop
	group by tb.n_kind

