
CREATE PROCEDURE  CreatePaymentRecord (
  @Payer  int,
  @NPA int,
  @startdate  datetime,
  @enddate datetime,
  @payerbillable varchar(1),
  @systemdate datetime,
  @p_fromUpdate char(1),
  @p_enforce_same_corporation varchar(1),
  @p_account_currency nvarchar(5),
  @status int OUTPUT)
  as
  begin

  declare @realstartdate datetime
  declare @realenddate datetime
  declare @accCreateDate datetime
  declare @billableFlag varchar(1)
  declare @payer_state varchar(10)

  select @status = 0
  select @realstartdate = dbo.mtstartofday(@startdate)    
  if (@enddate is NULL)
    begin
    select @realenddate = dbo.mtstartofday(dbo.MTMaxDate()) 
    end
 else
   begin
	if @enddate <> dbo.mtstartofday(dbo.MTMaxDate())
		select @realenddate = DATEADD(d, 1,dbo.mtstartofday(@enddate))
	else
		select @realenddate = @enddate
    end

	select @AccCreateDate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @NPA
	if @realstartdate < @AccCreateDate 
	begin
		-- MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE
		select @status = -486604753
		return
	end
	if @realstartdate = @realenddate begin
		-- MT_PAYMENT_START_AND_END_ARE_THE_SAME
		select @status = -486604735
		return
	end
	if @realstartdate > @realenddate begin
		-- MT_PAYMENT_START_AFTER_END
		select @status = -486604734
		return
	end
	 /* 
		NPA: Non Paying Account
	  Assumptions: The system has already checked if an existing payment
	  redirection record exists.  The user is asked whether the 
	  system should truncate the existing payment redirection record.
	  business rule checks:
	  MT_ACCOUNT_CAN_NOT_PAY_FOR_ITSELF (0xE2FF0007L, -486604793)
	  ACCOUNT_IS_NOT_BILLABLE (0xE2FF0005L,-486604795)
	  MT_PAYMENT_RELATIONSHIP_EXISTS (0xE2FF0006L, -486604794)
	  step 1: Account can not pay for itself
	if (@Payer = @NPA)
	begin
		select @status = -486604793
		return
		end  
	 */
	if (@Payer <> -1)
	begin
		select @billableFlag = case when @payerbillable is NULL then
			dbo.IsAccountBillable(@payer)	else @payerbillable end
		 -- step 2: The account is in a state such that new payment records can be created
		if (@billableFlag = '0') begin
			-- MT_ACCOUNT_IS_NOT_BILLABLE
		select @status = -486604795
			return
		end
	
	
	
		-- make sure that the paying account is active for the entire payment period
		select TOP 1 @payer_state = status from t_account_state
		where dbo.enclosedDateRange(vt_start,vt_end,@realstartdate,dateadd(s, -1, @realenddate)) = 1 AND
		id_acc = @payer
		if (@payer_state is NULL OR @payer_state <> 'AC') AND @payer <> @NPA begin
			-- MT_PAYER_IN_INVALID_STATE
			select @status = -486604736
			return
		end
	

		-- always check that payer and payee are on the same currency
		-- (if they are not the same, of course)
		-- if @p_account_currency parameter was passed as empty string, then 
		-- the call is coming either from MAM, and the currency is not available,
		-- or the call is coming from account update session, where currency is not being
	-- updated. In both cases it won't hurt to resolve it from t_av_internal and check
		-- that it matches payer currency.. ok, in Kona, an account that can never be a payer
		-- need not have a currency, handle this.
		if(@NPA <> @payer)
		begin
			if((LEN(@p_account_currency) = 0) OR (LEN(@p_account_currency) is null))
			begin
			SELECT @p_account_currency = c_currency from t_av_internal WHERE id_acc = @NPA
				if (@p_account_currency is null)
				begin
				  -- check if the account type has the b_canbepayer false, if it is then just assume that it has
				  -- the same currency as the prospective payer.
	  			  declare @NPAPayerRule varchar(1)
	  			  select @NPAPayerRule = b_CanBePayer from t_account_type atype
	  			  inner join t_account acc
	  			  on atype.id_type = acc.id_type
	  			  where acc.id_acc = @NPA
	  			  if (@NPAPayerRule = '0')
	  			    select @p_account_currency = c_currency from t_av_internal where id_acc = @payer
				end
			end
		
			declare @sameCurrency int
			select @sameCurrency = 
				(SELECT COUNT(payerav.id_acc)  from t_av_internal payerav
				where payerav.id_acc = @payer AND upper(payerav.c_currency) = upper(@p_account_currency)
				)
			if @sameCurrency = 0
			begin
				-- MT_PAYER_PAYEE_CURRENCY_MISMATCH
				select @status = -486604728
				return
			end
		end
		-- check that both the payer and Payee are in the same corporate account
		--only check this if business rule is enforced
		--only check this if the payee's current ancestor is not -1
		declare @payeeCurrentAncestor integer
		select @payeeCurrentAncestor = id_ancestor from t_account_ancestor
		where id_descendent = @NPA and  @realstartdate between vt_start AND vt_end
	  and num_generations = 1
	 
		if (@p_enforce_same_corporation = 1 AND @payeeCurrentAncestor <> -1 AND dbo.IsInSameCorporateAccount(@payer,@NPA,@realstartdate) <> 1)
		begin
			-- MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT
			select @status = -486604758
			return
		end
	end
	-- return without doing work in cases where nothing needs to be done
	select @status = count(*) 
	from t_payment_redirection where id_payer = @payer AND id_payee = @NPA
	AND (
		(dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND @p_fromupdate = 'N') 
		OR
		(vt_start <= @realstartdate AND vt_end = @realenddate AND @p_fromupdate = 'Y')
	)
	if @status > 0 begin
		-- account is already paying for the account during the interval.  Simply ignore
		-- the action
		select @status = 1
		return
	end

	exec CreatePaymentRecordBitemporal @payer,@NPA,@realstartdate,@realenddate,@systemdate, @status OUTPUT
  IF @status <> 1
    RETURN -- failure

  -- post-operation business rule checks (relies on rollback of work done up until this point)
  DECLARE @check1 INT, @check2 INT, @check3 INT
  SELECT 
  -- CR9906: checks to make sure the new payer's billing cycle matches all of the payee's 
  -- group subscriptions' BCR constraints
    @check1 = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@systemdate, groups.id_group)), 1),
    -- EBCR cycle constraint checks
    @check2 = ISNULL(MIN(dbo.CheckGroupMembershipEBCRConstraint(@systemdate, groups.id_group)), 1)
  FROM 
  (
    -- gets all of the payee's group subscriptions
    SELECT DISTINCT gsm.id_group id_group
    FROM t_gsubmember gsm
    WHERE gsm.id_acc = @NPA  -- payee ID
  ) groups

  IF (@check1 <> 1)
  BEGIN
    SET @status = @check1
    RETURN
  END
  ELSE IF (@check2 <> 1)
  BEGIN
    SET @status = @check2
    RETURN
  END

  SELECT  
    @check3 = ISNULL(MIN(dbo.CheckGroupReceiverEBCRConstraint(@systemdate, groups.id_group)), 1)
  FROM 
  (
    -- gets all of the payee's receiverships
    SELECT DISTINCT gsrm.id_group id_group
    FROM t_gsub_recur_map gsrm
    WHERE gsrm.id_acc = @NPA  -- payee ID
  ) groups

  IF (@check3 <> 1)
    SET @status = @check3

  -- Part of bug fix for 13588  
  -- check that - if the payee has individual subscriptions to product offerings with BCR constraints, then the
  -- new payer's cycle type satisfies those constraints.
 
  DECLARE @payer_cycle_type int
  DECLARE @check4 int
  -- g. cieplik 1/29/2009 (CORE-660) default "@check4" to 1, if either no rows are returned or id_po is null, then @check4 is 1
  set  @check4 = 1

  set @payer_cycle_type = (select type.id_cycle_type 
    from t_acc_usage_cycle uc
    inner join t_usage_cycle ucc
    on uc.id_usage_cycle = ucc.id_usage_cycle
    inner join t_usage_cycle_type type
    on ucc.id_cycle_type = type.id_cycle_type
    where uc.id_acc = @payer)
  
  -- g. cieplik 1/29/2009 (CORE-660) poConstrainedCycleType returns zero when there is no "ConstrainedCycleType", added predicate to check value being returned from "poConstrainedCycleType
  select top 1 @check4 = ISNULL(id_po, 1) from t_sub sub where id_acc = @NPA
  and id_group is null
  and @realenddate >= sub.vt_start and @realstartdate <= sub.vt_end
  and dbo.POContainsBillingCycleRelative(id_po) = 1
  and @payer_cycle_type <> dbo.poConstrainedCycleType(id_po)
  and 0 <> dbo.poConstrainedCycleType(id_po)
  
  IF (@check4 <> 1)
    SET @status = -289472464

END
