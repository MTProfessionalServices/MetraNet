
CREATE PROCEDURE AddNewAccount(
@p_id_acc_ext  varchar(16),
@p_acc_state  varchar(2),
@p_acc_status_ext  int,
@p_acc_vtstart  datetime,
@p_acc_vtend  datetime,
@p_nm_login  nvarchar(255),
@p_nm_space nvarchar(40),
@p_tx_password  nvarchar(1024),
@p_auth_type integer,
@p_langcode  varchar(10),
@p_profile_timezone  int,
@p_ID_CYCLE_TYPE  int,
@p_DAY_OF_MONTH  int,
@p_DAY_OF_WEEK  int,
@p_FIRST_DAY_OF_MONTH  int,
@p_SECOND_DAY_OF_MONTH int,
@p_START_DAY int,
@p_START_MONTH int,
@p_START_YEAR int,
@p_billable varchar,
@p_id_payer int,
@p_payer_startdate datetime,
@p_payer_enddate datetime,
@p_payer_login nvarchar(255),
@p_payer_namespace nvarchar(40),
@p_id_ancestor int,
@p_hierarchy_start datetime,
@p_hierarchy_end datetime,
@p_ancestor_name nvarchar(255),
@p_ancestor_namespace nvarchar(40),
@p_acc_type varchar(40),
@p_apply_default_policy varchar,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
-- pass the currency through to CreatePaymentRecord
-- stored procedure only to validate it against the payer
-- We have to do it, because the t_av_internal record
--is not created yet
@p_account_currency nvarchar(5),
@p_profile_id int,
@p_login_app varchar(40),
@accountID int,
@status  int OUTPUT,
@p_hierarchy_path varchar(4000) output,
@p_currency nvarchar(10) OUTPUT,
@p_id_ancestor_out int OUTPUT,
@p_corporate_account_id int OUTPUT,
@p_ancestor_type_out varchar(40) OUTPUT
)
as
	declare @existing_account as int
	declare @intervalID as int
	declare @intervalstart as datetime
	declare @intervalend as datetime
	declare @usagecycleID as int
	declare @acc_startdate as datetime
	declare @acc_enddate as datetime
	declare @payer_startdate as datetime
	declare @payer_enddate as datetime
	declare @ancestor_startdate as datetime
	declare @ancestor_enddate as datetime	declare @payerID as int
	declare @ancestorID as int
	declare @siteID as int
	declare @folderName nvarchar(255)
	declare @varMaxDateTime as datetime
	declare @IsNotSubscriber int
	declare @payerbillable as varchar(1)
	declare @authancestor as int
	declare @id_type as int
        declare @dt_end datetime

  set @p_ancestor_type_out = 'Err'
	-- step : validate that the account does not already exist.  Note 
	-- that this check is performed by checking the t_account_mapper table.
	-- However, we don't check the account state so the new account could
	-- conflict with an account that is an archived state.  You would need
	-- to purge the archived account before the new account could be created.
	select @varMaxDateTime = dbo.MTMaxDate()
	select @existing_account = id_acc from t_account_mapper with(updlock) where nm_login=@p_nm_login and nm_space=@p_nm_space
	if (@existing_account is not null) begin
	-- ACCOUNTMAPPER_ERR_ALREADY_EXISTS
	select @status = -501284862
	return
	end 

	-- check account creation business rules
	IF (@p_nm_login not in ('rm', 'mps_folder'))
	BEGIN
	  exec CheckAccountCreationBusinessRules 
			 @p_nm_space, 
			 @p_acc_type, 
			 @p_id_ancestor, 
			 @status output
	  IF (@status <> 1)
		BEGIN
	  	RETURN
		END		
	END	

	-- step : populate the account start dates if the values were
	-- not passed into the sproc
	select 
	@acc_startdate = case when @p_acc_vtstart is NULL then dbo.mtstartofday(@p_systemdate) 
		else dbo.mtstartofday(@p_acc_vtstart) end,
	@acc_enddate = case when @p_acc_vtend is NULL then @varMaxDateTime 
		else dbo.mtendofday(@p_acc_vtend) end
	-- step : populate t_account

 	select @id_type = id_type from t_account_type where name = @p_acc_type
	if (@p_id_acc_ext is null) begin
		insert into t_account(id_acc,id_acc_ext,dt_crt,id_type)
		select @accountID,newid(),@acc_startdate,@id_type 
	end
	else begin
		insert into t_account(id_acc,id_Acc_ext,dt_crt,id_type)
		select @accountID,convert(varbinary(16),@p_id_acc_ext),@acc_startdate,@id_type 
	end 
	-- step : get the account ID
	-- step : initial account state
	insert into t_account_state values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate)
	insert into t_account_state_history values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate,@p_systemdate,@varMaxDateTime)
	-- step : login and namespace information
	insert into t_account_mapper values (@p_nm_login,lower(@p_nm_space),@accountID)
	-- step : user credentials
	-- check if authentification is MetraNetInternal then add user credentials
	IF ISNULL(@p_auth_type,1) = 1 BEGIN
		insert into t_user_credentials (nm_login, nm_space, tx_password) values (@p_nm_login,lower(@p_nm_space),@p_tx_password)
	END

	-- step : t_profile. This looks like it is only for timezone information
	insert into t_profile values (@p_profile_id,'timeZoneID',@p_profile_timezone,'System')
	-- step : site user information
	exec GetlocalizedSiteInfo @p_nm_space,@p_langcode,@siteID OUTPUT
	insert into t_site_user values (@p_nm_login,@siteID,@p_profile_id)


  	--
  	-- associates the account with the Usage Server
  	--

	-- determines the usage cycle ID from the passed in date properties
	if (@p_ID_CYCLE_TYPE IS NOT NULL)
	BEGIN
		SELECT @usagecycleID = id_usage_cycle 
		FROM t_usage_cycle cycle 
	 	 WHERE
		 cycle.id_cycle_type = @p_ID_CYCLE_TYPE AND
	   	(@p_DAY_OF_MONTH = cycle.day_of_month OR @p_DAY_OF_MONTH IS NULL) AND
	   	(@p_DAY_OF_WEEK = cycle.day_of_week OR @p_DAY_OF_WEEK IS NULL) AND
	   	(@p_FIRST_DAY_OF_MONTH = cycle.FIRST_DAY_OF_MONTH OR @p_FIRST_DAY_OF_MONTH IS NULL) AND
	   	(@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH OR @p_SECOND_DAY_OF_MONTH IS NULL) AND
	   	(@p_START_DAY = cycle.START_DAY OR @p_START_DAY IS NULL) AND
	   	(@p_START_MONTH = cycle.START_MONTH OR @p_START_MONTH IS NULL) AND
	   	(@p_START_YEAR = cycle.START_YEAR OR @p_START_YEAR IS NULL)
	
	  	-- adds the account to usage cycle mapping
		INSERT INTO t_acc_usage_cycle VALUES (@accountID, @usagecycleID)
	
	  	-- creates only needed intervals and mappings for this account only.
	  	-- other accounts affected by any new intervals (same cycle) will
	 	-- be associated later in the day via a usm -create
                -- Compare this logic to that in the batch case by noting the mapping between
                -- variables and temp table columns:
                --
                -- tmp.id_account = @accountID
                -- tmp.id_usage_cycle = @usagecycleID
                -- tmp.acc_vtstart = @acc_startdate
                -- tmp.acc_vtend = @acc_enddate
                -- tmp.acc_state = @p_acc_state
                --
                -- Note also that some predicates don't depend on database tables
                -- and these become a surrounding IF statement

                -- Defines the date range that an interval must fall into to
                -- be considered 'active'.
                SELECT @dt_end = (@p_systemdate + n_adv_interval_creation) FROM t_usage_server

                IF 
                  -- Exclude archived accounts.
                  @p_acc_state <> 'AR' 
                  -- The account has already started or is about to start.
                  AND @acc_startdate < @dt_end 
                  -- The account has not yet ended.
                  AND @acc_enddate >= @p_systemdate
                BEGIN
                INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
                SELECT 
                  ref.id_interval,
                  ref.id_cycle,
                  ref.dt_start,
                  ref.dt_end,
                  'O'  -- Open
                FROM 
                t_pc_interval ref                 
                WHERE
                /* Only add intervals that don't exist */
                NOT EXISTS (SELECT 1 FROM t_usage_interval ui WHERE ref.id_interval = ui.id_interval)
                AND 
                ref.id_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                 ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)

                INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
                SELECT
                  @accountID,
                  ref.id_interval,
                  ref.tx_interval_status,
		  NULL
                FROM 
                t_usage_interval ref 
                WHERE
                ref.id_usage_cycle = @usagecycleID AND
                -- Reference interval must at least partially overlap the [minstart, maxend] period.
                (ref.dt_end >= @acc_startdate AND 
                ref.dt_start <= CASE WHEN @acc_enddate < @dt_end THEN @acc_enddate ELSE @dt_end END)
                /* Only add mappings for non-blocked intervals */
                AND ref.tx_interval_status <> 'B'
              END
	END

	-- Non-billable accounts must have a payment redirection record
	if ( @p_billable = 'N' AND 
	(@p_id_payer is NULL and
	(@p_id_payer is null AND @p_payer_login is NULL AND @p_payer_namespace is NULL))) begin
	-- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER
		select @status = -486604768
		return
	end
	-- default the payer start date to the start of the account  
	select @payer_startdate = case when @p_payer_startdate is NULL then @acc_startdate else dbo.mtstartofday(@p_payer_startdate) end,
	 -- default the payer end date to the end of the account if NULL
	@payer_enddate = case when @p_payer_enddate is NULL then @acc_enddate else dbo.mtendofday(@p_payer_enddate) end,
	-- step : default the hierarchy start date to the account start date 
	@ancestor_startdate = case when @p_hierarchy_start is NULL then @acc_startdate else @p_hierarchy_start end,
	-- step : default the hierarchy end date to the account end date
	@ancestor_enddate = case when @p_hierarchy_end is NULL then @acc_enddate else dbo.mtendofday(@p_hierarchy_end) end,
	-- step : resolve the ancestor ID if necessary
	@ancestorID = case when @p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL then
		dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace)  else 
		-- if the ancestor ID iis NULL then default to the root
		case when @p_id_ancestor is NULL then 1 else @p_id_ancestor end
	end,
	-- step : resolve the payer account if necessary
	@payerID = case when 	@p_payer_login is not null and @p_payer_namespace is not null then
		 dbo.LookupAccount(@p_payer_login,@p_payer_namespace) else 
			case when @p_id_payer is NULL then @accountID else @p_id_payer 
			end
		  end
  -- Fix CORE-762: step: @payerID must be > 1 (to eliminate root and synthetic root) and must be present
	select id_acc from t_account where id_acc = @payerID 
	if (@@rowcount = 0)
	begin
		-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		select @status = -486604792
		return
	end

	select id_acc from t_account where id_acc = @ancestorID
	if (@@rowcount= 0) 
		begin
			-- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
			select @status = -486604791
			return
		end 
	else
		begin
			SET @p_id_ancestor_out = @ancestorID
		end
	
	if (upper(@p_acc_type) = 'SYSTEMACCOUNT') begin  -- any one who is not a system account is a subscriber
		select @IsNotSubscriber = 1
	end 
	-- we trust AddAccToHIerarchy to set the status to 1 in case of success
	declare @acc_type_out varchar(40)
	exec AddAccToHierarchy @ancestorID,@accountID,@ancestor_startdate,
	@ancestor_enddate,@acc_startdate,@p_ancestor_type_out output, @acc_type_out output, @status output
	if (@status <> 1)begin 
		return
	end 

	-- Populate t_dm_account and t_dm_account_ancestor table
	declare @id_dm_acc int

      insert into t_dm_account select id_descendent, vt_start, vt_end from
      t_account_ancestor where id_ancestor=1 and id_descendent = @accountID

      set @id_dm_acc = @@identity
      
      insert into t_dm_account_ancestor select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
      from t_account_ancestor aa1
      inner join t_dm_account dm1 with(readcommitted) on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
      inner join t_dm_account dm2 with(readcommitted) on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
      where dm1.id_acc <> dm2.id_acc
      and dm1.vt_start >= dm2.vt_start
      and dm1.vt_end <= dm2.vt_end
      and aa1.id_descendent = @accountID
      and dm1.id_dm_acc = @id_dm_acc

	insert into t_dm_account_ancestor select id_dm_acc,id_dm_acc,0	from t_dm_account where id_acc = @accountID
	-- pass in the current account's billable flag when creating the payment 
	-- redirection record IF the account is paying for itself
	select @payerbillable = case when @payerID = @accountID then
		@p_billable else NULL end
	exec CreatePaymentRecord @payerID,@accountID,
	@payer_startdate,@payer_enddate,@payerbillable,@p_systemdate,'N', @p_enforce_same_corporation, @p_account_currency, @status OUTPUT
	if (@status <> 1) begin
		return
	end   
	
	select @p_hierarchy_path = tx_path  from t_account_ancestor
	where id_descendent = @accountID and (id_ancestor = 1 OR id_ancestor = -1)
	AND @ancestor_startdate between vt_start AND vt_end

	-- if "Apply Default Policy" flag is set, then
	-- figure out "ancestor" id based on account type in case the account is not
	--a subscriber
	--BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break
	declare @polid int
	exec Sp_Insertpolicy 'id_acc', @accountID,'A', @polID output
	
	/* 2/11/2010: TRW - We are now granting the "Manage Account Hierarchies" capability to all accounts
		upon their creation.  They are being granted read/write access to their own account only (not to 
		sub accounts).  This is being done to facilitate access to their own information via the MetraNet
		ActivityServices web services, which are now checking capabilities a lot more */
		
	/* Insert "Manage Account Hierarchies" parent capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		null,
		@polID,
		id_cap_type
	from
		t_composite_capability_type
	where
		tx_name = 'Manage Account Hierarchies'

	declare @id_parent_cap int
	set @id_parent_cap = @@IDENTITY

	/* Insert MTPathCapability atomic capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		@id_parent_cap,
		@polID,
		id_cap_type
	from
		t_atomic_capability_type
	where
		tx_name = 'MTPathCapability'
		
	declare @id_atomic_cap int
	set @id_atomic_cap = @@IDENTITY

	/* Insert into t_path_capability account's path */
	insert into t_path_capability(id_cap_instance, tx_param_name, tx_op, param_value)
	values( @id_atomic_cap, null, null, @p_hierarchy_path + '/')
	
	/* Insert MTEnumCapability atomic capability */
	insert into t_capability_instance(tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
	select
		0x41424344,
		@id_parent_cap,
		@polID,
		id_cap_type
	from
		t_atomic_capability_type
	where
		tx_name = 'MTEnumTypeCapability'
		
	set @id_atomic_cap = @@IDENTITY
	
	/* Insert into t_enum_capability to grant Write access */
	insert into t_enum_capability(id_cap_instance, tx_param_name, tx_op, param_value)
	select
		@id_atomic_cap,
		null,
		'=',
		id_enum_data
	from
		t_enum_data
	where
		nm_enum_data = 'Global/AccessLevel/WRITE'
	
	if
		(UPPER(@p_apply_default_policy) = 'Y' OR
		UPPER(@p_apply_default_policy) = 'T' OR
		UPPER(@p_apply_default_policy) = '1') begin
    SET @authancestor = @ancestorID
		if (@IsNotSubscriber > 0) begin
		 	select @folderName = 
			 CASE 
				WHEN UPPER(@p_login_app) = 'CSR' THEN 'csr_folder'
				WHEN UPPER(@p_login_app) = 'MOM' THEN 'mom_folder'
				WHEN UPPER(@p_login_app) = 'MCM' THEN 'mcm_folder'
				WHEN UPPER(@p_login_app) = 'MPS' THEN 'mps_folder'
				END
			SELECT @authancestor = NULL
      SELECT @authancestor = id_acc  FROM t_account_mapper WHERE nm_login = @folderName
			AND nm_space = 'auth'
			if (@authancestor is null) begin
	 			select @status = 1
	 		end
		end 
		--apply default security policy
		if (@authancestor > 1) begin
			exec dbo.CloneSecurityPolicy @authancestor, @accountID , 'D' , 'A'
		end
	End 
	
	--resolve accounts' corporation
	--select ancestor whose ancestor is of a type that has b_iscorporate set to true.
	select @p_corporate_account_id = ancestor.id_ancestor from t_account_ancestor ancestor
	inner join t_account acc on acc.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on acc.id_type = atype.id_type
	where
	ancestor.id_descendent = @accountID and
	atype.b_iscorporate = '1' 
	AND @acc_startdate  BETWEEN ancestor.vt_start and ancestor.vt_end
	
  if (@p_corporate_account_id is null)
   set @p_corporate_account_id = @accountID
   
	if (@ancestorID <> 1 and @ancestorID <> -1)
	begin
		select @p_currency = c_currency from t_av_internal where id_acc = @ancestorID
		--if cross corp business rule is enforced, verify that currencies match
		if(@p_enforce_same_corporation = '1' AND (upper(@p_currency) <> upper(@p_account_currency)) )
		begin
			-- MT_CURRENCY_MISMATCH
			select @status = -486604737
			return
		end
  end
	-- done
	select @status = 1
