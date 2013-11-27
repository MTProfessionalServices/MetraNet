
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
          SELECT @system_date = CAST(ROUND(CAST(@system_datetime AS FLOAT), 0, 1) AS DATETIME)
          SELECT @max_datetime = '2038-01-01'

          -- Step 0: Make sure that these values have the right case.
          --         This avoids having to UPPER or LOWER case them before
          --         inserting them into tables in the database.
          UPDATE tmp
          SET    tmp.acc_type = UPPER(tmp.acc_type),
                tmp.nm_space = LOWER(tmp.nm_space)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 1: Validate that the account does not already exist.  We do
          --         not care if the account already exists in an archived or
          --         deleted state.  We only care if an active account, i.e.
          --         an account listed in t_account_mapper, exists.
          UPDATE tmp
          SET    tmp.status = -501284862  -- ACCOUNTMAPPER_ERR_ALREADY_EXISTS (0xE21F0002)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_mapper map ON tmp.nm_login = map.nm_login
                                        AND tmp.nm_space = map.nm_space
          WHERE  tmp.status IS NULL

          -- Step 2: Check account creation business rules.

          -- Step 2a: Only system accounts can be in the system namespace
          UPDATE tmp
          SET    tmp.status = -486604732  -- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH (0xE2FF0046)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_namespace nmsp ON tmp.nm_space = nmsp.nm_space
          WHERE tmp.status IS NULL
            AND tmp.nm_login NOT IN ('rm', 'mps_folder')
            AND nmsp.tx_typ_space IN ('system_auth', 'system_mcm',
                                      'system_ops',  'system_rate', 
                                      'system_user')
            AND tmp.acc_type <> 'SYSTEMACCOUNT'

          -- Step 2b: Only non system accounts can be in the 'system_mps' namespace
          UPDATE tmp
          SET    tmp.status = -486604732  -- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH (0xE2FF0046)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_namespace nmsp ON tmp.nm_space = nmsp.nm_space
          WHERE tmp.status IS NULL
            AND tmp.nm_login NOT IN ('rm', 'mps_folder')
            AND nmsp.tx_typ_space = 'system_mps'
            AND tmp.acc_type = 'SYSTEMACCOUNT'
            
          -- Step 2c: Only accounts that have the b_CanHaveSyntheticRoot set to 1, can have -1 as ancestor
          UPDATE tmp
          SET tmp.status = -486604713  -- MT_ANCESTOR_INVALID_SYNTHETIC_ROOT ((DWORD)0xE2FF0057L)
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_type atype on atype.name = tmp.acc_type
          WHERE tmp.status IS NULL
            AND atype.b_CanHaveSyntheticRoot = '0'
            AND tmp.id_ancestor = -1
            
          -- Step 3: Update t_account and get each records account id.

          -- Step 3a: Set the account start and end dates.  This removes the time component.
          UPDATE tmp
          SET    tmp.acc_vtstart = CASE WHEN tmp.acc_vtstart IS NULL THEN @system_date
                                                                    -- The next line used to call dbo.MTStartOfDay(tmp.acc_vtstart).
                                                                    ELSE CAST(ROUND(CAST(tmp.acc_vtstart AS FLOAT), 0, 1) AS DATETIME) END,
                tmp.acc_vtend = CASE WHEN tmp.acc_vtend IS NULL THEN @max_datetime
                                                                    -- The next line used to call dbo.MTStartOfDay(tmp.acc_vtend).
                                                                  --ELSE CAST(ROUND(CAST(tmp.acc_vtend AS FLOAT), 0, 1) AS DATETIME) END,
                                                                  -- changing to do dbo.MTEndOfDay(tmp.acc_vtend) END,
                                                                  ELSE DATEADD(s, -1, CAST(ROUND(CAST(tmp.acc_vtend + 1 AS FLOAT), 0, 1) AS DATETIME)) END,
                tmp.id_acc_ext = CASE WHEN tmp.id_acc_ext IS NULL THEN newid()
                                                                  ELSE tmp.id_acc_ext END
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 3b: Populate t_account
          INSERT INTO t_account (id_acc,id_Acc_ext, dt_crt, id_type)
          SELECT tmp.id_account,tmp.id_acc_ext, tmp.acc_vtstart, atype.id_type
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          inner join t_account_type atype on atype.name = tmp.acc_type
          WHERE  tmp.status IS NULL

          -- Step 4: Update the remainder of the account tables.

          -- Step 4a: Set the initial account state.
          INSERT INTO t_account_state (id_acc, status, vt_start, vt_end)
          SELECT id_account, acc_state, acc_vtstart, acc_vtend
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.status IS NULL

          -- Step 4b: Set the initial account state history.
          INSERT INTO t_account_state_history (id_acc, status, vt_start, vt_end, tt_start, tt_end)
          SELECT id_account, acc_state, acc_vtstart, acc_vtend, @system_datetime, @max_datetime
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.status IS NULL

          -- Step 4c: Set the login and namespace information.
          INSERT INTO t_account_mapper (nm_login, nm_space, id_acc)
          SELECT nm_login, nm_space, id_account
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.status IS NULL

          -- Step 4d: Specify the user's credential.
          INSERT INTO t_user_credentials (nm_login, nm_space, tx_password)
          SELECT nm_login, nm_space, tx_password
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.status IS NULL

          -- Step 4e: Create the profile for this user.
          INSERT INTO t_profile (id_profile, nm_tag, val_tag, tx_desc)
          SELECT tmp.id_profile, 'timeZoneID', tmp.profile_timezone, 'System'
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
            FOR SELECT DISTINCT nm_space, langcode FROM %%TMP_TABLE_NAME%% WITH(READCOMMITTED) WHERE (status IS NULL)
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 5: Add the usage cycle mappings for the new accounts.
          -- do this only if it makes sense to create the intervals.  If id_cycle_type
          -- is passed in as null, no interval generation is required.
          
          IF ((select count(*) from %%TMP_TABLE_NAME%% where id_cycle_type is not null) > 0)
          BEGIN
            -- Step 5a: Determine the usage cycle ID from the passed in properties.
            UPDATE tmp
            SET    tmp.id_usage_cycle = tuc.id_usage_cycle
            FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
            INNER JOIN t_usage_cycle tuc ON 
            (   (tmp.id_cycle_type       = tuc.id_cycle_type)
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
            FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
            WHERE  tmp.status IS NULL

            -- Step 6: Create the usage intervals for the new accounts.
            --
            -- This code creates needed intervals and mappings only for these new accounts.
            -- Other accounts affected by any new intervals (i.e. on the same cycle) will
            -- be associated later via 'usm -create'.

                -- This code is derived from that in CreateUsageIntervals.  However,
                -- this code no longer mimics the code in CreateUsageIntervals very closely.
                -- That code has some complicated logic that is not in fact necessary for
                -- newly created accounts.  In particular:
                -- 1) we know a priori that t_acc_usage_interval is empty for the accounts in question
                -- 2) we know a priori that t_account_state has a single record for the accounts in question
                -- 3) we know that there is a single entry in t_acc_usage_cycle for the accounts in question
                -- In addition to being much faster, making use of these facts allows us to dispense
                -- with temporary tables that create ugly DTC headaches.

                -- PRECONDITIONS:
                --
                --   Intervals and mappings will be created and backfilled as long as there
                --   is an entry for the account in t_acc_usage_cycle. Missing mappings will
                --   be detected and added.

                -- Defines the date range that an interval must fall into to
                -- be considered 'active'.
                DECLARE @dt_end DATETIME
                SELECT @dt_end = (@system_date + n_adv_interval_creation) FROM t_usage_server

                -- Only create usage intervals for 'active' accounts.
                --
                -- Accounts are considered 'active' if they are valid during the
                -- the interval defined by @system_date and @dt_end and they are
                -- included in the temp table with a NULL status.
                --
                -- When comparing to CreateUsageIntervals it is helpful to know that
                -- we make use of the following facts.   On the left below are column
                -- names that appear in the CreateUsageIntervals queries, on the right 
                -- are the equivalent values in this context:
                -- minstart.dt_start = tmp.acc_vtstart
                -- maxend.dt_end = CASE WHEN tmp.acc_vtend < @dt_end THEN tmp.acc_vtend ELSE @dt_end END
                -- auc.id_usage_cycle = tmp.id_usage_cycle
                -- accstate.status = tmp.acc_state
                -- auc.id_acc=tmp.id_account
                -- no entries in t_acc_usage_interval exist
                --
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
                AND EXISTS (
                  SELECT 1 FROM %%TMP_TABLE_NAME%% tmp 
                  WHERE
                  ref.id_cycle = tmp.id_usage_cycle AND
                  -- Reference interval must at least partially overlap the [minstart, maxend] period.
                  (ref.dt_end >= tmp.acc_vtstart AND 
                   ref.dt_start <= CASE WHEN tmp.acc_vtend < @dt_end THEN tmp.acc_vtend ELSE @dt_end END)
                  -- Only do for account ids that have not yet encountered an error.
                  AND tmp.status IS NULL
                  -- Exclude archived accounts.
                  AND tmp.acc_state <> 'AR' 
                  -- The account has already started or is about to start.
                  AND tmp.acc_vtstart < @dt_end 
                  -- The account has not yet ended.
                  AND tmp.acc_vtend >= @system_date
                )

                INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
                SELECT
                  tmp.id_account,
                  ref.id_interval,
                  ref.tx_interval_status,
		  NULL
                FROM 
                %%TMP_TABLE_NAME%% tmp 
                INNER JOIN t_usage_interval ref ON
                  ref.id_usage_cycle = tmp.id_usage_cycle AND
                  -- Reference interval must at least partially overlap the [minstart, maxend] period.
                  (ref.dt_end >= tmp.acc_vtstart AND 
                   ref.dt_start <= CASE WHEN tmp.acc_vtend < @dt_end THEN tmp.acc_vtend ELSE @dt_end END)
                WHERE
                /* Only add mappings for non-blocked intervals */
                ref.tx_interval_status <> 'B'
                -- Only do for account ids that have not yet encountered an error.
                AND tmp.status IS NULL
                -- Exclude archived accounts.
                AND tmp.acc_state <> 'AR' 
                -- The account has already started or is about to start.
                AND tmp.acc_vtstart < @dt_end 
                -- The account has not yet ended.
                AND tmp.acc_vtend >= @system_date

          END

          -- Step 7: Set up the account hierarchy.

          -- Step 7a: Set the hierarchy start and end dates.  This removes the time component.
          --          Resolve the ancestor id.
          UPDATE tmp
          SET   tmp.hierarchy_start = CASE WHEN tmp.hierarchy_start IS NULL THEN tmp.acc_vtstart
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
                                                CASE WHEN (tmp.id_ancestor IS NULL OR tmp.id_ancestor = 1) THEN 1
                                                     -- Validate that the ancestor id actually exists.
                                                     ELSE (SELECT acc.id_acc FROM t_account acc WHERE acc.id_acc = tmp.id_ancestor) END
                                           END
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

 
          -- Step 7b: Set the folder to be true..  We do not base any checks on folder property
          UPDATE tmp
          SET    tmp.folder = '1'
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
      

          -- Step 7c: Find the type of the ancesotr.
          UPDATE tmp
          SET tmp.ancestor_type = atype.name
                from %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
                inner join t_account acc
                on acc.id_acc = tmp.id_ancestor_out
                inner join t_account_type atype
                on atype.id_type = acc.id_type
                where tmp.status IS NULL
                      and tmp.id_ancestor_out is not NULL
                      
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 7e: Validate that the account is not already in the
          --          hierarchy for the given time interval.
          UPDATE tmp
          SET    tmp.status = -486604785  -- MT_ACCOUNT_ALREADY_IN_HIEARCHY (0xE2FF000F)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_ancestor anc ON tmp.id_account = anc.id_ancestor
          WHERE  tmp.status IS NULL
            AND tmp.id_account = anc.id_descendent
            AND anc.num_generations = 0
            -- The next AND clause used to be:
            --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
            AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                          OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                        THEN 0 ELSE 1 END) = 1)

          -- Stemp 7e1: Make sure that the ancestor allows for account of this type. Kona addition
        UPDATE tmp
          SET tmp.status = -486604714  -- MT_ANCESTOR_OF_INCORRECT_TYPE
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
	        where tmp.status is NULL
	        and tmp.id_request not in
	        (SELECT tmp1.id_request from  %%TMP_TABLE_NAME%% tmp1
          INNER JOIN t_account_type anctype
            ON anctype.name = tmp1.ancestor_type
          INNER JOIN t_account_type desctype
            ON desctype.name = tmp1.acc_type
	        INNER JOIN t_acctype_descendenttype_map map
	          ON anctype.id_type = map.id_type
	          AND desctype.id_type = map.id_descendent_type)
          
        
          
          -- Step 7f: Save the account id as a string.
          UPDATE tmp
          SET    tmp.account_id_as_string = CAST(tmp.id_account AS VARCHAR(50))
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
                    CASE WHEN (anc.id_descendent = 1 OR anc.id_descendent = -1)
                        THEN tx_path + tmp.account_id_as_string
                        ELSE tx_path + '/' + tmp.account_id_as_string END
              FROM t_account_ancestor anc
              INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON tmp.id_ancestor_out = anc.id_descendent
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
                    CASE WHEN (anc.id_descendent = 1 OR anc.id_descendent = -1) THEN
                      tx_path + tmp.account_id_as_string
                    ELSE
                      tx_path + '/' + tmp.account_id_as_string
                    END
              FROM t_account_ancestor anc
              INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON tmp.id_ancestor_out = anc.id_descendent
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
              FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
              WHERE  tmp.status IS NULL

          -- Step 7h: Update each parent entry so that they indicate they have children.
          UPDATE anc
          SET anc.b_Children = 'Y'
          FROM t_account_ancestor anc
          INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON anc.id_descendent = tmp.id_ancestor_out
          WHERE  tmp.status IS NULL
            -- The next AND clause used to be:
            --   AND (dbo.OverlappingDateRange(anc.vt_start, anc.vt_end, tmp.hierarchy_start, tmp.hierarchy_end) = 1))
            AND ((CASE WHEN ((anc.vt_start IS NOT NULL AND anc.vt_start > tmp.hierarchy_end)
                          OR (tmp.hierarchy_start IS NOT NULL AND tmp.hierarchy_start > anc.vt_end))
                        THEN 0 ELSE 1 END) = 1)

			-- Populate t_dm_account and t_dm_account_ancestor table
			insert into t_dm_account select anc.id_descendent, anc.vt_start, anc.vt_end from
			t_account_ancestor anc INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON 
			anc.id_descendent = tmp.id_account
			WHERE  tmp.status IS NULL
			and (anc.id_ancestor=1 OR anc.id_ancestor=-1)
			insert into t_dm_account_ancestor select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
			from t_account_ancestor aa1
			INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON 
			aa1.id_descendent = tmp.id_account
			inner join t_dm_account dm1 on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
			inner join t_dm_account dm2 on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
			WHERE  tmp.status IS NULL
			and dm1.id_acc <> dm2.id_acc
			and dm1.vt_start >= dm2.vt_start
			and dm1.vt_end <= dm2.vt_end
			insert into t_dm_account_ancestor select id_dm_acc,id_dm_acc,0	from t_dm_account acc
			INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON 
			acc.id_acc = tmp.id_account
			WHERE  tmp.status IS NULL

          -- Step 8: Resolve the payment redirection status and create
          --         payment redirection records as appropriate.

          -- Step 8a: Non-billable accounts must have a payment redirection record.
          UPDATE tmp
          SET    tmp.status = -486604768  -- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER (0xE2FF0020), only for non service accounts
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 8c: Adjust the payer end date.
          --Commenting out the step, as EndOfDay is set on vt_enddate in step 3a
          --UPDATE tmp
          --SET    tmp.payer_enddate = DATEADD(d, 1, tmp.payer_enddate)
          --FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          --WHERE  tmp.status IS NULL
          --  AND tmp.payer_enddate <> @max_datetime

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
                                                -- Validate payer id actually exists
                                                ELSE (SELECT acc.id_acc FROM t_account acc WHERE acc.id_acc = tmp.id_payer)
                                                END)
                                    END
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          -- Step 8h: Validate that we do not have an account without a billable payer.
          --
          --          The two statements in this step used to be combined and
          --          they used to call dbo.IsAccountBillable(tmp.id_payer).

          UPDATE tmp
          SET    tmp.billable_payer = CASE WHEN tmp.id_payer = tmp.id_account THEN tmp.billable
                                           WHEN tmp.id_payer = -1 THEN '1'
                                          ELSE (
                                                  SELECT int.c_billable
                                                  FROM   t_av_internal int
                                                  WHERE tmp.status IS NULL
                                                    AND tmp.id_payer = int.id_acc
                                                ) END
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL

          UPDATE tmp
          SET    tmp.status = -486604795  -- MT_ACCOUNT_IS_NOT_BILLABLE (0xE2FF0005)                          
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
            AND ((tmp.billable_payer = '0') OR (tmp.billable_payer IS NULL))

          -- Step 8i: Independent accounts are not allowed to have a payer other then themselves.
          -- independent account service definition does not include a payer, check is redundant

          -- Step 8j: The paying account must be active for the entire payment period.
          UPDATE tmp
          SET    tmp.status = -486604736  -- MT_PAYER_IN_INVALID_STATE (0xE2FF0040)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
	  WHERE EXISTS (
            SELECT 1 FROM t_account_state ast 
            WHERE
            tmp.id_payer = ast.id_acc
            AND tmp.payer_enddate >= ast.vt_start AND tmp.payer_startdate <= ast.vt_end
            AND  ((ast.status IS NULL) OR (ast.status <> 'AC'))
          )
          AND tmp.status IS NULL
            AND tmp.id_payer <> -1

          -- Step 8k: Verify that payer and payee are using the same currency.
          --          Note that t_av_internal records do not yet exist for the
          --          new accounts we are adding.  This means that the inner join
          --          on 'tmp.id_payer = int.id_acc' will drop them from the
          --          results (because they won't have an int.id_acc).  This is
          --          fine because if an account is paying for itself then it
          --          must be using the same currency.  If id_payer is -1, it implies
          --          payer is not yet assigned.
          UPDATE tmp
          SET    tmp.status = -486604728  -- MT_PAYER_PAYEE_CURRENCY_MISMATCH (0xE2FF0048)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_av_internal int ON tmp.id_payer = int.id_acc
          WHERE  tmp.status IS NULL
            AND int.c_currency <> tmp.account_currency
            AND tmp.id_payer = -1

          -- Step 8l: The payer and payee must be in the same corporate
          --          account if the 'enforce same corporation' flag is set.
          --          If id_payer = -1, then the id_ancestor is also the same.
          --          TODO: The ancestor definition has changed.. this query needs to use the new rule
          --          This statement used to be much simpler and used to call
          --          dbo.IsInSameCorporateAccount(tmp.id_payer, tmp.id_account, tmp.payer_startdate).

          UPDATE tmp
          SET    tmp.same_corporation = CASE WHEN parentcorp.id_ancestor = desccorp.id_ancestor
                                            THEN 1
                                            ELSE 0 END
          FROM  t_account_ancestor descendent
          INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
                                           ON descendent.id_descendent = tmp.id_payer
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
          WHERE tmp.status IS NULL AND tmp.id_payer <> -1

          UPDATE tmp
          SET    tmp.status = -486604758  -- MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT (0xE2FF002A)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
            AND %%ENFORCE_SAME_CORPORATION%% = 1
            AND tmp.id_payer <> tmp.id_account
            AND ((tmp.same_corporation IS NULL) OR (tmp.same_corporation <> 1))
            AND tmp.id_payer <> -1
            
          -- Step 8m: Create the new payment record.

          -- Step 8m1: Create the new payment redirection history record.
          INSERT INTO t_payment_redir_history (id_payer, id_payee, vt_start, vt_end, tt_start, tt_end)
          SELECT
              tmp.id_payer,
              tmp.id_account,
              tmp.payer_startdate,
              CASE WHEN tmp.payer_enddate = @max_datetime THEN @max_datetime
                                                          -- The next statement used to call dbo.SubtractSecond(tmp.payer_enddate).
                                                          --ELSE DATEADD(s, -1, tmp.payer_enddate) END,
                                                          ELSE tmp.payer_enddate END,
              @system_datetime,
              @max_datetime
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.status IS NULL

          -- Step 8m2: Create the new payment redirection record.
          INSERT INTO t_payment_redirection (id_payer, id_payee, vt_start, vt_end)
          SELECT his.id_payer, his.id_payee, his.vt_start, his.vt_end
          FROM   t_payment_redir_history his
          JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON his.id_payee = tmp.id_account
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
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
            AND tmp.apply_default_policy = 'T'
            AND tmp.acc_type <> 'SYSTEMACCOUNT'

          -- Step 9b1: Determine the account login that the default security
          --           policy should be inherited from for non-subscriptions.
          UPDATE tmp
          -- ACCOUNTTYPES TODO: what below???
          SET  tmp.parent_login = CASE WHEN tmp.login_app = 'CSR' THEN 'csr_folder'
                                  WHEN tmp.login_app = 'MCM' THEN 'mcm_folder'
                                  WHEN tmp.login_app = 'MOM' THEN 'mom_folder'
                                  WHEN tmp.login_app = 'MPS' THEN 'mps_folder'
                                  ELSE NULL END
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
			    AND tmp.apply_default_policy = 'T'
			    AND tmp.acc_type = 'SYSTEMACCOUNT'

          -- Step 9b2: Determine the account that the default security
          --          policy should be inherited from for non-subscriptions.
          UPDATE tmp
          SET    tmp.auth_ancestor = map.id_acc
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_mapper map
            ON tmp.parent_login = map.nm_login
          WHERE  tmp.status IS NULL
            AND map.nm_space = 'auth'
          
          -- Step 9c: Find and apply the default security policy.

          -- Step 9c1: Get the default ('D') security policy id for each parent.
          UPDATE tmp
          SET    tmp.parent_policy = pr.id_policy
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_principal_policy pr ON pr.id_acc = tmp.auth_ancestor
                                          AND pr.policy_type= 'D'
          WHERE  tmp.status IS NULL

          -- Step 9c2: If there is no default policy for a parent then create one.
          INSERT INTO t_principal_policy (id_acc, policy_type)
          SELECT tmp.auth_ancestor, 'D'
          FROM %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE tmp.parent_policy IS NULL
            AND tmp.status IS NULL

          -- Step 9c3: Get the active 'A' security policy id for each child.
          UPDATE tmp
          SET    tmp.child_policy = pr.id_policy
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_principal_policy pr ON pr.id_acc = tmp.id_account
                                          AND pr.policy_type= 'A'
          WHERE  tmp.status IS NULL

          -- Step 9c4: If there is no active policy for a child then create one.
          INSERT INTO t_principal_policy (id_acc, policy_type)
          SELECT tmp.id_account, 'A'
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          WHERE  tmp.status IS NULL
            AND tmp.child_policy IS NULL

          -- Step 9c5: Now get the active security policy ids for those children
          --           for which we had to create active security policy entries.
          UPDATE tmp
          SET    tmp.child_policy = pr.id_policy
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
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
          INNER JOIN %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED) ON pp.id_acc = tmp.auth_ancestor
                                                               AND pp.policy_type = 'D'
          WHERE tmp.status IS NULL

          -- Step 10: Set the hierarchy path to return.
          UPDATE tmp
          SET    tmp.hierarchy_path = anc.tx_path
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_ancestor anc ON  tmp.id_account = anc.id_descendent
                                            AND (anc.id_ancestor = 1 OR anc.id_ancestor = -1)
                                            AND tmp.hierarchy_start BETWEEN anc.vt_start AND anc.vt_end
          WHERE  tmp.status IS NULL

          -- Step 11: Get the corporation ids for these accounts.
          -- changed for Kona, corporate account is one in the hierarchy, above, where the type
          -- of the account has the isCorporate flag true. We assume that thee is only one account in the
          -- hierarchy with the flag set to true.
   
          UPDATE tmp
          SET    tmp.id_corporation = anc.id_ancestor
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_account_ancestor anc ON anc.id_descendent = tmp.id_account
          INNER JOIN t_account acc ON acc.id_acc = anc.id_ancestor
          INNER JOIN t_account_type atype ON atype.id_type = acc.id_type
          WHERE 
            atype.b_iscorporate = '1'
            AND tmp.acc_vtstart BETWEEN anc.vt_start AND anc.vt_end
            AND tmp.status IS NULL

          UPDATE %%TMP_TABLE_NAME%%
          SET id_corporation = id_account
	        where status IS NULL
           AND id_corporation IS NULL
        
          -- Step 12: If we are enforcing the 'same corporation' business
          --          rule then each account must use the same currency
          --          as thier parents.
          UPDATE tmp
          SET    tmp.status = -486604737  -- MT_CURRENCY_MISMATCH (0xE2FF003F)
          FROM   %%TMP_TABLE_NAME%% tmp WITH(READCOMMITTED)
          INNER JOIN t_av_internal int ON tmp.id_ancestor_out = int.id_acc
          WHERE  tmp.status IS NULL
            AND %%ENFORCE_SAME_CORPORATION%% = 1
            AND int.c_currency <> tmp.account_currency
      