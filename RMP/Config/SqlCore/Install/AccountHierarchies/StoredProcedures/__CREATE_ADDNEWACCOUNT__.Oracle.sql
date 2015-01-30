
CREATE OR REPLACE 
PROCEDURE addnewaccount  (
   p_id_acc_ext                 IN       VARCHAR2,
   p_acc_state                  IN       VARCHAR2,
   p_acc_status_ext             IN       INT,
   p_acc_vtstart                IN       DATE,
   p_acc_vtend                  IN       DATE,
   p_nm_login                   IN       NVARCHAR2,
   p_nm_space                   IN       NVARCHAR2,
   p_tx_password                IN       NVARCHAR2,
   p_auth_type                  IN       INT,
   p_langcode                   IN       VARCHAR2,
   p_profile_timezone           IN       INT,
   p_id_cycle_type              IN       INT,
   p_day_of_month               IN       INT,
   p_day_of_week                IN       INT,
   p_first_day_of_month         IN       INT,
   p_second_day_of_month        IN       INT,
   p_start_day                  IN       INT,
   p_start_month                IN       INT,
   p_start_year                 IN       INT,
   p_billable                   IN       VARCHAR2,
   p_id_payer                   IN       INT,
   p_payer_startdate            IN       DATE,
   p_payer_enddate              IN       DATE,
   p_payer_login                IN       NVARCHAR2,
   p_payer_namespace            IN       NVARCHAR2,
   p_id_ancestor                IN       INT,
   p_hierarchy_start            IN       DATE,
   p_hierarchy_end              IN       DATE,
   p_ancestor_name              IN       NVARCHAR2,
   p_ancestor_namespace         IN       NVARCHAR2,
   p_acc_type                   IN       VARCHAR2,
   p_apply_default_policy       IN       VARCHAR2,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2, /*  pass the currency through to CreatePaymentRecord */ /*  stored procedure only to validate it against the payer */ /*  We have to do it, because the t_av_internal record */ /* is not created yet */
   p_account_currency                    NVARCHAR2,
   p_profile_id                          INT,
   p_login_app                           VARCHAR2,
   accountid                             INTEGER,
   status                       OUT      INTEGER,
   p_hierarchy_path             OUT      VARCHAR2,
   p_currency                   OUT      NVARCHAR2,
   p_id_ancestor_out            OUT      INT,
   p_corporate_account_id       OUT      INT,
   p_ancestor_type_out          OUT      VARCHAR2
)
AS
   existing_account     INTEGER;
   payerid              INT;
   intervalid           INTEGER;
   intervalstart        DATE;
   intervalend          DATE;
   usagecycleid         INTEGER;
   acc_startdate        DATE;
   acc_enddate          DATE;
   payer_startdate      DATE;
   payer_enddate        DATE;
   ancestor_startdate   DATE;
   ancestor_enddate     DATE;
   create_dt_end        DATE;
   ancestorid           INTEGER;
   siteid               INTEGER;
   foldername           VARCHAR2 (255);
   isnotsubscriber      INTEGER;
   payerbillable        VARCHAR2 (1);
   authancestor         INTEGER;
   varmaxdatetime       DATE;
   stoo_error           INTEGER        := 0;
   stoo_errmsg          VARCHAR2 (255);
   temp_count           INT;
   dummycursor          sys_refcursor;
   id_type              INT;
   acc_type_out         VARCHAR2 (40);
   p_count              INTEGER;
   l_polID              INTEGER;
   l_id_parent_cap          INTEGER;
   l_id_atomic_cap          INTEGER;
   templateId           INTEGER;
   templateOwner        INTEGER;
   sessionId            INTEGER;
   templateCount        INTEGER;
BEGIN
   p_ancestor_type_out := 'Err';
/* step : validate that the account does not already exist.  Note    that this check is performed by checking the t_account_mapper table.    However, we don't check the account state so the new account could
conflict with an account that is an archived state.  You would need
to purge the archived account before the new account could be created.
*/
   varmaxdatetime := dbo.mtmaxdate ();
   existing_account := dbo.lookupaccount (p_nm_login, p_nm_space);

   IF existing_account <> -1
   THEN
      /* ACCOUNTMAPPER_ERR_ALREADY_EXISTS*/
      status := -501284862;
      RETURN;
   END IF;

   /* step : check account creation business rules*/
   IF (LOWER (p_nm_login) NOT IN ('rm', 'mps_folder'))
   THEN
      checkaccountcreationbusinessru (p_nm_space,
                                      p_acc_type,
                                      p_id_ancestor,
                                      status
                                     );

      IF (status <> 1)
      THEN
         RETURN;
      END IF;
   END IF;

   /* step : populate the account start dates if the values were
   not passed into the sproc
   */
   SELECT CASE
             WHEN p_acc_vtstart IS NULL
                THEN dbo.mtstartofday (p_systemdate)
             ELSE dbo.mtstartofday (p_acc_vtstart)
          END,
          CASE
             WHEN p_acc_vtend IS NULL
                THEN dbo.mtmaxdate ()
             ELSE dbo.mtendofday (p_acc_vtend)
          END
     INTO acc_startdate,
          acc_enddate
     FROM DUAL;

   /* step : get the account ID and increment counter
   select id_current
     into accountid
     from t_current_id
    where nm_current = 'id_acc';

   update t_current_id
      set id_current = id_current + 1
    where nm_current = 'id_acc'; */

   /* step: populate t_account*/
   SELECT id_type
     INTO id_type
     FROM t_account_type
    WHERE LOWER (NAME) = LOWER (p_acc_type);

   IF p_id_acc_ext IS NULL
   THEN
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, SYS_GUID (), acc_startdate, id_type
                  );
   ELSE
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, p_id_acc_ext, acc_startdate, id_type
                  );
   END IF;

   /* step : initial account state*/
   INSERT INTO t_account_state
               (id_acc, status, vt_start, vt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate
               );

   INSERT INTO t_account_state_history
               (id_acc, status, vt_start, vt_end,
                tt_start, tt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate,
                p_systemdate, varmaxdatetime
               );

   /* step : login and namespace information*/
   INSERT INTO t_account_mapper
               (nm_login, nm_space, id_acc
               )
        VALUES (p_nm_login, LOWER (p_nm_space), accountid
               );

   /* step : user credentials*/
   /* check if authentification is MetraNetInternal then add user credentials */
   IF (COALESCE(p_auth_type, 1) = 1)
   THEN
       INSERT INTO t_user_credentials
                   (nm_login, nm_space, tx_password
                   )
            VALUES (p_nm_login, LOWER (p_nm_space), p_tx_password
                   );
   END IF;

   /* step : t_profile. This looks like it is only for timezone information */
   INSERT INTO t_profile
               (id_profile, nm_tag, val_tag, tx_desc
               )
        VALUES (p_profile_id, 'timeZoneID', p_profile_timezone, 'System'
               );

   /* step : site user information*/
   getlocalizedsiteinfo (p_nm_space, p_langcode, siteid);

   INSERT INTO t_site_user
               (nm_login, id_site, id_profile
               )
        VALUES (p_nm_login, siteid, p_profile_id
               );

   /* associates the account with the Usage Server */

   /* step : determines the usage cycle ID from the passed in date properties*/
   IF (p_id_cycle_type is not null) THEN
	   BEGIN
	      FOR i IN (SELECT id_usage_cycle
	                  FROM t_usage_cycle CYCLE
	                 WHERE CYCLE.id_cycle_type = p_id_cycle_type
	                   AND (   p_day_of_month = CYCLE.day_of_month
	                        OR p_day_of_month IS NULL
	                       )
	                   AND (   p_day_of_week = CYCLE.day_of_week
	                        OR p_day_of_week IS NULL
	                       )
	                   AND (   p_first_day_of_month = CYCLE.first_day_of_month
	                        OR p_first_day_of_month IS NULL
	                       )
	                   AND (   p_second_day_of_month = CYCLE.second_day_of_month
	                        OR p_second_day_of_month IS NULL
	                       )
	                   AND (p_start_day = CYCLE.start_day OR p_start_day IS NULL
	                       )
	                   AND (   p_start_month = CYCLE.start_month
	                        OR p_start_month IS NULL
	                       )
	                   AND (p_start_year = CYCLE.start_year
	                        OR p_start_year IS NULL
	                       ))
	      LOOP
	         usagecycleid := i.id_usage_cycle;
	      END LOOP;
	   END;

	   /* step : add the account to usage cycle mapping */
	   INSERT INTO t_acc_usage_cycle
	               (id_acc, id_usage_cycle
	               )
	        VALUES (accountid, usagecycleid
	               );

	   /* step : creates only needed intervals and mappings for this account only.
	    other accounts affected by any new intervals (same cycle) will
	    be associated later in the day via a usm -create. */
	   /* Defines the date range that an interval must fall into to
	     be considered 'active'. */
	   SELECT (p_systemdate + n_adv_interval_creation) INTO create_dt_end FROM t_usage_server;

	   IF (
	     /* Exclude archived accounts. */
	     p_acc_state <> 'AR'
	     /* The account has already started or is about to start. */
	     AND acc_startdate < create_dt_end
	     /* The account has not yet ended. */
	     AND acc_enddate >= p_systemdate)
	   THEN
	     INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
	     SELECT ref.id_interval,ref.id_cycle,ref.dt_start,ref.dt_end, 'O'
	     FROM
	     t_pc_interval ref
	     WHERE
	     /* Only add intervals that don't exist */
	     NOT EXISTS (
	       SELECT 1 FROM t_usage_interval ui
	       WHERE ref.id_interval = ui.id_interval)
	     AND
	     ref.id_cycle = usagecycleid AND
	     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
	     (ref.dt_end >= acc_startdate AND
	      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END);

	     INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
	     SELECT accountid, ref.id_interval, ref.tx_interval_status, NULL
	     FROM t_usage_interval ref
	     WHERE
	     ref.id_usage_cycle = usagecycleid AND
	     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
	     (ref.dt_end >= acc_startdate AND
	      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END)
	     /* Only add mappings for non-blocked intervals */
	     AND ref.tx_interval_status <> 'B';
	   END IF;
  END IF;
   /* step : Non-billable accounts must have a payment redirection record*/
   IF (    p_billable = 'N'
       AND (    p_id_payer IS NULL
            AND (    p_id_payer IS NULL
                 AND p_payer_login IS NULL
                 AND p_payer_namespace IS NULL
                )
           )
      )
   THEN
      /* MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER*/
      status := -486604768;
      RETURN;
   END IF;

   SELECT
          /* default the payer start date to the start of the account  */
          CASE
             WHEN p_payer_startdate IS NULL
                THEN acc_startdate
             ELSE dbo.mtstartofday (p_payer_startdate)
          END,
          /* default the payer end date to the end of the account if NULL*/
          CASE
             WHEN p_payer_enddate IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday (p_payer_enddate)
          END,
          /* step : default the hierarchy start date to the account start date */
          CASE
             WHEN p_hierarchy_start IS NULL
                THEN acc_startdate
             ELSE p_hierarchy_start
          END,
          /* step : default the hierarchy end date to the account end date*/
          CASE
             WHEN p_hierarchy_end IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday(p_hierarchy_end)
          END,
          /* step : resolve the ancestor ID if necessary*/
          CASE
             WHEN p_ancestor_name IS NOT NULL
             AND p_ancestor_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_ancestor_name, p_ancestor_namespace)
             ELSE
                 /* if the ancestor ID iis NULL then default to the root*/
          CASE
             WHEN p_id_ancestor IS NULL
                THEN 1
             ELSE p_id_ancestor
          END
          END,
          /* step : resolve the payer account if necessary*/
          CASE
             WHEN p_payer_login IS NOT NULL AND p_payer_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_payer_login, p_payer_namespace)
             ELSE CASE
             WHEN p_id_payer IS NULL
                THEN accountid
             ELSE p_id_payer
          END
          END
     INTO payer_startdate,
          payer_enddate,
          ancestor_startdate,
          ancestor_enddate,
          ancestorid,
          payerid
     FROM DUAL;

   /* -- Fix CORE-762: Check that payerid exists */
   begin
     select count(*) into p_count
     from t_account
     where id_acc = payerid;
     if p_count = 0 then /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
       status := -486604792;
       return;
     end if;
   end;

   IF ancestorid = -1
   THEN
      /* MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT*/
      status := -486604791;
      RETURN;
   ELSE
      p_id_ancestor_out := ancestorid;
   END IF;

   IF (UPPER (p_acc_type) = 'SYSTEMACCOUNT')
   THEN
      /* anyone who is not a system account is a subscriber */
      isnotsubscriber := 1;
   END IF;

   /* step: we trust AddAccToHIerarchy to set the status
   to 1 in case of success*/
   addacctohierarchy (ancestorid,
                      accountid,
                      ancestor_startdate,
                      ancestor_enddate,
                      acc_startdate,
                      p_ancestor_type_out,
                      acc_type_out,
                      status
                     );

   IF status <> 1
   THEN
      RETURN;
   END IF;

   /* step: populate t_dm_account and t_dm_account_ancestor table */
   INSERT INTO t_dm_account
               (id_dm_acc, id_acc, vt_start, vt_end)
      SELECT seq_t_dm_account.NEXTVAL, id_descendent, vt_start, vt_end
        FROM t_account_ancestor
       WHERE id_ancestor = 1 AND id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
        FROM t_account_ancestor aa1 INNER JOIN t_dm_account dm1 ON aa1.id_descendent =
                                                                     dm1.id_acc
                                                              AND aa1.vt_start <=
                                                                     dm1.vt_end
                                                              AND dm1.vt_start <=
                                                                     aa1.vt_end
             INNER JOIN t_dm_account dm2 ON aa1.id_ancestor = dm2.id_acc
                                       AND aa1.vt_start <= dm2.vt_end
                                       AND dm2.vt_start <= aa1.vt_end
       WHERE dm1.id_acc <> dm2.id_acc
         AND dm1.vt_start >= dm2.vt_start
         AND dm1.vt_end <= dm2.vt_end
         AND aa1.id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT id_dm_acc, id_dm_acc, 0
        FROM t_dm_account
       WHERE id_acc = accountid;

   /* step: pass in the current account's billable flag when creating the    payment redirection record IF the account is paying for itself */
   SELECT CASE
             WHEN payerid = accountid
                THEN p_billable
             ELSE NULL
          END
     INTO payerbillable
     FROM DUAL;

   createpaymentrecord (payerid,
                        accountid,
                        payer_startdate,
                        payer_enddate,
                        payerbillable,
                        p_systemdate,
                        'N',
                        p_enforce_same_corporation,
                        p_account_currency,
                        status
                       );

   IF (status <> 1)
   THEN
      RETURN;
   END IF;

      BEGIN
      SELECT tx_path
        INTO p_hierarchy_path
        FROM t_account_ancestor
       WHERE id_descendent = accountid
         AND id_ancestor = 1
         AND ancestor_startdate BETWEEN vt_start AND vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   /* if "Apply Default Policy" flag is set, then figure out    "ancestor" id based on account type in case the account is not    a subscriber*/

    /*BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break*/
    Sp_Insertpolicy( 'id_acc', accountID,'A', l_polID );

    /* 2/11/2010: TRW - We are now granting the "Manage Account Hierarchies" capability to all accounts
        upon their creation.  They are being granted read/write access to their own account only (not to
        sub accounts).  This is being done to facilitate access to their own information via the MetraNet
        ActivityServices web services, which are now checking capabilities a lot more */

    /* Insert "Manage Account Hierarchies" parent capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
    'ABCD',
        null,
        l_polID,
        id_cap_type
    from
        t_composite_capability_type
    where
        tx_name = 'Manage Account Hierarchies';

    select seq_t_cap_instance.CURRVAL into l_id_parent_cap from dual;

    /* Insert MTPathCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTPATHCAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_path_capability account's path */
    insert into t_path_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    values( l_id_atomic_cap, null, null, p_hierarchy_path || '/');

    /* Insert MTEnumCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTENUMTYPECAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_enum_capability to grant Write access */
    insert into t_enum_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    select
        l_id_atomic_cap,
        null,
        '=',
        id_enum_data
    from
        t_enum_data
    where
        upper(nm_enum_data) = 'GLOBAL/ACCESSLEVEL/WRITE';

   IF (   UPPER (p_apply_default_policy) = 'Y'
       OR UPPER (p_apply_default_policy) = 'T'
       OR UPPER (p_apply_default_policy) = '1'
      )
   THEN
      authancestor := ancestorid;

      IF isnotsubscriber > 0
      THEN
         foldername :=
            CASE
               WHEN UPPER (p_login_app) = 'CSR'
                  THEN 'csr_folder'
               WHEN UPPER (p_login_app) = 'MOM'
                  THEN 'mom_folder'
               WHEN UPPER (p_login_app) = 'MCM'
                  THEN 'mcm_folder'
               WHEN UPPER (p_login_app) = 'MPS'
                  THEN 'mps_folder'
            END;

         BEGIN
            authancestor := NULL;

            SELECT id_acc
              INTO authancestor
              FROM t_account_mapper
             WHERE UPPER (nm_login) = UPPER (foldername)
               AND UPPER (nm_space) = 'AUTH'; /* record  for ancestor is not on t_account_mapper just return OK*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               status := 1;
         END;
      END IF; /* apply default security policy; only do it if ancestor was found*/

      IF authancestor > 1
      THEN
         clonesecuritypolicy (authancestor, accountid, 'D', 'A');
      END IF;
   END IF;

    /* resolve accounts' corporation.
    select ancestor whose ancestor is of a type that
    has b_iscorporate set to true */

   BEGIN
      SELECT max(ancestor.id_ancestor)
        INTO p_corporate_account_id
        FROM t_account_ancestor ancestor INNER JOIN t_account acc ON acc.id_acc =
                                                                       ancestor.id_ancestor
             INNER JOIN t_account_type atype ON acc.id_type = atype.id_type
       WHERE ancestor.id_descendent = accountid
         AND atype.b_iscorporate = '1'
         AND acc_startdate BETWEEN ancestor.vt_start AND ancestor.vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF (p_corporate_account_id IS NULL)
   THEN
      p_corporate_account_id := accountid;
   END IF;

   IF ancestorid <> 1
   THEN
      BEGIN
         SELECT c_currency
           INTO p_currency
           FROM t_av_internal
          WHERE id_acc = ancestorid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* if cross corp business rule is enforced,
      verify that currencis match */
      IF (    p_enforce_same_corporation = '1'
          AND (LOWER (p_currency) <> LOWER (p_account_currency))
         )
      THEN
         /* MT_CURRENCY_MISMATCH*/
         status := -486604737;
         RETURN;
      END IF;
   END IF;

   /* done*/
   status := 1;
END;