
-- ===========================================================
-- Soft closes one or more billing groups.
-- 1) It is an ERROR for both id_billgroup and id_interval to be non-null
-- 2) If only id_billgroup is non-null, then that billing group will be soft closed, if it is in the 'Open' state
-- 3) If only id_interval is non-null then all 'Open' billing groups for that interval will be soft closed
-- 4) If both id_billgroup and id_interval are null, then all 'Open' billing groups for all intervals 
--     (automatically detected based on grace periods) are soft closed

-- @status is set to the following values:
--   0  - if the procedure executes successfully
--  -1 - if an unknown error occurs
--  -2 - if both @id_billgroup and @id_interval are specified
-- ===========================================================
CREATE PROCEDURE SoftCloseBillingGroups
(
  @dt_now DATETIME,       -- MetraTech system date
  @id_billgroup INT,          -- specific billing group to close or null 
  @id_interval INT,            -- specific usage interval to close or null for automatic detection based on grace periods
  @pretend INT,                 -- if pretend is true no billing groups are closed but instead are just returned
  @n_count INT OUTPUT,   -- the number of billing groups closed (or that would have been closed)
  @status INT OUTPUT      -- error status
)
AS
  
  BEGIN TRAN

  -- Initialize @status
  SET @status = -1
  -- Initialize @n_count
  SET @n_count = 0

  DECLARE @closing_billgroup TABLE
  (
    id_billgroup INT NOT NULL,
    id_interval INT NOT NULL,
    id_usage_cycle INT NOT NULL,
    id_cycle_type INT NOT NULL,
    dt_start DATETIME NOT NULL,
    dt_end DATETIME NOT NULL,
    tx_billgroup_status VARCHAR(1) NOT NULL
  )

  -- ERROR if both @id_billgroup and @id_interval are non null
  IF (@id_billgroup IS NOT NULL AND @id_interval IS NOT NULL)
  BEGIN
     SET @status = -2
     ROLLBACK
     RETURN 
  END

  -- If both @id_billgroup and @id_interval are NULL, then select all 'Open' billing groups
  -- for all valid intervals (based on grace periods)
  IF (@id_billgroup IS NULL AND @id_interval IS NULL)
    BEGIN
       -- looks at all the billing groups in the system
       INSERT INTO @closing_billgroup
       SELECT bgs.id_billgroup, 
                   ui.id_interval, 
                   ui.id_usage_cycle, 
                   uct.id_cycle_type, 
                   ui.dt_start, 
                   ui.dt_end, 
                   'C'
       FROM vw_all_billing_groups_status bgs
       INNER JOIN t_usage_interval ui ON ui.id_interval = bgs.id_usage_interval
       INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
       INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
       WHERE
           CASE WHEN uct.n_grace_period IS NOT NULL 
                    THEN ui.dt_end + uct.n_grace_period -- take into account the cycle type's grace period
                    ELSE @dt_now -- the grace period has been disabled, so don't close this interval
          END < @dt_now AND
          bgs.Status = 'O' -- ui.tx_interval_status = 'O'

          -- Set the row count
          SET @n_count = @@ROWCOUNT
    END
  ELSE
    
       -- If only id_interval is non-null then soft close all 'Open' billing groups for this interval
       --  (regardless of grace period/end date)
       IF (@id_interval IS NOT NULL)
          BEGIN
             INSERT INTO @closing_billgroup
             SELECT bgs.id_billgroup, 
                         ui.id_interval, 
                         ui.id_usage_cycle, 
                         uct.id_cycle_type, 
                         ui.dt_start, 
                         ui.dt_end, 
                         'C'
             FROM vw_all_billing_groups_status bgs
             INNER JOIN t_usage_interval ui ON ui.id_interval = bgs.id_usage_interval
             INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
             INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
             WHERE bgs.status = 'O' AND 
                         bgs.id_usage_interval = @id_interval

             SET @n_count = @@ROWCOUNT
          END
       ELSE
          BEGIN
             -- If we are here then we have a non null @id_billgroup. Soft close it.
             INSERT INTO @closing_billgroup
             SELECT bgs.id_billgroup, 
                         ui.id_interval, 
                         ui.id_usage_cycle, 
                         uct.id_cycle_type, 
                         ui.dt_start, 
                         ui.dt_end, 
                         'C'
             FROM vw_all_billing_groups_status bgs
             INNER JOIN t_usage_interval ui ON ui.id_interval = bgs.id_usage_interval
             INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
             INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
             WHERE bgs.status = 'O' AND 
                         bgs.id_billgroup = @id_billgroup

             SET @n_count = @@ROWCOUNT
          END
   -- only closes the billing groups if pretend is false
  IF @pretend = 0
  BEGIN
   
    -- Update the status of the accounts for the billing group in t_acc_usage_interval
    UPDATE aui 
    SET aui.tx_status = 'C'
    FROM t_acc_usage_interval aui 
    INNER JOIN @closing_billgroup cbg 
       ON cbg.id_interval = aui.id_usage_interval
    INNER JOIN t_billgroup_member bgm 
       ON bgm.id_acc = aui.id_acc AND
             bgm.id_billgroup = cbg.id_billgroup

    -- adds instance entries for each billing group that is closed
    INSERT INTO t_recevent_inst(id_event,
                                                  id_arg_billgroup,
                                                  id_arg_root_billgroup,
                                                  id_arg_interval,
                                                  dt_arg_start,
                                                  dt_arg_end,
                                                  b_ignore_deps,
                                                  dt_effective,
                                                  tx_status)
    SELECT 
      evt.id_event id_event,
      CASE WHEN evt.tx_billgroup_support = 'Interval' THEN NULL 
               ELSE cbg.id_billgroup 
               END id_arg_billgroup,
      CASE WHEN evt.tx_billgroup_support = 'Interval' THEN NULL 
               ELSE dbo.GetBillingGroupAncestor(cbg.id_billgroup)
               END id_arg_root_billgroup,
      cbg.id_interval id_arg_interval,
      NULL dt_arg_start,
      NULL dt_arg_end,
      'N' b_ignore_deps,
      NULL dt_effective,
      -- the start root event is created as Succeeded
      -- the end root event is created as ReadyToRun (for auto hard close)
      -- all others are created as  NotYetRun
      CASE WHEN evt.tx_name = '_StartRoot' AND evt.tx_type = 'Root' THEN 'Succeeded' 
           WHEN evt.tx_name = '_EndRoot'   AND evt.tx_type = 'Root' THEN 'ReadyToRun' ELSE
           'NotYetRun' 
      END tx_status
    FROM @closing_billgroup cbg
    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = cbg.id_usage_cycle
    INNER JOIN t_recevent_eop sch ON 
               -- the schedule is not constrained in any way
               ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
               -- the schedule's cycle type is constrained
               (sch.id_cycle_type = uc.id_cycle_type) OR
               -- the schedule's cycle is constrained
               (sch.id_cycle = uc.id_usage_cycle))
    INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
    INNER JOIN t_billgroup bg ON bg.id_billgroup = cbg.id_billgroup 
    WHERE 
      -- event must be active
      evt.dt_activated <= @dt_now and
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      -- event must be of type: root, end-of-period or checkpoint
      (evt.tx_type in ('Root', 'EndOfPeriod', 'Checkpoint')) AND
     -- do not insert BillingGroup adapters for pull lists
     NOT EXISTS (SELECT 1 
                         FROM t_billgroup bg1
                         WHERE bg1.tx_type = 'PullList' AND
                                     bg1.id_billgroup = bg.id_billgroup
                         AND EXISTS
                         (SELECT 1
 	             FROM t_recevent re1
                         WHERE re1.tx_billgroup_support = 'BillingGroup' AND
                                     re1.id_event = evt.id_event)) AND      

      evt.id_event NOT IN 
      (
        -- only adds instances if they are missing
        -- this guards against extra instances after closing -> reopening -> closing
        SELECT evt.id_event
        FROM @closing_billgroup cbg 
        INNER JOIN t_billgroup bg ON bg.id_billgroup = cbg.id_billgroup
        -- check that interval-only instances are not regenerated
        -- check that billing-group instances are not regenerated
        -- check that account-only instances are not regenerated
        INNER JOIN t_recevent_inst inst ON inst.id_arg_interval = cbg.id_interval AND
                                                                (inst.id_arg_billgroup = cbg.id_billgroup OR
                                                                 -- inst.id_arg_root_billgroup = bg.id_parent_billgroup OR
                                                                 inst.id_arg_billgroup IS NULL)
        INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
        WHERE  
          -- event must be active
          evt.dt_activated <= @dt_now and
          (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) 
       
      )
      GROUP BY evt.id_event, 
                       CASE WHEN evt.tx_billgroup_support = 'Interval' THEN NULL 
                               ELSE cbg.id_billgroup 
                               END,
                        CASE WHEN evt.tx_billgroup_support = 'Interval' THEN NULL 
                                 ELSE dbo.GetBillingGroupAncestor(cbg.id_billgroup)
                                 END,
                       cbg.id_interval,
                       CASE WHEN evt.tx_name = '_StartRoot' AND evt.tx_type = 'Root' THEN 'Succeeded' 
                                WHEN evt.tx_name = '_EndRoot'   AND evt.tx_type = 'Root' THEN 'ReadyToRun' 
                                ELSE 'NotYetRun' 
                       END

  END
  SET @status = 0
  SELECT * FROM @closing_billgroup
  COMMIT
  