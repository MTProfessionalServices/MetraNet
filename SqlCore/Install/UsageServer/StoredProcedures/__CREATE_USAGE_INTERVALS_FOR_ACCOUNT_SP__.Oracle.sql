
create or replace
PROCEDURE createusageintervalsforaccount(
   dt_now             date,                  /* the MetraTech system's date */
   p_id_acc           int,  /* account ID to create intervals/mappings for  */
   p_dt_start         date,                           /* account start date */
   dt_end             date,
   /* account end date */

   /* if true doesn't create new intervals but returns what would have been created */
   pretend            int,
   /* the count of intervals created (or that would have been created) */
   n_count      out   int,
   /* the intervals created or might have been created */
   res          out   sys_refcursor
)
as
   result       int;
   dt_probe     date;
   dt_adj_end   date;
   m_count      int;
   xacc         int;
   xinterval    int;
   xchar        char;
begin
/* NOTE: this procedure is closely realted to CreateUsageIntervals     except that it only does work for one account (id_acc). This sproc     is used to decrease total duration of an account creation. Other     accounts affected by new intervals being created are addressed later     in the day when a required usm -create triggers a full CreateUsageIntervals     execution. */
/* PRECONDITIONS:     Intervals and mappings will be created and backfilled as long as there     is an entry for the account in t_acc_usage_cycle. Missing mappings will     be detected and added. */
/* ensures that there is only one instance of this sproc or the     CreateUsageIntervals sproc being executing right now     EXEC result = sp_getapplock Resource = 'CreateUsageIntervals',                                 @LockMode = 'Exclusive'     IF result < 0 then        ROLLBACK         RETURN    END IF;     */
            /* clear out the temporary tables from any data in this session */
   execute immediate 'delete from CreateUsageIntervalsForAcc_rs';

   execute immediate 'delete from tmp_new_acc_interval_map';

/* represents the end date that an interval must     fall into to be considered  */
   for i in (select (dt_now + n_adv_interval_creation) dt_probe
               from t_usage_server)
   loop
      dt_probe := i.dt_probe;
   end loop;

       /* if the account hasn't started nor is about to start or
   the account has already ended (is this possible)
   then don't do anything */
   if (p_dt_start >= dt_probe and dt_end < dt_now)
   then
      n_count := sql%rowcount;           /* COMMIT; /* release the applock */
      return;
   end if;

/* adjusts the account end date to be no later than the probe date
no intervals are created in the future after the probe date */
   select (case
              when dt_end > dt_probe
                 then dt_probe
              else dt_end
           end)
     into dt_adj_end
     from dual;

/* associate the account with intervals based on its cycle mapping     this will detect missing mappings and add them */
   insert into tmp_new_acc_interval_map
      select auc.id_acc, ref.id_interval, nvl(ui.tx_interval_status, 'O')
        /* TODO: tx_status column no longer used and should be removed */
      from   t_acc_usage_cycle auc inner join t_pc_interval ref on ref.id_cycle =
                                                                     auc.id_usage_cycle
                                                              /* reference interval must at least partially overlap the [minstart, maxend] period */
                                                              and (    ref.dt_end >=
                                                                          p_dt_start
                                                                   and ref.dt_start <=
                                                                          dt_adj_end
                                                                  )
             left outer join t_acc_usage_interval aui on aui.id_usage_interval =
                                                               ref.id_interval
                                                    and aui.id_acc =
                                                                    auc.id_acc
  LEFT OUTER JOIN t_usage_interval ui
    ON ui.id_interval = ref.id_interval 		
       where auc.id_acc = p_id_acc and
   /* Only add mappings for non-blocked intervals */
    (ui.tx_interval_status IS NULL OR ui.tx_interval_status != 'B') 
                                  /* only add mappings that dont exist already */
             and aui.id_usage_interval is null;

   /* number of mapped intervals possibly added */
   m_count := sql%rowcount;

/* determines what usage intervals need to be added     based on the new account-to-interval mappings   */
   insert into createusageintervalsforacc_rs
      select ref.id_interval, ref.id_cycle, ref.dt_start, ref.dt_end, 'O',

             /* Open */
             uct.id_cycle_type
        from t_pc_interval ref inner join tmp_new_acc_interval_map mappings on mappings.id_usage_interval =
                                                                     ref.id_interval
             inner join t_usage_cycle uc on uc.id_usage_cycle = ref.id_cycle
             inner join t_usage_cycle_type uct on uct.id_cycle_type =
                                                              uc.id_cycle_type
       where ref.id_interval not in(select id_interval
                                      from t_usage_interval);

   /* don't add any intervals already in t_usage_interval */

   /* records how many intervals would be added */
   n_count := sql%rowcount;

   /* only adds the new intervals and mappings if we aren't pretending */
   if nvl(pretend, 0) = 0
   then                                           /* adds the new intervals */
      insert into t_usage_interval
                  (id_interval, id_usage_cycle, dt_start, dt_end,
                   tx_interval_status)
         select id_interval, id_usage_cycle, dt_start, dt_end,
                tx_interval_status
           from createusageintervalsforacc_rs;    /* adds the new mappings */

      insert into t_acc_usage_interval
                  (id_acc, id_usage_interval, tx_status, dt_effective)
         select id_acc, id_usage_interval, tx_status, null
           from tmp_new_acc_interval_map;

      open res for
         select *
           from createusageintervalsforacc_rs;
   end if;
end;
  