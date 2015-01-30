
create procedure AddAccountToGroupSub(
	@p_id_sub int,             -- subscription ID of the group
	@p_id_group int,           -- group ID
	@p_id_po int,              -- product offering ID to which the group is subscribed
	@p_id_acc int,             -- account ID of the candidate member
	@p_startdate datetime,     -- date at which membership should begin
	@p_enddate datetime,       -- date at which membership should end
	@p_systemdate datetime,    -- current system time
	@p_enforce_same_corporation varchar,
	@p_status int OUTPUT,
	@p_datemodified varchar output,
  @p_allow_acc_po_curr_mismatch int = 0,
  @p_allow_multiple_pi_sub_rcnrc int = 0
  )
as
begin
declare @existingID as int
declare @real_enddate as datetime
declare @real_startdate datetime
	select @p_status = 0
	-- step : if the end date is null get the max date
	-- XXX this is broken if the end date of the group subscription is not max date
	if (@p_enddate is null)
		begin
		select @real_enddate = dbo.MTMaxDate()
		end
	else
		begin
		if @p_startdate > @p_enddate begin
			-- MT_GROUPSUB_STARTDATE_AFTER_ENDDATE
			select @p_status = -486604782
			select @p_datemodified = 'N'
			return
		end

		select @real_enddate = @p_enddate
		end 
	select @real_startdate = dbo.mtmaxoftwodates(@p_startdate,t_sub.vt_start),
	@real_enddate = dbo.mtminoftwodates(@real_enddate,t_sub.vt_end) 
	from 
	t_sub where id_sub = @p_id_sub

	if (@real_startdate <> @p_startdate OR
	(@real_enddate <> @p_enddate AND @real_enddate <> dbo.mtmaxdate()))
		begin
			select @p_datemodified = 'Y'
		end
		else
		begin
			select @p_datemodified = 'N'
		end
	begin
	-- step : check that account is not already part of the group subscription
	-- in the specified date range
		select @existingID = id_acc from t_gsubmember where
	-- check againt the account
		id_acc = @p_id_acc AND id_group = @p_id_group
	-- make sure that the specified date range does not conflict with 
	-- an existing range
		AND dbo.overlappingdaterange(vt_start,vt_end,
		@real_startdate,@real_enddate) = 1
		if (@existingID = @p_id_acc)
			begin
			-- MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION 
			select @p_status = -486604790
			return
			end 
		if (@existingID is null)
			begin
			select @p_status = 0 
			end
	end
		-- step : verify that the date range is inside that of the group subscription
		begin
			select @p_status = dbo.encloseddaterange(vt_start,vt_end,@real_startdate,@real_enddate)  
			from t_sub where id_group = @p_id_group
			if (@p_status <> 1 ) 
			begin
			-- MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
			select @p_status = -486604789
			return
			end 
		if (@p_status is null) 
			begin
			-- MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST
			select @p_status = -486604788
			return 
		end
		end
		-- step : check that the account does not have any conflicting subscriptions
		-- note: checksubscriptionconflicts return 0 on success while the other
		-- functions return 1.  This should be fixed (CS 2-1-2001)
		select @p_status = dbo.checksubscriptionconflicts(@p_id_acc,@p_id_po,
		@real_startdate, @real_enddate,@p_id_sub, @p_allow_acc_po_curr_mismatch, @p_allow_multiple_pi_sub_rcnrc) 
		if (@p_status <> 1 ) 
			begin
			 return
			end 
		
		-- bug fix for 13538.. This check is done better in CheckSubscriptionConflicts	
		-- Check that both account and PO have the same currency
		-- if (dbo.IsAccountAndPOSameCurrency(@p_id_acc, @p_id_po) = '0')
		-- begin
			-- MT_ACCOUNT_PO_CURRENCY_MISMATCH
			-- select @p_status = -486604729
			-- return
		-- end
		 -- make sure that the member is in the corporate account specified in 
		 -- the group subscription
		 -- only check this if Corp business rule is enforced.
		if (@p_enforce_same_corporation = '1')
		begin
			select @p_status = count(num_generations) from 
			t_account_ancestor ancestor
			INNER JOIN t_group_sub tg on tg.id_group = @p_id_group
			where ancestor.id_ancestor = tg.id_corporate_account AND
			ancestor.id_descendent = @p_id_acc AND
			@real_startdate between ancestor.vt_start AND ancestor.vt_end
			if (@p_status = 0 )
			begin
			-- MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT
			select @p_status = -486604769
			return
			end
		end
		
		-- check that account type of the member is compatible with the product offering
    -- since the absense of ANY mappings for the product offering means that PO is "wide open"
    -- we need to do 2 EXISTS queries

		if
		 exists (
      SELECT 1
      FROM t_po_account_type_map atmap 
      WHERE atmap.id_po = @p_id_po
    )
    --PO is not wide open - see if susbcription is permitted for the account type
    AND
    not exists (
      SELECT 1
      FROM  t_account tacc 
      INNER JOIN t_po_account_type_map atmap on atmap.id_po = @p_id_po AND atmap.id_account_type = tacc.id_type
      WHERE  tacc.id_acc = @p_id_acc
    )
    begin
      select @p_status = -289472435 -- MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE
      return
    end
    
    -- Check for MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 0xEEBF004FL -289472433
    -- BR violation
    if
		 exists (
      SELECT 1
      FROM  t_account tacc 
      INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
      WHERE tacc.id_acc = @p_id_acc AND tacctype.b_CanParticipateInGSub = '0'
    )
    begin
      select @p_status = -289472433 -- MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 
      return
    end
    
    

		
		 
		-- end business rule checks

	exec CreateGSubmemberRecord @p_id_group,@p_id_acc,@real_startdate,@real_enddate,@p_systemdate,@p_status OUTPUT

  -- post-creation business rule check (relies on rollback of work done up until this point)

  -- CR9906: check to make sure the newly added member does not violate a BCR constraint
  SELECT @p_status = dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, @p_id_group)
  IF (@p_status <> 1)
    RETURN

  -- checks to make sure the member's payer's do not violate EBCR cycle constraints
  SELECT @p_status = dbo.CheckGroupMembershipEBCRConstraint(@p_systemdate, @p_id_group)
END
	