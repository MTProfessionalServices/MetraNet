
create procedure CheckGroupSubBusinessRules(
	@p_name nvarchar(255),
	@p_desc nvarchar(255),
	@p_startdate datetime,
	@p_enddate datetime,
	@p_id_po int,
	@p_proportional varchar,
	@p_discountaccount int,
	@p_CorporateAccount int,
	@p_existingID int,
	@p_id_usage_cycle integer,
	@p_systemdate datetime,
	@p_enforce_same_corporation varchar,
	@p_allow_acc_po_curr_mismatch int = 0,
	@p_status int OUTPUT
)
as
begin 
declare @existingPO integer
declare @constrainedcycletype integer
declare @groupsubCycleType integer
declare @corporatestartdate datetime
select @p_status = 0

-- verify that the corporate account and the product offering have the same currency.
if (@p_enforce_same_corporation = '1') 
begin
	if (dbo.IsAccountAndPOSameCurrency(@p_CorporateAccount, @p_id_po) = '0')
	begin

		-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
    if (@p_allow_acc_po_curr_mismatch <> 0)  
		select @p_status = 1
	else
		select @p_status = -486604729
		return
	end
end

-- verify that the discount account, if not null has the same currency as the po.
if (@p_enforce_same_corporation = '0' AND @p_discountaccount is not NULL)
begin
   if (dbo.IsAccountAndPOSameCurrency(@p_discountaccount, @p_id_po) = '0')
   begin
	-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
    if (@p_allow_acc_po_curr_mismatch <> 0)  
		select @p_status = 1
	else
		select @p_status = -486604729
		return
	end
end

if @p_enddate is NULL
	select @p_enddate = dbo.MTMaxDate()
	
	
	-- verify that the product offering exists and the effective date is kosher
if (@p_proportional = 'N' )
 begin
 if (@p_discountaccount is NULL AND dbo.POContainsDiscount(@p_id_po) = 1)
	begin
	-- MT_GROUP_SUB_DISCOUNT_ACCOUNT_REQUIRED
	select @p_status = -486604787
	return
	end 
 end
	-- verify that the account is actually a corporate account
  -- during the interval [@p_startdate, @p_enddate]
  -- this is done by requiring that the account is corporate
	-- at @p_startdate and at @p_enddate and that there are no
  -- gaps during [@p_startdate, @p_enddate] such that the account
  -- is not a corporate account.
  -- DBlair - Note that this is more complicated than it really needs
  -- to be because I have written it as a "generic" sequenced
  -- referential integrity constraint (see Snodgrass' book for definition).
  -- I wanted to follow the pattern, since it is very easy to make
  -- mistakes inventing temporal database constructs in an ad-hoc
  -- way.
--BP: Only return MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID error if
-- a business rule that prohibits cross-corporation operations is enforced
-- Otherwise we create all group subscriptions as global (id_corp = 1)
--Another way to do this would be to ignore below check if corporation id
-- is 1. However this would introduce some complications during pc import/export and upgrades
if(@p_enforce_same_corporation = '1')
begin
	if 
		not exists(
			select * 
			from t_account_ancestor aa
			inner join t_account a on a.id_acc = aa.id_descendent
			inner join t_account_type at on at.id_type = a.id_type
			where 
			at.b_IsCorporate = '1'
			and
			aa.id_descendent=@p_CorporateAccount
			and
			aa.vt_start <= @p_startdate
			and
			aa.vt_end >= @p_startdate
		)
		or not exists (
			select * 
			from t_account_ancestor aa
			inner join t_account a on a.id_acc = aa.id_descendent
			inner join t_account_type at on at.id_type = a.id_type
			where 
			at.b_IsCorporate = '1'
			and
			aa.id_descendent=@p_CorporateAccount
			and
			aa.vt_start <= @p_enddate
			--and
			--aa.vt_end >= @p_enddate
		)
		or exists (
			select * 
			-- This finds a record that ends during the
			-- interval...
			from t_account_ancestor aa
			inner join t_account a on a.id_acc = aa.id_descendent
			inner join t_account_type at on at.id_type = a.id_type
			where 
			at.b_IsCorporate = '1'
			and
			aa.id_descendent=@p_CorporateAccount
			and
			@p_startdate <= aa.vt_end
			and
			aa.vt_end < @p_enddate
			-- ... and there is not corp. account record that extends
			-- its validity.
			and
			not exists (
				select * 
				from t_account_ancestor aa2
			  inner join t_account a on a.id_acc = aa2.id_descendent
			  inner join t_account_type at on at.id_type = a.id_type
			  where 
			  at.b_IsCorporate = '1'
				and
				aa2.vt_start <= dateadd(s, 1, aa.vt_end)
			--	and
			--	aa2.vt_end > aa.vt_end	
			)
		)
    begin
    declare @accStart datetime, @accEnd datetime

    select @accStart = vt_start, @accEnd = vt_end from t_account_ancestor
    where id_descendent = @p_CorporateAccount and num_generations = 0 -- Clustered Index

    if (@p_startdate < @accStart)
      begin
        -- MT_GROUP_SUB_STARTS_BEFORE_ACCOUNT
        select @p_status = -486604710
        return
      end
    if (@p_enddate > @accEnd)
      begin
        -- MT_GROUP_SUB_ENDS_AFTER_ACCOUNT
        select @p_status = -486604709
        return
      end
    -- MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID
    select @p_status = -486604786
    return
    end
end
 -- make sure start date is before end date
	-- MT_GROUPSUB_STARTDATE_AFTER_ENDDATE
if (@p_enddate is not null )
	begin
	if (@p_startdate > @p_enddate)
		begin
		select @p_status = -486604782
		return
		end 
	end
	-- verify that the group subscription name does not conflict with an existing
	-- group subscription
	--  MT_GROUP_SUB_NAME_EXISTS -486604784
begin
	select @p_status = 0
	select @p_status = id_group  from t_group_sub where lower(@p_name) = lower(tx_name) AND
	(@p_existingID <> id_group OR @p_existingID is NULL)
	if (@p_status <> 0) begin
		select @p_status = -486604784
		return
	end 
	if (@p_status is null) begin
		select @p_status = 0
		end
end
-- verify that the usage cycle type matched that of the 
-- product offering
select @constrainedcycletype = dbo.poconstrainedcycletype(@p_id_po),
		@groupsubCycleType = id_cycle_type 
from
t_usage_cycle
where id_usage_cycle = @p_id_usage_cycle
if @constrainedcycletype > 0 AND
	@constrainedcycletype <> @groupsubCycleType begin
-- MT_GROUP_SUB_CYCLE_TYPE_MISMATCH
	select @p_status = -486604762
return
end
 -- check that the discount account has in its ancestory tree 
	-- the corporate account
-- BP: Only return MT_DISCOUNT_ACCOUNT_MUST_BE_IN_CORPORATE_HIERARCHY error if
-- a business rule that prohibits cross-corporation operations is enforced.
-- Otherwise we create all group subscriptions as global (id_corp = 1)
-- Another way to do this would be to ignore below check if corporation id
-- is 1. However this would introduce some complications during pc import/export and upgrades
if (@p_enforce_same_corporation = '1' AND @p_discountaccount is not NULL)
	begin
		select @p_status = max(id_ancestor)  
		from t_account_ancestor 
		where id_descendent = @p_discountaccount 
		and id_ancestor = @p_CorporateAccount
	if (@p_status is NULL)
		begin
		-- MT_DISCOUNT_ACCOUNT_MUST_BE_IN_CORPORATE_HIERARCHY
		select @p_status = -486604760
		return
		end 
	end 

	-- make sure the start date is after the start date of the corporate account
	-- BP: Only return MT_CANNOT_CREATE_GROUPSUB_BEFORE_CORPORATE_START_DATE error if
	-- a business rule that prohibits cross-corporation operations is enforced.
	-- Otherwise we create all group subscriptions as global (id_corp = 1)
	-- Another way to do this would be to ignore below check if corporation id
	-- is 1. However this would introduce some complications during pc import/export and upgrades
	if (@p_enforce_same_corporation = '1')
	begin
		select @corporatestartdate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @p_CorporateAccount
		if @corporatestartdate > @p_startdate begin
			-- MT_CANNOT_CREATE_GROUPSUB_BEFORE_CORPORATE_START_DATE
			select @p_status = -486604747
			return
		end 
	end

-- done
select @p_status = 1
end
			 