
        create or replace PROCEDURE CreateUsageIntervals
        (
            dt_now   DATE,  /* the MetraTech system's date */
            pretend  INT,       /* if true doesn't create new intervals but returns what would have been created */
            n_count  OUT INT,  /* the count of intervals created (or that would have been created) */
            res OUT sys_refcursor
        )
        AS
            result INT;
            dt_end DATE;
        BEGIN
              /*  */
              /* PRECONDITIONS: */
              /*   Intervals and mappings will be created and backfilled as long as there */
              /*   is an entry for the account in t_acc_usage_cycle. Missing mappings will */
              /*   be detected and added. */
              /*  */
              /*   To update a billing cycle: t_acc_usage_cycle must be updated. Also the */
              /*   new interval the account is updating to must be created and the initial */
              /*   special update mapping must be made in t_acc_usage_interval - dt_effective */
              /*   must be set to the end date of the previous (old) interval. */
              /*  */
            
              /* ensures that there is only one instance of this sproc executing right now */
            /*  
              EXEC @result = sp_getapplock @Resource = 'CreateUsageIntervals', @LockMode = 'Exclusive'
              IF @result < 0
              BEGIN
                  ROLLBACK
                  RETURN
              END 
            */
            
				EXECUTE IMMEDIATE 'TRUNCATE TABLE CreateUsageIntervals_rs';
				EXECUTE IMMEDIATE 'TRUNCATE TABLE tmp_new_acc_interval_map';
              /* represents the end date that an interval must */
              /* fall into to be considered */
          for i in (
          SELECT (dt_now + n_adv_interval_creation) dt_end FROM t_usage_server where rownum =1) loop
                dt_end := i.dt_end;
          end loop;

              /* associate accounts with intervals based on their cycle mapping */
              /* this will detect missing mappings and add them */
              INSERT INTO tmp_new_acc_interval_map
              SELECT
                auc.id_acc,
                ref.id_interval,
                nvl(ui.tx_interval_status, 'O')  /* TODO: this column is no longer used and should eventually be removed */
              FROM t_acc_usage_cycle auc
              INNER JOIN
              (
                /* gets the minimal start date for each account */
                SELECT
                  accstate.id_acc,
                  /* if the usage cycle was updated, consider the time of update as the start date */
                  /* this prevents backfilling mappings for the previous cycle */
                  MIN(NVL(maxaui.dt_effective, accstate.vt_start)) dt_start
                FROM t_account_state accstate
                LEFT OUTER JOIN
                (
                  SELECT
                    id_acc,
                    MAX(CASE WHEN dt_effective IS NULL THEN NULL ELSE dbo.AddSecond(dt_effective) END) dt_effective
                  FROM t_acc_usage_interval
                  GROUP BY id_acc
                ) maxaui ON maxaui.id_acc = accstate.id_acc
                WHERE
                  /* excludes archived accounts */
                  accstate.status <> 'AR' AND
                  /* the account has already started or is about to start */
                  accstate.vt_start < dt_end AND
                  /* the account has not yet ended */
                  accstate.vt_end >= dt_now
                GROUP BY accstate.id_acc
              ) minstart ON minstart.id_acc = auc.id_acc
              INNER JOIN
              (
                /* gets the maximal end date for each account */
                SELECT
                  id_acc,
                  MAX(CASE WHEN vt_end > dt_end THEN dt_end ELSE vt_end END) dt_end
                FROM t_account_state
                WHERE
                  /* excludes archived accounts */
                  status <> 'AR' AND
                  /* the account has already started or is about to start */
                  vt_start < dt_end AND
                  /* the account has not yet ended */
                  vt_end >= dt_now
                GROUP BY id_acc
              ) maxend ON maxend.id_acc = minstart.id_acc
              INNER JOIN t_pc_interval ref ON
                ref.id_cycle = auc.id_usage_cycle AND
                /* reference interval must at least partially overlap the [minstart, maxend] period */
                (ref.dt_end >= minstart.dt_start AND ref.dt_start <= maxend.dt_end)
              LEFT OUTER JOIN t_acc_usage_interval aui ON
                aui.id_usage_interval = ref.id_interval AND
                aui.id_acc = auc.id_acc
              LEFT OUTER JOIN t_usage_interval ui
                ON ui.id_interval = ref.id_interval 
              WHERE
                /* only add mappings that don't exist already */
                aui.id_usage_interval IS NULL and
                /* Only add mappings for non-blocked intervals */
								(ui.tx_interval_status IS NULL OR ui.tx_interval_status != 'B');
            
              /*  SELECT * FROM tmp_new_acc_interval_map */
              /* determines what usage intervals need to be added */
              /* based on the new account-to-interval mappings */
              INSERT INTO CreateUsageIntervals_rs
              SELECT
                ref.id_interval,
                ref.id_cycle,
                ref.dt_start,
                ref.dt_end,
                'O',  /* Open */
                uct.id_cycle_type
              FROM t_pc_interval ref
              INNER JOIN
              (
                SELECT DISTINCT id_usage_interval FROM tmp_new_acc_interval_map
              ) mappings ON mappings.id_usage_interval = ref.id_interval
              INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ref.id_cycle
              INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
              WHERE
                /* don't add any intervals already in t_usage_interval */
                ref.id_interval NOT IN (SELECT id_interval FROM t_usage_interval);
            
              /* records how many intervals would be added */
              n_count := SQL%ROWCOUNT;
            
              /* only adds the new intervals and mappings if pretend is false */
              IF NVL(pretend, 0) = 0 THEN
            
                /* adds the new intervals */
                INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
                SELECT id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status
                FROM CreateUsageIntervals_rs;
            
                /* adds the new mappings */
                /* CORE-1578 added order by to improve performance of insert */ 
                INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
                SELECT id_acc, id_usage_interval, tx_status, NULL
                FROM tmp_new_acc_interval_map
                order by id_acc,id_usage_interval;
            
                /* updates the last interval creation time, useful for debugging */
                UPDATE t_usage_server SET dt_last_interval_creation = dt_now;
              END IF;
							open res for SELECT * FROM CreateUsageIntervals_rs;         
              COMMIT;
        END CreateUsageIntervals;
  