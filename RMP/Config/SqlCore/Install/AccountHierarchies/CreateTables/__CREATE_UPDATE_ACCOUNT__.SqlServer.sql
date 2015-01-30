
CREATE PROCEDURE UpdateAccount (
  @p_loginname nvarchar(255),
	@p_namespace nvarchar(40),
	@p_id_acc int,
	@p_acc_state varchar(2),
	@p_acc_state_ext int,
	@p_acc_statestart datetime,
	@p_tx_password nvarchar(1024),
	@p_ID_CYCLE_TYPE int,
	@p_DAY_OF_MONTH  int,
	@p_DAY_OF_WEEK int,
	@p_FIRST_DAY_OF_MONTH int,
	@p_SECOND_DAY_OF_MONTH  int,
	@p_START_DAY int,
	@p_START_MONTH int,
	@p_START_YEAR int,
	@p_id_payer int,
	@p_payer_login nvarchar(255),
  @p_payer_namespace nvarchar(40),
	@p_payer_startdate datetime,
	@p_payer_enddate datetime,
	@p_id_ancestor int,
	@p_ancestor_name nvarchar(255),
	@p_ancestor_namespace nvarchar(40),
	@p_hierarchy_movedate datetime,
	@p_systemdate datetime,
	@p_billable varchar,
	@p_enforce_same_corporation varchar,
	--pass the currency through so that CreatePaymenrRecord
	--validates it, because the currency can be updated
	@p_account_currency nvarchar(5),
	@p_status int output,
	@p_cyclechanged int output,
	@p_newcycle int output,
	@p_accountID int output,
	@p_hierarchy_path varchar(4000) output,
	--if account is being moved, select old ancestor id
	@p_old_id_ancestor_out int output,
	--if account is being moved, select new ancestor id
	@p_id_ancestor_out int output,
	@p_corporate_account_id int OUTPUT,
	@p_ancestor_type varchar(40) OUTPUT,
	@p_acc_type varchar(40) OUTPUT
	)
as
begin
	declare @accountID int
	declare @oldcycleID int
	declare @usagecycleID int
	declare @intervalenddate datetime
	declare @intervalID int
	declare @pc_start datetime
	declare @pc_end datetime
	declare @oldpayerstart datetime
	declare @oldpayerend datetime
	declare @oldpayer int
	declare @payerenddate datetime
	declare @payerID int
	declare @AncestorID int
	
	declare @payerbillable varchar(1)
	select @accountID = -1
	select @oldcycleID = 0
	select @p_status = 0
	
	-- initialize the ancestor type (hack !!)
	set @p_ancestor_type = ''
	
	set @p_old_id_ancestor_out = @p_id_ancestor  -- we assume no move.
	-- step : resolve the account if necessary
	if (@p_id_acc is NULL) begin
		if (@p_loginname is not NULL and @p_namespace is not NULL) begin
		select @accountID = dbo.LookupAccount(@p_loginname,@p_namespace) 
			if (@accountID < 0) begin
				-- MTACCOUNT_RESOLUTION_FAILED
					select @p_status = -509673460
      end
		end
		else 
			begin
  	-- MTACCOUNT_RESOLUTION_FAILED
      select @p_status = -509673460
		end 
	end
	else
	begin
		select @accountID = @p_id_acc
	end 
	if (@p_status < 0) begin
		return
	end
 -- step : update the account password if necessary.  catch error
 -- if the account does not exist or the login name is not valid.  The system
 -- should check that both the login name, namespace, and password are 
 -- required to change the password.
	if (@p_loginname is not NULL and @p_namespace is not NULL and 
			@p_tx_password is not NULL)
			begin
			 update t_user_credentials set tx_password = @p_tx_password
				where nm_login = @p_loginname and nm_space = @p_namespace
			 if (@@rowcount = 0) 
	       begin
				 -- MTACCOUNT_FAILED_PASSWORD_UPDATE
				 select @p_status =  -509673461
         end
      end
			-- step : figure out if we need to update the account's billing cycle.  this
			-- may fail because the usage cycle information may not be present.
	begin
		select @usagecycleID = id_usage_cycle 
		from t_usage_cycle cycle where
	  cycle.id_cycle_type = @p_ID_CYCLE_TYPE 
		AND (@p_DAY_OF_MONTH = cycle.day_of_month or @p_DAY_OF_MONTH is NULL)
		AND (@p_DAY_OF_WEEK = cycle.day_of_week or @p_DAY_OF_WEEK is NULL)
		AND (@p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or @p_FIRST_DAY_OF_MONTH is NULL)
		AND (@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or @p_SECOND_DAY_OF_MONTH is NULL)
		AND (@p_START_DAY= cycle.START_DAY or @p_START_DAY is NULL)
		AND (@p_START_MONTH= cycle.START_MONTH or @p_START_MONTH is NULL)
		AND (@p_START_YEAR = cycle.START_YEAR or @p_START_YEAR is NULL)
    if (@usagecycleid is null)
		 begin
			SELECT @usagecycleID = -1
		 end
   end
	 select @oldcycleID = id_usage_cycle from
	 t_acc_usage_cycle where id_acc = @accountID
	 if (@oldcycleID <> @usagecycleID AND @usagecycleID <> -1)
	  begin

      -- checks to see if this account is affiliated with an EBCR charge
      SET @p_status = dbo.IsBillingCycleUpdateProhibitedByGroupEBCR(@p_systemdate, @p_id_acc)
      IF @p_status <> 1
        RETURN

      -- updates the account's billing cycle mapping
      UPDATE t_acc_usage_cycle SET id_usage_cycle = @usagecycleID
      WHERE id_acc = @accountID

      -- post-operation business rule check (relies on rollback of work done up until this point)
      -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 
      -- group subscription BCR constraints
      SELECT @p_status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, groups.id_group)), 1)
      FROM 
      (
        -- gets all of the payer's payee's and/or the payee's group subscriptions
        SELECT DISTINCT gsm.id_group id_group
        FROM t_gsubmember gsm
        INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
        WHERE 
          pay.id_payer = @accountID OR
          -- TODO: is payee criteria necessary?  
          pay.id_payee = @accountID
      ) groups
      IF @p_status <> 1
        RETURN
    
			-- deletes any mappings to intervals in the future from the old cycle
			DELETE FROM t_acc_usage_interval 
			WHERE 
        t_acc_usage_interval.id_acc = @accountID AND
        id_usage_interval IN 
        ( 
          SELECT id_interval 
          FROM t_usage_interval ui
          INNER JOIN t_acc_usage_interval aui ON 
            t_acc_usage_interval.id_acc = @accountID AND
            aui.id_usage_interval = ui.id_interval
          WHERE dt_start > @p_systemdate
			  )

      -- only one pending update is allowed at a time
			-- deletes any previous update mappings which have not yet
      -- transitioned (dt_effective is still in the future)
			DELETE FROM t_acc_usage_interval 
      WHERE 
        dt_effective IS NOT NULL AND
        id_acc = @accountID AND
        dt_effective >= @p_systemdate

      -- gets the current interval's end date
			SELECT @intervalenddate = ui.dt_end 
      FROM t_acc_usage_interval aui
			INNER JOIN t_usage_interval ui ON 
        ui.id_interval = aui.id_usage_interval AND
        @p_systemdate BETWEEN ui.dt_start AND ui.dt_end
		  WHERE aui.id_acc = @AccountID

      -- future dated accounts may not yet be associated with an interval (CR11047)
      IF @intervalenddate IS NOT NULL
      BEGIN
        -- figures out the new interval ID based on the end date of the current interval  
			  SELECT 
          @intervalID = id_interval,
         @pc_start = dt_start,
          @pc_end = dt_end 
			  FROM t_pc_interval
        WHERE
          id_cycle = @usagecycleID AND
			    dbo.addsecond(@intervalenddate) BETWEEN dt_start AND dt_end

        -- inserts the new usage interval if it doesn't already exist
        -- (needed for foreign key relationship in t_acc_usage_interval)
			  INSERT INTO t_usage_interval
        SELECT 
          @intervalID,
          @usagecycleID,
          @pc_start,
          @pc_end,
          'O'
			  WHERE @intervalID NOT IN (SELECT id_interval FROM t_usage_interval)

			  -- creates the special t_acc_usage_interval mapping to the interval of
        -- new cycle. dt_effective is set to the end of the old interval.
			  INSERT INTO t_acc_usage_interval 
			  SELECT @accountID, 
			         @intervalID, 
			         ISNULL(tx_interval_status, 'O'),
			         @intervalenddate
			  FROM t_usage_interval 
			  WHERE id_interval = @intervalID AND 
			        tx_interval_status != 'B'
      END

			-- indicate that the cycle changed
			select @p_newcycle = @UsageCycleID
			select @p_cyclechanged = 1

    END
    else
  	-- indicate to the caller that the cycle did not change
    begin
		select @p_newcycle = @UsageCycleID
    	select @p_cyclechanged = 0
    end

    -- step : update the payment redirection information.  Only update
    -- the payment information if the payer and payer_startdate is specified
    if ((@p_id_payer is NOT NULL OR (@p_payer_login is not NULL AND 
	@p_payer_namespace is not NULL)) AND @p_payer_startdate is NOT NULL) 
    begin
	-- resolve the paying account id if necessary
	if (@p_payer_login is not null and @p_payer_namespace is not null)
	begin
		select @payerId = dbo.LookupAccount(@p_payer_login,@p_payer_namespace) 
		if (@payerID = -1)
	 	begin 
			-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
	 		select @p_status = -486604792
	 		return
	 	end 
	end
	else
	begin
    -- Fix CORE-762: account must be present
    select id_acc from t_account where id_acc = @p_id_payer 
	  if (@@rowcount = 0)
	  begin
		  -- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		  select @p_status = -486604792
		  return
	  end
		select @payerID = @p_id_payer
	end 
		-- default the payer end date to the end of the account
	if (@p_payer_enddate is NULL)
	begin
		select @payerenddate = dbo.mtmaxdate()
	end 
	else
	begin 
		select @payerenddate = @p_payer_enddate
    	end 
	-- find the old payment information
	select @oldpayerstart = vt_start,@oldpayerend = vt_end ,@oldpayer = id_payer
	from t_payment_redirection
	where id_payee = @AccountID and
	dbo.overlappingdaterange(vt_start,vt_end,@p_payer_startdate,dbo.mtmaxdate())=1
	-- if the new record is in range of the old record and the payer is the same as the older payer,
	-- update the record
	if (@payerID = @oldpayer) 
        begin
		exec UpdatePaymentRecord @payerID,@accountID,@oldpayerstart,@oldpayerend,
		 @p_payer_startdate,@payerenddate,@p_systemdate,@p_enforce_same_corporation, @p_account_currency, @p_status output
		if (@p_status <> 1)
		 begin
			return
		 end 

  	end
  	else
	begin
	 	select @payerbillable = case when @payerID = @accountID then @p_billable else NULL end
	 	exec CreatePaymentRecord @payerID,@accountID,@p_payer_startdate,@payerenddate,@payerbillable,
		@p_systemdate,'N', @p_enforce_same_corporation, @p_account_currency, @p_status output
	 	if (@p_status <> 1)
	  	begin
			return
		end
	end
    end
    -- check if the account has any payees before setting the account as Non-billable.  It is important
    -- that this check take place after creating any payment redirection records	
    if dbo.IsAccountBillable(@AccountID) = '1' AND @p_billable = 'N' 
    begin
	if dbo.DoesAccountHavePayees(@AccountID,@p_systemdate) = 'Y'
        begin
		-- MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS
		select @p_status = -486604767
			return
	end
    end

    --payer update done.
    
    
    --ancestor update begun
  if (((@p_ancestor_name is not null AND @p_ancestor_namespace is not NULL)
	 or @p_id_ancestor is not null) AND @p_hierarchy_movedate is not null)
    begin	 
	    if (@p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL)
	    begin
		    select @ancestorID = dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace) 

		    SET @p_id_ancestor_out = @ancestorID
		    if (@ancestorID = -1)
		    begin
			    -- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
			    select @p_status = -486604791
			    return
		    end 
	    end
  	  else
	    begin
		    select @ancestorID = @p_id_ancestor
	    end
	 
	    exec MoveAccount @ancestorID,@AccountID, @p_hierarchy_movedate, @p_enforce_same_corporation, @p_systemdate, @p_status output, @p_old_id_ancestor_out output, @p_ancestor_type output, @p_acc_type output

	    if (@p_status <> 1)
 	    begin
		    return
 	    end 

  end
  --ancestor update done

if (@p_old_id_ancestor_out is null)
begin
	set @p_old_id_ancestor_out = -1
end

if (@p_id_ancestor_out is null)
begin
	set @p_id_ancestor_out = -1
end
  
	-- step : resolve the hierarchy path based on the current time
 		begin
			select @p_hierarchy_path = tx_path  from t_account_ancestor
			where id_ancestor =1  and id_descendent = @AccountID and
				@p_systemdate between vt_start and vt_end

  		if (@p_hierarchy_path is null)
		 begin
			select @p_hierarchy_path = '/'  
 	 	 end

 		end

	--resolve accounts' corporation
	select @p_corporate_account_id = ancestor.id_ancestor from t_account_ancestor ancestor
	inner join t_account acc on ancestor.id_ancestor = acc.id_acc
	inner join t_account_type atype on atype.id_type = acc.id_type
	where
	  ancestor.id_descendent = @AccountID
		AND atype.b_iscorporate = '1'
		AND @p_systemdate  BETWEEN ancestor.vt_start and ancestor.vt_end

  if (@p_corporate_account_id is null)
    set @p_corporate_account_id = @AccountID
    
 -- done
 select @p_accountID = @AccountID
 select @p_status = 1
 end
	