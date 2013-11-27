
CREATE OR REPLACE
PROCEDURE SoftCloseBillingGroups
(
  p_dt_now date,       /* MetraTech system date */
  p_id_billgroup INT,   /* specific billing group to close or null  */
  p_id_interval INT,    /* specific usage interval to close or null for automatic detection based on grace periods */
  p_pretend INT,        /* if pretend is true no billing groups are closed but instead are just returned */
  p_n_count out INT,   /* the number of billing groups closed (or that would have been closed) */
  p_status out INT,    /*  error status */
  p_cur out sys_refcursor
)
AS

begin
  
  /* Initialize p_status */
  p_status := -1;
  /* Initialize p_n_count */
  p_n_count := 0;

  /* ERROR if both p_id_billgroup and p_id_interval are non null 
    */
  IF (p_id_billgroup IS NOT NULL AND p_id_interval IS NOT NULL) then
     p_status := -2;
     ROLLBACK;
     RETURN;
  END if;

  /* Get rid of any detritus from previous invocations not removed by connection pool */
  DELETE FROM tmp_closing_billgroup;

  /* If both p_id_billgroup and p_id_interval are NULL, then select all 'Open' billing groups
    for all valid intervals (based on grace periods)
    */
  IF (p_id_billgroup IS NULL AND p_id_interval IS NULL) then
       /* looks at all the billing groups in the system */
       INSERT INTO tmp_closing_billgroup
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
                    THEN ui.dt_end + uct.n_grace_period /* take into account the cycle type's grace period */
                    ELSE p_dt_now /* the grace period has been disabled, so don't close this interval */
          END < p_dt_now AND bgs.Status = 'O'; /* ui.tx_interval_status = 'O' */

          /* Set the row count */
          p_n_count := sql%rowcount;
  ELSE
       /* If only id_interval is non-null then soft close all 'Open' billing groups for this interval
        * (regardless of grace period/end date)
        */
       IF (p_id_interval IS NOT NULL) then
             INSERT INTO tmp_closing_billgroup
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
                  bgs.id_usage_interval = p_id_interval;

             p_n_count := sql%rowcount; 

       ELSE
             /* If we are here then we have a non null p_id_billgroup. Soft close it.
              */
             INSERT INTO tmp_closing_billgroup
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
                   bgs.id_billgroup = p_id_billgroup;

             p_n_count := sql%rowcount;
       END if;

    end if;   

   /* only closes the billing groups if pretend is false */
  IF p_pretend = 0 then
   
    /* Update the status of the accounts for the billing group in t_acc_usage_interval */
    UPDATE t_acc_usage_interval aui 
    SET aui.tx_status = 'C'
    where exists (
      select 1      
      from tmp_closing_billgroup cbg 
      INNER JOIN t_billgroup_member bgm 
         on bgm.id_billgroup = cbg.id_billgroup
      where bgm.id_acc = aui.id_acc 
         and cbg.id_interval = aui.id_usage_interval);
         

    /* adds instance entries for each billing group that is closed
    */
    INSERT INTO t_recevent_inst(
        id_instance,
        id_event,
        id_arg_billgroup,
        id_arg_root_billgroup,
        id_arg_interval,
        dt_arg_start,
        dt_arg_end,
        b_ignore_deps,
        dt_effective,
        tx_status)
    select 
        seq_t_recevent_inst.nextval, 
        subqry.*
    from (
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
           /* the start root event is created as Succeeded
            * the end root event is created as ReadyToRun (for auto hard close)
            * all others are created as  NotYetRun
            */
          CASE WHEN evt.tx_name = '_StartRoot' AND evt.tx_type = 'Root' THEN 'Succeeded' 
               WHEN evt.tx_name = '_EndRoot'   AND evt.tx_type = 'Root' THEN 'ReadyToRun' ELSE
               'NotYetRun' 
          END tx_status
        FROM tmp_closing_billgroup cbg
        INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = cbg.id_usage_cycle
        INNER JOIN t_recevent_eop sch ON 
                   /* the schedule is not constrained in any way */
                   ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
                   /* the schedule's cycle type is constrained  */
                   (sch.id_cycle_type = uc.id_cycle_type) OR
                   /* the schedule's cycle is constrained  */
                   (sch.id_cycle = uc.id_usage_cycle))
        INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
        INNER JOIN t_billgroup bg ON bg.id_billgroup = cbg.id_billgroup 
        WHERE 
          /* event must be active */
          evt.dt_activated <= p_dt_now and
          (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
          /* event must be of type: root, end-of-period or checkpoint */
          (evt.tx_type in ('Root', 'EndOfPeriod', 'Checkpoint')) AND
         /* do not insert BillingGroup adapters for pull lists */
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
            /* only adds instances if they are missing
              * this guards against extra instances after closing -> reopening -> closing
              */
            SELECT evt.id_event
            FROM tmp_closing_billgroup cbg 
            INNER JOIN t_billgroup bg ON bg.id_billgroup = cbg.id_billgroup
            /* check that interval-only instances are not regenerated
              * check that billing-group instances are not regenerated
              * check that account-only instances are not regenerated
              */
            INNER JOIN t_recevent_inst inst 
                ON inst.id_arg_interval = cbg.id_interval 
                  AND (inst.id_arg_billgroup = cbg.id_billgroup 
                            /*  inst.id_arg_root_billgroup = bg.id_parent_billgroup OR */
                        or inst.id_arg_billgroup IS NULL)
            INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
            WHERE  
              /* event must be active */
              evt.dt_activated <= p_dt_now and
              (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) 
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
        ) subqry;
    END if;
  
  p_status := 0;

  open p_cur for 'SELECT * FROM tmp_closing_billgroup';
 
  COMMIT;
  
 end;
      