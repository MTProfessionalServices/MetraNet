
create function MTRangeCheck(@start as datetime,@end as datetime,@check as datetime) returns char(1)
as
begin
	if @check <= @start AND @check < @end begin
		return 'Y'
	end
	return 'N'
end
go

s


select DATEPART(m,vt_start) + '-' + DATEPART(d,vt_start) + '-' + DATEPART(y,vt_start) from t_account_ancestor

select distinct(DATEPART(vt_start)) from t_account_ancestor


CREATE RULE range_rule
AS 
@range >= $1000 AND @range < $20000

create rule boolean_rule
as
@boolean = 'N' OR @boolean =  'Y'

sp_addtype 'boolean','char(1)', 'NOT NULL',default


sp_bindrule 'boolean_rule','boolean'

declare @foo as boolean
set @foo = 1

drop table t_foo


drop function MTMaxDate
go
create function MTMaxDate() returns datetime
as
begin
	return '9999'
end
go
drop function MTMinDate
go
create function MTMinDate() returns datetime
as
begin
	return '1753'
end
go
-------------------------------------------------------
-- DDL
drop table t_account_ancestor
go
CREATE TABLE t_account_ancestor(
	id_key INTEGER identity(1,1) PRIMARY KEY,
	id_ancestor INTEGER,
	id_descendent INTEGER, 
	num_generations INTEGER,
	vt_start datetime not NULL default dbo.MTMinDate(),
	vt_end datetime not NULL default dbo.MTMaxDate(),
	tt_start datetime default GetUTCDate(),
	tt_end datetime default dbo.MTMaxDate()
)
go

create index t_account_ancestor_index1 on t_account_ancestor(id_ancestor)
go
create index t_account_ancestor_index2 on t_account_ancestor(id_descendent)
go
create index t_account_ancestor_index3 on t_account_ancestor(num_generations)
go
--------------------------------------------------------------------------------------------------

-- stored procedures
drop proc AddAccToHierarchy
go

create proc AddAccToHierarchy (@id_ancestor as int,@id_descendent as int,@dt_start as datetime,@dt_end as datetime)
																		 --@status int OUTPUT)
as
	SET NOCOUNT ON
	declare @ctime as datetime
	set @ctime = GetUTCDate()
--	set @status = 0
	

	-- create new rules
	insert into t_account_ancestor (id_ancestor,id_descendent,num_generations,vt_start,vt_end,tt_start,tt_end)
		-- create a record of all the parents above us in the hierarchy
		select id_ancestor,@id_descendent,num_generations + 1,
		vt_start,vt_end,@ctime,dbo.MTMaxDate() from
		t_account_ancestor where
		id_descendent = @id_ancestor AND id_ancestor <> id_descendent  AND
		dbo.OverlappingDateRange(vt_start,vt_end,@dt_start,@dt_end) = 1 AND tt_end = dbo.MTMaxDate()
		UNION ALL
		-- the new record to parent.  Note that the 
		select @id_ancestor,@id_descendent,1,@dt_start,@dt_end,@ctime,dbo.MTMaxDate()
		-- self pointer
		UNION ALL 
		select @id_descendent,@id_descendent,0,@dt_start,@dt_end,@ctime,dbo.MTMaxDate()
go
-- end sproc

--------------------------------------------------------------------------------------------------

drop proc SetAccountHierarchyEndDate
go
create proc SetAccountHierarchyEndDate(@id_descendent int,@dt_end as datetime,@status int  OUTPUT)
as
	set @status = 0
-- possible status codes:
-- 0 : no error
-- 1 : descendent account contains children.
-- 2 : start date is after end date
	declare @ctime as datetime
	declare @dt_start as datetime
	set @ctime = GetUTCDate()

	-- step 1: get the start date (based on the currently effective account period).  Note that 
	-- we find the maximum start date.
	select @dt_start = MAX(vt_start) from t_account_ancestor where id_descendent = @id_descendent AND 
	dbo.OverlappingDateRange(GetUTCDate(),@dt_end,vt_start,vt_end) = 1 AND
	num_generations = 0 AND tt_end = dbo.MTMaxDate()

	-- step 2: make sure that the start is before the end date
	if @dt_start > @dt_end begin
		PRINT 'resolved start date is after end date.'
		set @status = 2
		return
	end

	-- step 3: check the descendent account does not have any children after dt_end
	select @status = case when count(tablelist.id_descendent) > 0 then 1 else 0 end from
		(select id_descendent from t_account_ancestor where id_ancestor = @id_descendent AND
		 num_generations > 0 AND
		dbo.OverlappingDateRange(@dt_end,dbo.MTMaxDate(),vt_start,vt_end) =1 AND
		tt_end = dbo.MTMaxDate()) tablelist

	-- step 4: exit if account has children
	if @status <> 0 begin
		PRINT 'Existing account contains children'
		return
	end

	-- step 5: create the new version information
	insert into t_account_ancestor (id_ancestor,id_descendent,num_generations,vt_start,vt_end,tt_start,tt_end)
	-- create new records with the new end date
	select id_ancestor,id_descendent,num_generations,@dt_start,@dt_end,@ctime,dbo.MTMaxDate() from
		t_account_ancestor where id_descendent  = @id_descendent AND tt_end = dbo.MTMaxDate() AND 
		vt_start = @dt_start

	-- step 6: update the records that are no longer true
	update t_account_ancestor set tt_end = @ctime where
	id_descendent = @id_descendent AND vt_start = @dt_start AND vt_end = dbo.MTMaxDate()

	set @status = 0
go
-- end sproc --------------------------------------------------


--------------------------------------------------------------------------------------------------
-- test for SetAccountHierarchyEndDate
/*

select * from t_account_ancestor

declare @ctime as datetime
declare @status as int
set @ctime = GetUTCDate()

exec SetAccountHierarchyEndDate 4,@ctime,@status = @status OUTPUT
select @status
*/
--------------------------------------------------------------------------------------------------


go
drop proc MoveAccount
go
create proc MoveAccount (@id_ancestor as int,@id_descendent as int,@dt_start as datetime,
												 @status int OUTPUT)
as
-- status codes: 
-- 1: folder does not have an infinite end date
-- 2: ancestor is actually a child
-- 3: account has an existing move effective in the future that conflicts with the current move operation

--SET NOCOUNT ON
	declare @ctime as datetime
	declare @dt_start_bucket as datetime
	set @ctime = GetUTCDate()

	-- step : determine the start,end bucket to bisect.
	select @dt_start_bucket = MAX(vt_start) from t_account_ancestor where 
	id_descendent = @id_descendent and tt_end = dbo.MTMaxDate() AND
	dbo.MTRangeCheck(vt_start,vt_end,@dt_start) = 'Y' AND tt_end = dbo.MTMaxDate()

	-- step : determine that the ancestor is a folder and can have children??

	-- step : make sure that the ancestor has an infinite end date.  We require this
	-- because we are assuming that we are moving the account at a given timestamp into
	-- a new and it will be there infinitely (or until we change it again)
	select @status = 	case when count(*) > 0 then 1 else 0 end
	from t_account_ancestor where id_descendent = @id_ancestor AND
	tt_end = dbo.MTMaxDate() AND vt_end = dbo.MTMaxDate()
	if @status = 0 begin
		set @status = 1
		PRINT 'folder does not have an infinite end date'
		return
	end

	-- step : make sure that the new ancestor is not actually a child
	select @status =case when count(*) > 0 then 1 else 0 end
	from t_account_ancestor where id_ancestor = @id_descendent AND id_descendent = @id_ancestor
	if @status = 1 begin
		set @status = 2
		PRINT 'Specified new parent account is a child of the target account'
		return
	end

	-- step : make sure that the account to be moved does not have a pending move in the fture
	select @status = case when count(*) > 0 then 1 else 0 end
	from t_account_ancestor where id_descendent = @id_descendent AND tt_end = dbo.MTMaxDate() AND 
	-- XXX > OR X=??
	vt_start > @dt_start
	if @status = 1 begin
		set @status = 3
		PRINT 'Account has a move effective in the future that conflicts with the requested operation'
		return
	end

	-- step : do we need to check that the user does not try to make the same effective change
	-- twice?  It is probably a good idea but I don't know if it actually causes problems, especially 
	-- because there is a limited number of rows that are actually effective.

	-- step : update all of the parent records for the descendent and all of its children such
	-- that they are no longer in effect after dt_start.  This accomplishes two goals: it 
	-- removes any parent records that are no longer valid as well as the generation number
	-- which is also no longer valid.

--	declare @id_descendent as int	
--	declare @id_ancestor as int
--	set @id_descendent = 5
--	set @id_ancestor = 6
--	declare @dt_start as datetime
--	set @dt_start = GetUTCDate()
	declare @keylist table (id_key int)

	insert into @keylist 
	select existing.id_key from t_account_ancestor existing,t_account_ancestor old
	/*,t_account_ancestor old_direct_parent */
	where 
	-- old direct parent for the descendent
	/*
	old_direct_parent.id_descendent = @id_descendent AND old_direct_parent.num_generations =1 
	AND old_direct_parent.tt_end = dbo.MTMaxDate() AND
	dbo.OverlappingDateRange(old_direct_parent.vt_start,old_direct_parent.vt_end,@dt_start,dbo.MTMaxDate()) = 1 AND
	*/	
-- old join criteria
	old.id_ancestor = @id_descendent AND old.tt_end = dbo.MTMaxDate() and
	dbo.OverlappingDateRange(old.vt_start,old.vt_end,@dt_start,dbo.MTMaxDate()) = 1 AND
	-- we want only stuff from new that is currently effective AND is not the self pointer
	existing.id_descendent = old.id_descendent AND existing.num_generations > old.num_generations AND
	existing.vt_end = dbo.MTMaxDate() AND existing.tt_end = dbo.MTMaxDate()

	update t_account_ancestor set tt_end = @ctime where id_key in  ( select id_key from @keylist)

	-- step : add the new parent records.  We basically are adding records for the descendent and all of its
	-- children.

	-- step : create new records of all the new parents
	-- select the record where the descendent is the ancestor and get the id_descendent and row number.  Insert 
	-- new rows with the id_descendent while adding the new parent number of generations to the child number of generations + 1
	insert into t_account_ancestor (id_ancestor,id_descendent,num_generations,vt_start,vt_end,tt_Start,tt_end)
	select new_parent.id_ancestor,child.id_descendent,
	new_parent.num_generations + child.num_generations + 1 as num_generations,
	@dt_start,dbo.MTMaxDate(),@ctime,dbo.MTMaxDate()
	from t_account_ancestor new_parent,t_account_ancestor child where
	new_parent.id_descendent = @id_ancestor AND new_parent.tt_end = dbo.MTMaxDate() AND new_parent.vt_end = dbo.MTMaxDate() AND
	child.id_ancestor = @id_descendent AND child.tt_end = dbo.MTMaxDate() 
	UNION ALL
  select ans.id_ancestor,ans.id_descendent,ans.num_generations,vt_start,@dt_start,@ctime,dbo.MTMaxDate()
	from t_account_ancestor ans,@keylist list
	where list.id_key = ans.id_key
go 
-- end sproc --------------------------------------------------
	
	

--------------------------------------------------------------------------------------------------
-- test MOveAccount

/*
select * from 	t_account_ancestor where tt_end = dbo.MTMaxDate()

select * from t_account_ancestor where tt_end = '2001-11-12 17:59:53.153'

select * from t_account_ancestor 
declare @cdate as datetime
set @cdate = GetUTCDate()+50
declare @status as int

exec MoveAccount 1,3,@cdate,@status = @status OUTPUT
select @status

select * from 	t_account_ancestor where id_descendent = 5 AND tt_end = dbo.MTMaxDate()
*/

--------------------------------------------------------------------------------------------------
-- what was 5's hierarchy as of December 15th?

/*
select * from t_account_ancestor where id_descendent = 5 and vt_start <= '2001-12-15 00:00:00' AND '2001-12-15 00:00:00' < vt_end AND tt_end = dbo.MTMaxDate()


-- what was 5's hierarchy as of December 15, 2002
select * from t_account_ancestor where id_descendent = 5 and vt_start <= '2002-12-15 00:00:00' AND '2002-12-15 00:00:00' < vt_end AND tt_end = dbo.MTMaxDate()

-- what did the system think the hierarchy looked like on 2001-11-12 18:55:58.090
-- find all the rows where id_descendent = 5 and 

select * from t_account_ancestor where id_descendent = 5 AND tt_start <= '2001-11-12 18:55:58.090' 


select min(tt_end) from t_account_ancestor where id_descendent = 5 AND tt_start <= '2001-11-12 18:55:58.090' AND '2001-11-12 18:55:58.090' < tt_end


select min(tt_start),tt_end from t_account_ancestor where id_descendent = 5  group by tt_end

*/

--------------------------------------------------------------------------------------------------


/*
declare @cdate as datetime
set @cdate = '2002-05-05'
declare @status as int
select * from 	t_account_ancestor where id_descendent = 5

exec MoveAccount 6,5,@cdate,@status = @status OUTPUT
select @status
select * from 	t_account_ancestor where id_descendent = 5



select * from 	t_account_ancestor where id_descendent = 5 AND tt_end = dbo.MTMaxDate()--AND vt_end = tt_end
select * from 	t_account_ancestor where id_descendent = 5 AND id_ancestor = 1 AND num_generations = 4

select * from 	t_account_ancestor where id_descendent = 4
select * from 	t_account_ancestor where id_descendent = 3


select * from 	t_account_ancestor where id_descendent = 1

select GetUTCDate() + 50
select GetUTCDate() + 60

drop table t_foo
select now.cdate into t_foo from (select GetUTCDate() cdate) now



--------------------------------------------------------------------------------------------------

-- see the table
select dbo.MTMinDate()		

truncate table t_account_ancestor

insert into t_account_ancestor values (1,1,0,dbo.MTMinDate(),dbo.MTMaxDate(),GetUTCDate(),dbo.MTMaxDate())

declare @cdate as datetime
declare @enddate as datetime
declare @maxdate as datetime
set @cdate = GetUTCDate()
set @enddate = @cdate + 100
set @maxdate = dbo.MTMaxDate()

exec AddHierarchyParent 1,2,@cdate,@maxdate
exec AddHierarchyParent 2,3,@cdate,@maxdate
exec AddHierarchyParent 3,4,@cdate,@maxdate
exec AddHierarchyParent 4,5,@cdate,@maxdate
exec AddHierarchyParent 1,6,@cdate,@maxdate

declare @cdate as datetime
declare @enddate as datetime
declare @maxdate as datetime
set @cdate = GetUTCDate()
set @enddate = @cdate + 100
set @maxdate = dbo.MTMaxDate()
exec AddHierarchyParent 1,6,@cdate,@maxdate


*/

--------------------------------------------------------------------------------------------------
