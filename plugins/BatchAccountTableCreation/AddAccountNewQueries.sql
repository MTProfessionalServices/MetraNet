
  -- TODO:  Once we have rewritten the account creation pipeline so that it is batch oriented we
  --          need to revisit whether or not we should continue to recommend the use of applock
  --          at the pipeline level (i.e. via a plug-in at the start of the pipeline) if multiple
  --          account creation pipelines are being run.
  --        Once we have rewritten the account creation pipeline so that it is batch oriented we
  --          should take a look at merging t_localized_site, t_site_user and t_profile into a
  --          single table.
  --
  -- NOTE:  All of the operations in a single batch or session set MUST be of the same type.
  --          So any single batch or session set must contain only 'Add' or 'Update' or 'Delete'
  --          operations.  It can not contain some 'Add' and some 'Update' operations for
  --          example.
  --
  -- PARAMETERS:  %%ENFORCE_SAME_CORPORATION%% - '1' if this business rule should be enforced.
  --                                             '0' if this business rule should not be enforced.
  --              %%TMP_TABLE_NAME%%           - Fully qualified name of the temporary table.
  --                                             (ex. 'NetMeterStage..tmp_create_account')

  -- Step -1: Create useful local variables.
  DECLARE @system_date     DATETIME
  DECLARE @system_datetime DATETIME
  DECLARE @max_datetime    DATETIME

  SELECT @system_datetime = %%%SYSTEMDATE%%%
  SELECT @system_date = dbo.MTStartOfDay(@system_datetime)
  SELECT @max_datetime = dbo.MTMaxDate()

  -- Step 0: Make sure that these values have the right case.
  --         This avoids having to UPPER or LOWER case them before
  --         inserting them into tables in the database.
  UPDATE tmp
  SET    tmp.acc_type = UPPER(tmp.acc_type),
         tmp.nm_space = LOWER(tmp.nm_space)
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 1: Validate that the account does not already exist.  We do
  --         not care if the account already exists in an archived or
  --         deleted state.  We only care if an active account, i.e.
  --         an account listed in t_account_mapper, exists.
  UPDATE tmp
  SET    tmp.status = -501284862  -- ACCOUNTMAPPER_ERR_ALREADY_EXISTS (0xE21F0002)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_mapper map ON tmp.nm_login = map.nm_login
                                 AND tmp.nm_space = map.nm_space
  WHERE  tmp.status IS NULL

  -- Step 2: Check account creation business rules.

  -- Step 2a: An account in the hierarchy cannot be in a system namespace.
  UPDATE tmp
  SET    tmp.status = -486604731  -- MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH (0xE2FF0045)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_namespace nmsp ON tmp.nm_space = nmsp.nm_space
  WHERE tmp.status IS NULL
    AND tmp.nm_login NOT IN ('rm', 'mps_folder')
    AND nmsp.tx_typ_space IN ('system_user', 'system_auth', 'system_mcm', 
                              'system_ops',  'system_rate', 'system_csr')
    AND tmp.id_ancestor IS NOT NULL

  -- Step 2b: An independent (IND) or subscriber (SUB)
  --          account cannot be in a system namespace.
  UPDATE tmp
  SET    tmp.status = -486604732  -- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH (0xE2FF0046)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_namespace nmsp ON tmp.nm_space = nmsp.nm_space
  WHERE tmp.status IS NULL
    AND tmp.nm_login NOT IN ('rm', 'mps_folder')
    AND nmsp.tx_typ_space IN ('system_user', 'system_auth', 'system_mcm',
                              'system_ops',  'system_rate', 'system_csr')
    AND tmp.acc_type IN ('IND', 'SUB')

  -- Step 2c: Only independent (IND) or subscriber (SUB)
  --          accounts can be in the 'system_mps' namespace.
  UPDATE tmp
  SET    tmp.status = -486604732  -- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH (0xE2FF0046)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_namespace nmsp ON tmp.nm_space = nmsp.nm_space
  WHERE tmp.status IS NULL
    AND tmp.nm_login NOT IN ('rm', 'mps_folder')
    AND nmsp.tx_typ_space = 'system_mps'
    AND tmp.acc_type NOT IN ('IND', 'SUB')

  -- Step 3: Update t_account and get each records account id.

  -- Step 3a: Set the account start and end dates.  This removes the time component.
  UPDATE tmp
  SET    tmp.acc_vtstart = CASE WHEN tmp.acc_vtstart IS NULL THEN @system_date
                                                             -- The next line used to call dbo.MTStartOfDay(tmp.acc_vtstart).
                                                             ELSE CAST(ROUND(CAST(tmp.acc_vtstart AS FLOAT), 0, 1) AS DATETIME) END,
         tmp.acc_vtend = CASE WHEN tmp.acc_vtend IS NULL THEN @max_datetime
                                                             -- The next line used to call dbo.MTStartOfDay(tmp.acc_vtend).
                                                         ELSE CAST(ROUND(CAST(tmp.acc_vtend AS FLOAT), 0, 1) AS DATETIME) END,
         tmp.id_acc_ext = CASE WHEN tmp.id_acc_ext IS NULL THEN newid()
                                                           ELSE tmp.id_acc_ext END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 3b: Populate t_account
  INSERT INTO t_account (id_Acc_ext, dt_crt, acc_type)
  SELECT tmp.id_acc_ext, tmp.acc_vtstart, tmp.acc_type
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 3c: Get the account ids.
  UPDATE tmp
  SET    tmp.id_account = acc.id_acc
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account acc ON acc.id_acc_ext = tmp.id_acc_ext
  WHERE tmp.status IS NULL

  -- Step 4: Update the remainder of the account tables.

  -- Step 4a: Set the initial account state.
  INSERT INTO t_account_state (id_acc, status, vt_start, vt_end)
  SELECT id_account, acc_state, acc_vtstart, acc_vtend
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 4b: Set the initial account state history.
  INSERT INTO t_account_state_history (id_acc, status, vt_start, vt_end, tt_start, tt_end)
  SELECT id_account, acc_state, acc_vtstart, acc_vtend, @system_datetime, @max_datetime
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 4c: Set the login and namespace information.
  INSERT INTO t_account_mapper (nm_login, nm_space, id_acc)
  SELECT nm_login, nm_space, id_account
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 4d: Specify the user's credential.
  INSERT INTO t_user_credentials (nm_login, nm_space, tx_password)
  SELECT nm_login, nm_space, tx_password
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 4e: Create the profile for this user.
  INSERT INTO t_profile (id_profile, nm_tag, val_tag, tx_desc)
  SELECT tmp.id_profile, 'timeZoneID', tmp.profile_timezone, 'System'
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 4f: Set the user's site information.

  -- Step 4f1: Create entries for any sites that are not currently
  --           listed in the t_localized_site table.

  DECLARE @CursorVar CURSOR
  DECLARE @count AS INT
  DECLARE @i AS INT
  DECLARE @nm_space AS VARCHAR(40)
  DECLARE @langcode AS VARCHAR(10)

  SET @CursorVar = CURSOR FORWARD_ONLY STATIC
    FOR SELECT DISTINCT nm_space, langcode FROM %%TMP_TABLE_NAME%% WHERE (status IS NULL)
  OPEN @CursorVar

  SET @count = @@cursor_rows
  SET @i = 0
  WHILE(@i < @count)
  BEGIN

    SET @i = @i + 1
    FETCH NEXT FROM @CursorVar INTO @nm_space, @langcode

    IF NOT EXISTS (SELECT * FROM t_localized_site WHERE nm_space = @nm_space
                                                    AND tx_lang_code = @langcode)
    BEGIN
      INSERT INTO t_localized_site (nm_space, tx_lang_code) VALUES (@nm_space, @langcode)
    END
  END

  CLOSE @CursorVar
  DEALLOCATE @CursorVar

  -- 4f2: Set the site ids in the temporary table.
  UPDATE tmp
  SET    tmp.id_site = site.id_site
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_localized_site site ON tmp.nm_space = site.nm_space
                                  AND tmp.langcode = site.tx_lang_code
  WHERE  tmp.status IS NULL

  -- 4f3: If a site entry did not exist (if the code above failed
  --      somehow) then set the status to indicate no site found.
  UPDATE %%TMP_TABLE_NAME%%
  SET    status = -486604723 -- MT_UNABLE_TO_CREATE_SITE_RECORD (0xE2FF004D)
  WHERE id_site IS NULL
    AND status  IS NULL

  -- 4f4: Create the site entries for these users.
  INSERT INTO t_site_user (nm_login, id_site, id_profile)
  SELECT tmp.nm_login, tmp.id_site, tmp.id_profile
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 5: Add the usage cycle mappings for the new accounts.

  -- Step 5a: Determine the usage cycle ID from the passed in properties.
  UPDATE tmp
  SET    tmp.id_usage_cycle = tuc.id_usage_cycle
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_usage_cycle tuc ON 
  (    (tmp.id_cycle_type       = tuc.id_cycle_type)
   AND (tmp.day_of_month        = tuc.day_of_month        OR tmp.day_of_month        IS NULL)
   AND (tmp.day_of_week         = tuc.day_of_week         OR tmp.day_of_week         IS NULL)
   AND (tmp.first_day_of_month  = tuc.first_day_of_month  OR tmp.first_day_of_month  IS NULL)
   AND (tmp.second_day_of_month = tuc.second_day_of_month OR tmp.second_day_of_month IS NULL)
   AND (tmp.start_day           = tuc.start_day           OR tmp.start_day           IS NULL)
   AND (tmp.start_month         = tuc.start_month         OR tmp.start_month         IS NULL)
   AND (tmp.start_year          = tuc.start_year          OR tmp.start_year          IS NULL)
  )
  WHERE tmp.status IS NULL

  -- Step 5b: Create the usage cycle mappings for the new accounts.
  INSERT INTO t_acc_usage_cycle (id_acc, id_usage_cycle)
  SELECT tmp.id_account, tmp.id_usage_cycle
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 6: Create the usage intervals for the new accounts.
  --
  -- This code creates needed intervals and mappings only for these new accounts.
  -- Other accounts affected by any new intervals (i.e. on the same cycle) will
  -- be associated later via 'usm -create'.

  BEGIN
    BEGIN TRAN  -- Needed because the code allows this SQL
                -- to be run outside of any transactions.

      -- NOTE: The code inside this BEGIN/END block is closely realted to
      -- CreateUsageIntervals except that it only does work for the accounts we
      -- are currently creating.
      --
      -- This code is used instead of the stored procedure to decrease the total
      -- duration of account creations. Other accounts affected by new intervals
      -- being created are addressed later in the day when a required 'usm -create'
      -- triggers a full CreateUsageIntervals execution.

      -- PRECONDITIONS:
      --
      --   Intervals and mappings will be created and backfilled as long as there
      --   is an entry for the account in t_acc_usage_cycle. Missing mappings will
      --   be detected and added.

      -- Ensures that there is only one instance of this stored procedure or the
      -- CreateUsageIntervals stored procedure being executed right now.
      DECLARE @result INT
      EXEC @result = sp_getapplock @Resource = 'CreateUsageIntervals', @LockMode = 'Exclusive'
      IF @result < 0
      BEGIN
          -- Flag all remaining entries with errors
          -- so that we effectively do no more processing.
          UPDATE tmp
          SET    tmp.status = -486604722 -- MT_ACCOUNT_ERR_DBERROR (0xE2FF004E)
          FROM   %%TMP_TABLE_NAME%% tmp
          WHERE  tmp.status IS NULL
      END

      -- Defines the date range that an interval must fall into to
      -- be considered 'active'.
      DECLARE @dt_end DATETIME
      SELECT @dt_end = (@system_date + n_adv_interval_creation) FROM t_usage_server

      -- This table may have multiple entries for a single account id
      -- depending on the cycle type, the 'active' range and the system date.
      DECLARE @new_mappings TABLE
      (
        id_acc INT NOT NULL,
        id_usage_interval INT NOT NULL
      )

      -- Only create usage intervals for 'active' accounts.
      --
      -- Accounts are considered 'active' if they are valid during the
      -- the interval defined by @system_date and @dt_end and they are
      -- included in the temp table with a NULL status.
      --
      -- Associate accounts with intervals based on their cycle mapping
      -- this will detect missing mappings and add them to the @new_mappings
      -- table variable.
      --
      -- This statement generates a warning:
      --
      --      Warning: Null value is eliminated by an aggregate or other SET operation.
      --
      -- This warning is also generated by the CreateUsageIntervals() stored procedure
      -- that this code was taken from.  We should probably understand why this warning
      -- is being generated once we move this code from prototyping into development.
      INSERT INTO @new_mappings
      SELECT
        auc.id_acc,
        ref.id_interval
      FROM t_acc_usage_cycle auc
      INNER JOIN
      (
        -- Gets the minimal start date for each account.
        SELECT
          accstate.id_acc,
          -- If the usage cycle was updated, consider the time of update as the
          -- start date, this prevents backfilling mappings for the previous cycle.
          MIN(ISNULL(maxaui.dt_effective, accstate.vt_start)) dt_start
        FROM t_account_state accstate
        LEFT OUTER JOIN
        (
          SELECT
            id_acc,
            -- The next line used to call dbo.AddSecond(dt_effective)
            MAX(CASE WHEN dt_effective IS NULL THEN NULL ELSE DATEADD(s, 1, dt_effective) END) dt_effective
          FROM t_acc_usage_interval
          GROUP BY id_acc
        ) maxaui ON maxaui.id_acc = accstate.id_acc
        WHERE
          -- Exclude archived accounts.
          accstate.status <> 'AR' AND
          -- The account has already started or is about to start.
          accstate.vt_start < @dt_end AND
          -- The account has not yet ended.
          accstate.vt_end >= @system_date
        GROUP BY accstate.id_acc
      ) minstart ON minstart.id_acc = auc.id_acc
      INNER JOIN
      (
        -- Get the maximal end date for each account.
        SELECT
          id_acc,
          MAX(CASE WHEN vt_end > @dt_end THEN @dt_end ELSE vt_end END) dt_end
        FROM t_account_state
        WHERE
          -- Exclude archived accounts.
          status <> 'AR' AND
          -- The account has already started or is about to start.
          vt_start < @dt_end AND
          -- The account has not yet ended.
          vt_end >= @system_date
        GROUP BY id_acc
      ) maxend ON maxend.id_acc = minstart.id_acc
      INNER JOIN t_pc_interval ref ON
        ref.id_cycle = auc.id_usage_cycle AND
        -- Reference interval must at least partially overlap the [minstart, maxend] period.
        (ref.dt_end >= minstart.dt_start AND ref.dt_start <= maxend.dt_end)
      LEFT OUTER JOIN t_acc_usage_interval aui ON
        aui.id_usage_interval = ref.id_interval AND
        aui.id_acc = auc.id_acc
      INNER JOIN %%TMP_TABLE_NAME%% tmp ON
        auc.id_acc = tmp.id_account
      WHERE
            -- Only add mappings that don't exist already.
            aui.id_usage_interval IS NULL
            -- Only do for account ids that have not yet encountered an error.
        AND tmp.status IS NULL

      -- SELECT * FROM @new_mappings

      DECLARE @new_intervals TABLE
      (
        id_interval INT NOT NULL,
        id_usage_cycle INT NOT NULL,
        dt_start DATETIME NOT NULL,
        dt_end DATETIME NOT NULL,
        tx_interval_status VARCHAR(1) NOT NULL,
        id_cycle_type INT NOT NULL
      )

      -- Determine what usage intervals need to be added
      -- based on the new account-to-interval mappings.
      INSERT INTO @new_intervals
      SELECT
        ref.id_interval,
        ref.id_cycle,
        ref.dt_start,
        ref.dt_end,
        'O',  -- Open
        uct.id_cycle_type
      FROM t_pc_interval ref
      INNER JOIN
      (
        SELECT DISTINCT id_usage_interval FROM @new_mappings
      ) mappings ON mappings.id_usage_interval = ref.id_interval
      INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ref.id_cycle
      INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
      WHERE
        -- Don't add any intervals already in t_usage_interval.
        ref.id_interval NOT IN (SELECT id_interval FROM t_usage_interval)

      -- SELECT * FROM @new_intervals

      -- Add the new intervals.
      INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
      SELECT id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status
      FROM   @new_intervals

      -- Add the new mappings.
      INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
      SELECT id_acc, id_usage_interval, 'O', NULL
      FROM   @new_mappings

      -- Updates the last interval creation time, useful for debugging.
      UPDATE t_usage_server SET dt_last_interval_creation = @system_datetime

    COMMIT
  END

  -- Step 7: Set up the account hierarchy.

  -- Step 7a: Set the hierarchy start and end dates.  This removes the time component.
  --          Resolve the ancestor id.
  UPDATE tmp
  SET    tmp.hierarchy_start = CASE WHEN tmp.hierarchy_start IS NULL THEN tmp.acc_vtstart
                                                                     -- The next line used to call dbo.MTStartOfDay(tmp.hierarchy_start).
                                                                     ELSE CAST(ROUND(CAST(tmp.hierarchy_start AS FLOAT), 0, 1) AS DATETIME) END,
         tmp.hierarchy_end = CASE WHEN tmp.hierarchy_end IS NULL THEN tmp.acc_vtend
                                                                 -- The next line used to call dbo.MTStartOfDay(tmp.hierarchy_end).
                                                                 ELSE CAST(ROUND(CAST(tmp.hierarchy_end AS FLOAT), 0, 1) AS DATETIME) END,
         tmp.id_ancestor_out = CASE WHEN tmp.ancestor_name IS NOT NULL
                                     AND tmp.ancestor_namespace IS NOT NULL
                                    THEN
                                        -- The next subquery used to be a call do dbo.LookupAccount(tmp.ancestor_name, tmp.ancestor_namespace).
                                        (SELECT acc.id_acc
                                         FROM t_account_mapper acc
                                         WHERE acc.nm_login = tmp.ancestor_name
                                           AND acc.nm_space = tmp.ancestor_namespace)
                                    ELSE
                                        -- If the ancestor id is NULL default to root.
                                        CASE WHEN tmp.id_ancestor IS NULL THEN 1
                                                                          ELSE tmp.id_ancestor END
                                    END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 7b: If this account's ancestor is '1' then it's ancestor is
  --          definitely a folder.
  UPDATE tmp
  SET    tmp.folder = '1'
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND tmp.id_ancestor_out = '1'

  -- Step 7c: If this account's ancestor is not '1' then find out
  --          whether or not this account's ancestor is a folder.
  UPDATE tmp
  SET    tmp.folder = c_folder
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_av_internal int ON tmp.id_ancestor_out = int.id_acc
  WHERE  tmp.status IS NULL
     AND tmp.id_ancestor_out <> '1'

  -- Step 7d: Validate that the ancestor id was successfully resolved,
  --          then validate that the parent account is in the hierarchy,
  --          then validate that the parent account is a folder,
  --          and then validate that the parent account is valid at the
  --          time at which the child account is created.
  UPDATE tmp
  SET    tmp.status = CASE WHEN tmp.id_ancestor_out IS NULL
                           THEN -486604791 -- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT (0xE2FF0009)
                           ELSE (CASE WHEN tmp.folder IS NULL
                                      THEN -486604771 -- MT_PARENT_NOT_IN_HIERARCHY (0xE2FF001D)
                                      ELSE (CASE WHEN tmp.folder = '0'
                                                 THEN -486604799  -- MT_ACCOUNT_NOT_A_FOLDER (0xE2FF0001)
                                                 ELSE (CASE WHEN tmp.acc_vtstart < (SELECT dt_crt FROM t_account WHERE id_acc = tmp.id_ancestor_out)
                                                            THEN -486604746  -- MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START (0xE2FF0036)
                                                            ELSE NULL
                                                            END)
                                                 END)
                                      END)
                          END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 7e: Validate that the account is not already in the
  --          hierarchy for the given time interval.
  UPDATE tmp
  SET    tmp.status = -486604785  -- MT_ACCOUNT_ALREADY_IN_HIEARCHY (0xE2FF000F)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_ancestor anc ON tmp.id_account = anc.id_ancestor
  WHERE  tmp.status IS NULL
     AND tmp.id_account = anc.id_descendent
     AND anc.num_generations = 0
     -- The next AND clause used to be:
     --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
     AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                   OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                THEN 0 ELSE 1 END) = 1)

  -- Step 7f: Save the account id as a string.
  UPDATE tmp
  SET    tmp.account_id_as_string = CAST(tmp.id_account AS VARCHAR(50))
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 7g: Populate t_account_ancestor.
  INSERT INTO t_account_ancestor (id_ancestor, id_descendent, num_generations, vt_start, vt_end, tx_path)
      -- Add records for my parent's ancestors.
      -- Note that these will be one level deeper for me then for my parent.
      SELECT anc.id_ancestor, tmp.id_account, anc.num_generations + 1,
            -- The next case statement used to be a call to dbo.MTMaxOfTwoDates(anc.vt_start, tmp.hierarchy_start).
            CASE WHEN tmp.hierarchy_start IS NULL
                   OR anc.vt_start > tmp.hierarchy_start
                 THEN anc.vt_start
                 ELSE tmp.hierarchy_start END,
            -- The next case statement used to be a call to dbo.MTMinOfTwoDates(anc.vt_end, tmp.hierarchy_end).
            CASE WHEN tmp.hierarchy_end IS NULL
                   OR anc.vt_end < tmp.hierarchy_end
                 THEN anc.vt_end
                 ELSE tmp.hierarchy_end END,
            CASE WHEN anc.id_descendent = 1
                 THEN tx_path + tmp.account_id_as_string
                 ELSE tx_path + '/' + tmp.account_id_as_string END
      FROM t_account_ancestor anc
      INNER JOIN %%TMP_TABLE_NAME%% tmp ON tmp.id_ancestor_out = anc.id_descendent
      WHERE  tmp.status IS NULL
         AND anc.id_ancestor <> anc.id_descendent
         -- The next AND clause used to be:
         --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
         AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                       OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                    THEN 0 ELSE 1 END) = 1)
    UNION ALL
      -- Add the record for my parent.
      SELECT tmp.id_ancestor_out, tmp.id_account, 1, tmp.hierarchy_start, tmp.hierarchy_end,
            CASE WHEN id_descendent = 1 THEN
              tx_path + tmp.account_id_as_string
            ELSE
              tx_path + '/' + tmp.account_id_as_string
            END
      FROM t_account_ancestor anc
      INNER JOIN %%TMP_TABLE_NAME%% tmp ON tmp.id_ancestor_out = anc.id_descendent
      WHERE  tmp.status IS NULL
         AND anc.num_generations = 0
         -- The next AND clause used to be:
         --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
         AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                       OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                    THEN 0 ELSE 1 END) = 1)
    UNION ALL 
      -- Add my record, the record that points me to myself.
      SELECT tmp.id_account, tmp.id_account, 0, tmp.hierarchy_start, tmp.hierarchy_end, tmp.account_id_as_string
      FROM   %%TMP_TABLE_NAME%% tmp
      WHERE  tmp.status IS NULL

  -- Step 7h: Update each parent entry so that they indicate they have children.
  UPDATE anc
  SET anc.b_Children = 'Y'
  FROM t_account_ancestor anc
  INNER JOIN %%TMP_TABLE_NAME%% tmp ON anc.id_descendent = tmp.id_account
                                   AND anc.id_ancestor = tmp.id_ancestor_out
  WHERE  tmp.status IS NULL
     AND anc.num_generations = 1
     -- The next AND clause used to be:
     --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
     AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                   OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                THEN 0 ELSE 1 END) = 1)

  -- Step 8: Resolve the payment redirection status and create
  --         payment redirection records as appropriate.

  -- Step 8a: Non-billable accounts must have a payment redirection record.
  UPDATE tmp
  SET    tmp.status = -486604768  -- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER (0xE2FF0020)
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND tmp.billable = 'N'
     AND tmp.id_payer IS NULL
     AND ((tmp.payer_login IS NULL) OR (tmp.payer_namespace IS NULL))

  -- Step 8b: Set the payer start and end dates.  This removes the time component.
  UPDATE tmp
  SET    tmp.payer_startdate = CASE WHEN tmp.payer_startdate IS NULL THEN tmp.acc_vtstart
                                                                     -- The next line used to call dbo.MTStartOfDay(tmp.payer_startdate).
                                                                     ELSE CAST(ROUND(CAST(tmp.payer_startdate AS FLOAT), 0, 1) AS DATETIME) END,
         tmp.payer_enddate = CASE WHEN tmp.payer_enddate IS NULL THEN tmp.acc_vtend
                                                                 -- The next line used to call dbo.MTStartOfDay(tmp.payer_enddate).
                                                                 ELSE CAST(ROUND(CAST(tmp.payer_enddate AS FLOAT), 0, 1) AS DATETIME) END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 8c: Adjust the payer end date.
  UPDATE tmp
  SET    tmp.payer_enddate = DATEADD(d, 1, tmp.payer_enddate)
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND tmp.payer_enddate <> @max_datetime

  -- Step 8d: Resolve the payer id.
  UPDATE tmp
  SET    tmp.id_payer = CASE WHEN tmp.payer_login IS NOT NULL
                              AND tmp.payer_namespace IS NOT NULL
                             THEN
                                  -- The next subquery used to be a call do dbo.LookupAccount(tmp.payer_login, tmp.payer_namespace).
                                  (SELECT acc.id_acc
                                    FROM t_account_mapper acc
                                    WHERE ((acc.nm_login = tmp.payer_login)
                                      AND (acc.nm_space = tmp.payer_namespace)))
                             ELSE (CASE WHEN tmp.id_payer IS NULL
                                        THEN tmp.id_account
                                        ELSE tmp.id_payer
                                        END)
                             END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 8e: Validate the payer id, then validate that we do not have a payer for the account
  --          before the account exists, then validate that we don't have any payers starting
  --          and ending on the same day, and then validate that we don't have a payer start date
  --          that is after the related payer end date.
  UPDATE tmp
  SET    tmp.status = CASE WHEN tmp.id_payer IS NULL
                           THEN -486604792  -- MT_CANNOT_RESOLVE_PAYING_ACCOUNT (0xE2FF0008)
                           ELSE (CASE WHEN tmp.payer_startdate < tmp.acc_vtstart
                                      THEN -486604753 -- MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE (0xE2FF002F)
                                      ELSE (CASE WHEN tmp.payer_startdate = tmp.payer_enddate
                                                 THEN -486604735  -- MT_PAYMENT_START_AND_END_ARE_THE_SAME (0xE2FF0041)
                                                 ELSE (CASE WHEN tmp.payer_startdate > tmp.payer_enddate
                                                            THEN -486604734 -- MT_PAYMENT_START_AFTER_END (0xE2FF0042)
                                                            ELSE NULL
                                                            END)
                                                 END)
                                      END)
                          END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  -- Step 8h: Validate that we do not have an account without a billable payer.
  --
  --          The two statements in this step used to be combined and
  --          they used to call dbo.IsAccountBillable(tmp.id_payer).

  UPDATE tmp
  SET    tmp.billable_payer = CASE WHEN tmp.id_payer = tmp.id_account
                                   THEN tmp.billable
                                   ELSE (
                                          SELECT int.c_billable
                                          FROM   t_av_internal int
                                          WHERE tmp.status IS NULL
                                            AND tmp.id_payer = int.id_acc
                                        ) END
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL

  UPDATE tmp
  SET    tmp.status = -486604795  -- MT_ACCOUNT_IS_NOT_BILLABLE (0xE2FF0005)
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND ((tmp.billable_payer = '0') OR (tmp.billable_payer IS NULL))

  -- Step 8i: Independent accounts are not allowed to have a payer other then themselves.
  UPDATE tmp
  SET    tmp.status = -486604757  -- MT_CANNOT_PAY_FOR_INDEPENDENT_ACCOUNT (0xE2FF002B)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account acc ON tmp.id_account = acc.id_acc
  WHERE  tmp.status IS NULL
     AND tmp.id_payer <> tmp.id_account
     AND acc.acc_type = 'IND'

  -- Step 8j: The paying account must be active for the entire payment period.
  UPDATE tmp
  SET    tmp.status = -486604736  -- MT_PAYER_IN_INVALID_STATE (0xE2FF0040)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_state ast ON tmp.id_payer = ast.id_acc
                                 -- The next AND clause used to be:
                                 --   AND (dbo.EnclosedDateRange(ast.vt_start, ast.vt_end, tmp.payer_startdate, tmp.payer_enddate) = 1))
                                 AND ((CASE WHEN (tmp.payer_startdate >= ast.vt_start
                                              AND tmp.payer_enddate <= ast.vt_end)
                                            THEN 1 ELSE 0 END) = 1)
  WHERE  tmp.status IS NULL
    AND  ((ast.status IS NULL) OR (ast.status <> 'AC'))

  -- Step 8k: Verify that payer and payee are using the same currency.
  --          Note that t_av_internal records do not yet exist for the
  --          new accounts we are adding.  This means that the inner join
  --          on 'tmp.id_payer = int.id_acc' will drop them from the
  --          results (because they won't have an int.id_acc).  This is
  --          fine because if an account is paying for itself then it
  --          must be using the same currency.
  UPDATE tmp
  SET    tmp.status = -486604728  -- MT_PAYER_PAYEE_CURRENCY_MISMATCH (0xE2FF0048)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_av_internal int ON tmp.id_payer = int.id_acc
  WHERE  tmp.status IS NULL
     AND int.c_currency <> tmp.account_currency

  -- Step 8l: The payer and payee must be in the same corporate
  --          account if the 'enforce same corporation' flag is set.
  --
  --          This statement used to be much simpler and used to call
  --          dbo.IsInSameCorporateAccount(tmp.id_payer, tmp.id_account, tmp.payer_startdate).

  UPDATE tmp
  SET    tmp.same_corporation = CASE WHEN parentcorp.id_ancestor = desccorp.id_ancestor
                                     THEN 1
                                     ELSE 0 END
  FROM  t_account_ancestor descendent
  INNER JOIN %%TMP_TABLE_NAME%% tmp ON descendent.id_descendent = tmp.id_payer
                                   AND tmp.payer_startdate BETWEEN descendent.vt_start AND descendent.vt_end
                                   AND descendent.id_ancestor = 1
  INNER JOIN t_account_ancestor parent ON parent.id_descendent = tmp.id_account
                                      AND parent.id_ancestor = 1
                                      AND tmp.payer_startdate BETWEEN parent.vt_start AND parent.vt_end
  INNER JOIN t_account_ancestor parentcorp ON parentcorp.id_descendent = tmp.id_account
                                          AND tmp.payer_startdate BETWEEN parentcorp.vt_start AND parentcorp.vt_end
                                          AND parentcorp.num_generations = parent.num_generations - 1
  INNER JOIN t_account_ancestor desccorp ON desccorp.id_descendent = tmp.id_payer
                                        AND tmp.payer_startdate BETWEEN desccorp.vt_start AND desccorp.vt_end
                                        AND desccorp.num_generations = descendent.num_generations - 1
  WHERE tmp.status IS NULL

  UPDATE tmp
  SET    tmp.status = -486604758  -- MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT (0xE2FF002A)
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND %%ENFORCE_SAME_CORPORATION%% = 1
     AND tmp.id_payer <> tmp.id_account
     AND ((tmp.same_corporation IS NULL) OR (tmp.same_corporation <> 1))

  -- Step 8m: Create the new payment record.

  -- Step 8m1: Create the new payment redirection history record.
  INSERT INTO t_payment_redir_history (id_payer, id_payee, vt_start, vt_end, tt_start, tt_end)
  SELECT
      tmp.id_payer,
      tmp.id_account,
      tmp.payer_startdate,
      CASE WHEN tmp.payer_enddate = @max_datetime THEN @max_datetime
                                                  -- The next statement used to call dbo.SubtractSecond(tmp.payer_enddate).
                                                  ELSE DATEADD(s, -1, tmp.payer_enddate) END,
      @system_datetime,
      @max_datetime
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.status IS NULL

  -- Step 8m2: Create the new payment redirection record.
  INSERT INTO t_payment_redirection (id_payer, id_payee, vt_start, vt_end)
  SELECT his.id_payer, his.id_payee, his.vt_start, his.vt_end
  FROM   t_payment_redir_history his
  JOIN %%TMP_TABLE_NAME%% tmp ON his.id_payee = tmp.id_account
  WHERE  tmp.status IS NULL
     AND his.tt_end = @max_datetime

  -- Step 9: Apply default security if appropriate.
  --
  --         All of the statements in Step 9 used to be a simple
  --         call to 'dbo.CloneSecurityPolicy @auth_ancestor, @id_account, 'D', 'A''.

  -- Step 9a: Determine the account that the default security
  --          policy should be inherited from for subscriptions.
  UPDATE tmp
  SET    tmp.auth_ancestor = tmp.id_ancestor_out
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
     AND tmp.apply_default_policy = 'T'
     AND tmp.acc_type = 'SUB'

  -- Step 9b: Determine the account that the default security
  --          policy should be inherited from for non-subscriptions.
  UPDATE tmp
  SET    tmp.auth_ancestor = map.id_acc
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_mapper map
    ON tmp.id_account = map.id_acc
  WHERE  tmp.status IS NULL
     AND tmp.apply_default_policy = 'T'
     AND tmp.acc_type <> 'SUB'
     AND map.nm_login = CASE WHEN tmp.acc_type = 'CSR' THEN 'csr_folder'
                                                       WHEN tmp.acc_type = 'MCM' THEN 'mcm_folder'
                                                       WHEN tmp.acc_type = 'MOM' THEN 'mom_folder'
                                                       WHEN tmp.acc_type = 'IND' THEN 'mps_folder'
                                                                                 ELSE NULL END
     AND map.nm_space = 'auth'

  -- Step 9c: Find and apply the default security policy.

  -- Step 9c1: Get the default ('D') security policy id for each parent.
  UPDATE tmp
  SET    tmp.parent_policy = pr.id_policy
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_principal_policy pr ON pr.id_acc = tmp.auth_ancestor
                                  AND pr.policy_type= 'D'
  WHERE  tmp.status IS NULL

  -- Step 9c2: If there is no default policy for a parent then create one.
  INSERT INTO t_principal_policy (id_acc, policy_type)
  SELECT tmp.auth_ancestor, 'D'
  FROM %%TMP_TABLE_NAME%% tmp
  WHERE tmp.parent_policy IS NULL
    AND tmp.status IS NULL

  -- Step 9c3: Get the active 'A' security policy id for each child.
  UPDATE tmp
  SET    tmp.child_policy = pr.id_policy
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_principal_policy pr ON pr.id_acc = tmp.id_account
                                  AND pr.policy_type= 'A'
  WHERE  tmp.status IS NULL

  -- Step 9c4: If there is no active policy for a child then create one.
  INSERT INTO t_principal_policy (id_acc, policy_type)
  SELECT tmp.id_account, 'A'
  FROM   %%TMP_TABLE_NAME%% tmp
  WHERE  tmp.status IS NULL
    AND tmp.child_policy IS NULL

  -- Step 9c5: Now get the active security policy ids for those children
  --           for which we had to create active security policy entries.
  UPDATE tmp
  SET    tmp.child_policy = pr.id_policy
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_principal_policy pr ON pr.id_acc = tmp.id_account
                                  AND pr.policy_type = 'A'
  WHERE  tmp.status IS NULL
    AND tmp.child_policy IS NULL

  -- Step 9c6: Validate that all accounts have a security policy.
  UPDATE %%TMP_TABLE_NAME%%
  SET    status = -486604721 -- MT_UNABLE_TO_CREATE_POLICY_RECORD (0xE2FF004F)
  WHERE status IS NULL
    AND child_policy IS NULL

  -- Step 9c7: If a role exists for this account's parent's default security policy then
  --           insert the policy to role mapping record for this account into t_policy_role.
  INSERT INTO t_policy_role (id_policy, id_role)
  SELECT tmp.child_policy, pr.id_role
  FROM t_policy_role pr
  INNER JOIN t_principal_policy pp ON pp.id_policy = pr.id_policy
  INNER JOIN %%TMP_TABLE_NAME%% tmp ON pp.id_acc = tmp.auth_ancestor
                                   AND pp.policy_type = 'D'
  WHERE tmp.status IS NULL

  -- Step 10: Set the hierarchy path to return.
  UPDATE tmp
  SET    tmp.hierarchy_path = anc.tx_path
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_ancestor anc ON  tmp.id_account = anc.id_descendent
                                    AND anc.id_ancestor = 1
                                    AND tmp.hierarchy_start BETWEEN anc.vt_start AND anc.vt_end
  WHERE  tmp.status IS NULL

  -- Step 11: Get the corporation ids for these accounts.
  UPDATE tmp
  SET    tmp.id_corporation = anc.id_ancestor
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_account_ancestor anc ON anc.id_descendent = tmp.id_account
  INNER JOIN t_account_ancestor corp ON corp.id_descendent = anc.id_ancestor
  WHERE corp.id_ancestor = 1
    AND corp.num_generations = 1
    AND tmp.acc_vtstart BETWEEN anc.vt_start AND anc.vt_end
    AND tmp.acc_vtstart BETWEEN corp.vt_start AND corp.vt_end
    AND tmp.status IS NULL

  -- Step 12: If we are enforcing the 'same corporation' business
  --          rule then each account must use the same currency
  --          as thier parents.
  UPDATE tmp
  SET    tmp.status = -486604737  -- MT_CURRENCY_MISMATCH (0xE2FF003F)
  FROM   %%TMP_TABLE_NAME%% tmp
  INNER JOIN t_av_internal int ON tmp.id_ancestor_out = int.id_acc
  WHERE  tmp.status IS NULL
     AND %%ENFORCE_SAME_CORPORATION%% = 1
     AND int.c_currency <> tmp.account_currency

  -- Step 13: Return the results.
--  SELECT id_request, status, id_account, id_ancestor_out, id_corporation, hierarchy_path, acc_type, nm_space
--  FROM %%TMP_TABLE_NAME%%
--  ORDER BY id_request ASC
