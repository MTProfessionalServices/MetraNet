
create procedure UpdateGroupSubscription(
@p_id_group int,
@p_name nvarchar(255),
@p_desc nvarchar(255),
@p_startdate datetime,
@p_enddate datetime,
@p_proportional varchar,
@p_supportgroupops varchar,
@p_discountaccount int,
@p_CorporateAccount int,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
@p_allow_acc_po_curr_mismatch int = 0,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
	declare @idPO as int
	declare @idSUB as int
	declare @realenddate as datetime
	declare @oldstartdate as datetime
	declare @oldenddate as datetime
	declare @varMaxDateTime as datetime
	declare @idusagecycle int
	select @varMaxDateTime = dbo.MTMaxDate()
	

-- Section 1
	-- find the product offering ID
	select @idPO = id_po, @idusagecycle = tg.id_usage_cycle,@idSUB = t_sub.id_sub
	from t_sub 
	INNER JOIN t_group_sub tg on tg.id_group = @p_id_group
	where t_sub.id_group = @p_id_group
	

-- Section 2
	-- business rule checks
	if (@p_enddate is null)
		begin
		select @realenddate = @varMaxDateTime
		end
	else
		begin
		select @realenddate = @p_enddate
		end 
	exec CheckGroupSubBusinessRules @p_name,@p_desc,@p_startdate,@p_enddate,@idPO,
	@p_proportional,@p_discountaccount,@p_CorporateAccount,@p_id_group,@idusagecycle,@p_systemdate,@p_enforce_same_corporation, @p_allow_acc_po_curr_mismatch, @p_status output
	if (@p_status <> 1) begin
		return
	end
	exec UpdateSub @idSUB,@p_startdate,@realenddate,'N','N',@idPO,NULL,@p_systemdate,
		@p_status OUTPUT,@p_datemodified OUTPUT
	if @p_status <> 1 begin
		return
	end
	update t_group_sub set tx_name = @p_name,tx_desc = @p_desc,b_proportional = @p_proportional,
	id_corporate_account = @p_CorporateAccount,id_discountaccount = @p_discountaccount,
	b_supportgroupops = @p_supportgroupops
	where id_group = @p_id_group
	

-- Section 3
	-- Ok, here is how I propose to do this.
	-- First of all, we will end the current history of all memberships whose duration
	-- falls, partially or completely, out of the group subscription duration.
	-- This is accomplished with the following statement.
	update t_gsubmember_historical
	set tt_end = dateadd(s, -1, @p_systemdate)
	where id_group = @p_id_group 
		AND tt_end = @varMaxDateTime
		AND ((@p_startdate > vt_start) OR (@realenddate < vt_end))
		
-- TODO: When converting this procedure to oracle, sections 4, 5, and 6 have changed since 3.0.1
-- Section 4
	-- The next step involves inserting the new history of the memberships that were changed somehow.
	-- Except that we do not need to insert new history for the memberships that were *completely* left out
	-- of the group sub duration. Those are effectively deleted, and the last entry on t_gsubmember_history
	-- for them will have tt_end = systemdate.
	insert into t_gsubmember_historical (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
	select id_group,id_acc,
	dbo.mtmaxoftwodates(tgs.vt_start,@p_startdate),
	dbo.mtminoftwodates(tgs.vt_end,@realenddate),
	@p_systemdate,
	@varMaxDateTime
	from t_gsubmember tgs
	where tgs.id_group = @p_id_group
		and ((@p_startdate > vt_start and vt_end >= @p_startdate) OR (@realenddate < vt_end and vt_start <= @realenddate))

-- Section 5
	-- Finally, we will select the records that are still relevant to the current format of the group subscription
	-- and insert them from t_gsubmember_historical into t_gsubmember.
	
	-- First remove the old records
	delete from t_gsubmember where id_group = @p_id_group
	-- Then import the records that are relevant to this group subscription
	insert into t_gsubmember (id_group,id_acc,vt_start,vt_end)
		select id_group,id_acc,vt_start,vt_end
		from t_gsubmember_historical
		where id_group = @p_id_group and tt_end = @varMaxDateTime


  -- post-operation business rule checks (relies on rollback of work done up until this point)

  -- CR9906: check to make sure the newly added member does not violate a BCR constraint
  SELECT @p_status = dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, @p_id_group)
  IF (@p_status <> 1)
    RETURN
  
  -- checks to make sure the member's payer's do not violate EBCR cycle constraints
  SELECT @p_status = dbo.CheckGroupMembershipEBCRConstraint(@p_systemdate, @p_id_group)
  IF (@p_status <> 1)
    RETURN

  -- checks to make sure the receiver's payer's do not violate EBCR cycle constraints
  SELECT @p_status = dbo.CheckGroupReceiverEBCRConstraint(@p_systemdate, @p_id_group)
end
		 