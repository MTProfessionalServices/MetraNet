
create  procedure
AddAccToHierarchy (@id_ancestor int,
@id_descendent int,
@dt_start  datetime,
@dt_end  datetime,
@p_acc_startdate datetime,
@ancestor_type varchar(40) OUTPUT,
@acc_type varchar(40) OUTPUT,
@status int OUTPUT)
as
begin
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @ancestor int
declare @descendentIDAsString varchar(50)
declare @ancestorStartDate as datetime
declare @realaccstartdate as datetime
declare @ancestor_acc_type int
declare @descendent_acc_type int
select  @status = 0
-- begin business rules
-- check that the account is not already in the hierarchy
select @varMaxDateTime = dbo.MTMaxDate()
select @descendentIDAsString = CAST(@id_descendent as varchar(50)) 

--take a lock on a parent, we need it as we will update the b_children='Y' on the parent.
declare @varMaxDateTimeAlex datetime
select @varMaxDateTimeAlex = max(vt_end)
from t_account_ancestor  with(updlock) 
where id_descendent = @id_ancestor

  -- begin business rule checks.


 select @ancestor_type = atype.name, @ancestor_acc_type = atype.id_type from t_account acc
       inner join t_account_type atype 
       on atype.id_type = acc.id_type
       where acc.id_acc = @id_ancestor

      
  select @acc_type = atype.name, @descendent_acc_type = atype.id_type from t_account acc
       inner join t_account_type atype
       on atype.id_type = acc.id_type
       where acc.id_acc = @id_descendent
              

	SELECT @ancestor = id_acc 
	  from
	  t_account where id_acc = @id_ancestor
	if @ancestor is null begin
		  -- MT_PARENT_NOT_IN_HIERARCHY
		  select @status = -486604771
		  return
	end
	
	if @descendent_acc_type not in (
	  select id_descendent_type from t_acctype_descendenttype_map
	  where id_type = @ancestor_acc_type)
  begin
     select @status = -486604714  -- MT_ANCESTOR_OF_INCORRECT_TYPE
     return
  end 

	if @p_acc_startdate is NULL
	begin
		select @realaccstartdate = dt_crt from t_account where id_acc = @id_descendent
	end
	else
	begin
		select @realaccstartdate = @p_acc_startdate
	end

	select @ancestorStartDate = dt_crt
	from t_account where id_acc = @id_ancestor
	if  dbo.mtstartofday(@realaccstartdate) < dbo.mtstartofday(@ancestorStartDate)
	begin
		-- MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START
		select @status = -486604746
		return
	end 

  select  @status = count(*)  from t_account_ancestor with(updlock)
    where id_descendent = @id_descendent 
    and id_ancestor = @id_ancestor
    and num_generations = 1
    and (dbo.overlappingdaterange(vt_start,vt_end,@dt_start,@dt_end) = 1 )

  if (@status > 0) 
  begin
    -- MT_ACCOUNT_ALREADY_IN_HIEARCHY
    select @status = -486604785
    return
  end 

-- end business rule checks.

select @realstartdate = dbo.MTStartOfDay(@dt_start)  
if (@dt_end is NULL) 
begin
 select @realenddate = dbo.MTStartOfDay(dbo.mtmaxdate())  
 end
else
 begin
 select @realenddate = dbo.mtendofday(@dt_end)  
 end 
-- TODO: we need error handling code to detect when the ancestor does 
-- not exist at the time interval!!
-- populate t_account_ancestor (no bitemporal data)
insert into t_account_ancestor (id_ancestor,id_descendent,
num_generations,vt_start,vt_end,tx_path)
select id_ancestor,@id_descendent,num_generations + 1,dbo.MTMaxOfTwoDates(vt_start,@realstartdate),dbo.MTMinOfTwoDates(vt_end,@realenddate),
case when (id_descendent = 1 OR id_descendent = -1) then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end 
from t_account_ancestor
where
id_descendent = @id_ancestor AND id_ancestor <> id_descendent  AND
dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
UNION ALL
-- the new record to parent.  Note that the 
select @id_ancestor,@id_descendent,1,@realstartdate,@realenddate,
case when (id_descendent = 1 OR id_descendent = -1) then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end
from
t_account_ancestor where id_descendent = @id_ancestor AND num_generations = 0
AND dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
	-- self pointer
UNION ALL 
select @id_descendent,@id_descendent,0,@realstartdate,@realenddate,@descendentIDAsString
-- update our parent entry to have children
update t_account_ancestor set b_Children = 'Y' where
id_descendent = @id_ancestor AND
dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
and b_Children <> 'Y'
if (@@error <> 0) 
 begin
 select @status = 0
 end
select @status = 1  
end
				