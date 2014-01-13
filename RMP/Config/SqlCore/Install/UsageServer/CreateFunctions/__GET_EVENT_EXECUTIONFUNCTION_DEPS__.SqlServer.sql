
/* ===========================================================
Return the dependencies for the given @id_instances or all 'ReadyToRun' instances
if @id_instances is NULL
=========================================================== */
CREATE FUNCTION GetEventExecutionFunctionDeps(@dt_now DATETIME, @id_instances VARCHAR(4000))
RETURNS @deps TABLE
(
  id_orig_event INT NOT NULL,
  tx_orig_billgroup_support VARCHAR(15),         /* useful for debugging */
  id_orig_instance INT NOT NULL,
  id_orig_billgroup INT,                               /* useful for debugging */
  tx_orig_name VARCHAR(255) NOT NULL, /* useful for debugging */
  tx_name nvarchar(255) NOT NULL,           /* useful for debugging */
  id_event INT NOT NULL,
  tx_billgroup_support VARCHAR(15),         /* useful for debugging */
  id_instance INT,
  id_billgroup INT,                                       /* useful for debugging */
  id_arg_interval INT,
  dt_arg_start DATETIME,
  dt_arg_end DATETIME,
  tx_status VARCHAR(14),
  b_critical_dependency VARCHAR(1)
)
AS
BEGIN

  DECLARE @args TABLE
  ( 
    id_instance INT NOT NULL
  )
  
  /* builds up a table from the comma separated list of instance IDs
   if the list is null, then add all ReadyToRun instances */
  
  IF (@id_instances IS NOT NULL)
  BEGIN
    INSERT INTO @args
    SELECT value FROM CSVToInt(@id_instances)
  END
  ELSE
  BEGIN
    INSERT INTO @args
    SELECT id_instance 
    FROM t_recevent_inst
    WHERE tx_status = 'ReadyToRun'
  END


  DECLARE @instances TABLE
  (
    id_event INT NOT NULL,
    tx_type VARCHAR(11) NOT NULL,
    tx_name nvarchar(255) NOT NULL,
    id_instance INT NOT NULL,
    id_arg_interval INT,
    id_arg_billgroup INT,
    id_arg_root_billgroup INT,
    dt_arg_start DATETIME,
    dt_arg_end DATETIME
  )

  /*  inserts all active 'ReadyToRun' instances or the instance ID's passed in  */
  
  INSERT INTO @instances
  SELECT
    evt.id_event,
    evt.tx_type,
    evt.tx_name,
    inst.id_instance,
    inst.id_arg_interval,
    inst.id_arg_billgroup,
    inst.id_arg_root_billgroup,
    /* in the case of EOP then, use the interval's start date */
    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
    /* in the case of EOP then, use the interval's end date */
    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
  FROM t_recevent_inst inst
  INNER JOIN @args args ON args.id_instance = inst.id_instance
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
  WHERE
    /* event is active */
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)

  /* inserts EOP to EOP dependencies for interval-only adapters */
  INSERT INTO @deps
  SELECT
    inst.id_event,
    origevent.tx_billgroup_support,
    inst.id_instance,
    inst.id_arg_billgroup,
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    depevt.tx_billgroup_support,
    depinst.id_instance,
    depinst.id_arg_billgroup,
    depinst.id_arg_interval,
    NULL,
    NULL,
    CASE WHEN inst.id_instance = depinst.id_instance THEN
      /*  treats the identity dependency as successful */
      'Succeeded'
    ELSE
      depinst.tx_status
    END,
    'Y'  /* b_critical_dependency */
  FROM @instances inst
  INNER JOIN t_recevent_dep dep 
      ON dep.id_event = inst.id_event
  INNER JOIN t_recevent depevt 
      ON depevt.id_event = dep.id_dependent_on_event
  INNER JOIN t_recevent_inst depinst 
      ON depinst.id_event = depevt.id_event AND
            depinst.id_arg_interval = inst.id_arg_interval
  INNER JOIN t_recevent origevent
      ON origevent.id_event = inst.id_event
  WHERE
    /* dep event is active */
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    /* the original instance's event is root, EOP or a checkpoint event */
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
    /* the dependency instance's event is an EOP or Checkpoint event */
    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')  AND
    /* the original instance's event is 'Interval' */
    origevent.tx_billgroup_support = 'Interval'

   /* 
      Inserts EOP to EOP dependencies for billing group-only and account-only adapters. 
      For a given adapter instance, the depends-on instance could
      be and interval-only instance, a billing-group-only instance or an account-only instance.
    */
  
  INSERT INTO @deps
  SELECT
    inst.id_event,
    origevent.tx_billgroup_support,
    inst.id_instance,
    inst.id_arg_billgroup,
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    depevt.tx_billgroup_support,
    depinst.id_instance,
    depinst.id_arg_billgroup,
    depinst.id_arg_interval,
    NULL,
    NULL,
    CASE WHEN inst.id_instance = depinst.id_instance THEN
      /* treats the identity dependency as successful */
      'Succeeded'
    ELSE
      depinst.tx_status
    END,
    'Y'  /* b_critical_dependency */
  FROM @instances inst
   INNER JOIN t_recevent origEvt
      ON origEvt.id_event = inst.id_event
  INNER JOIN t_recevent_dep dep 
      ON dep.id_event = inst.id_event
  INNER JOIN t_recevent depevt 
      ON depevt.id_event = dep.id_dependent_on_event
  INNER JOIN t_recevent_inst depinst 
      ON depinst.id_event = depevt.id_event AND
          (
                 /* when the original event or dependent event is Interval then make sure
                  that the original instance and the dependent instance have the same interval */
               (
                   (
                       origEvt.tx_billgroup_support = 'Interval' OR 
                       depEvt.tx_billgroup_support = 'Interval'
                   )
                   AND 
                   (
                       depinst.id_arg_interval = inst.id_arg_interval
                   )
               )
              
               OR
               /* when the original event is BillingGroup */
               (
                   (
                      origEvt.tx_billgroup_support = 'BillingGroup' 
                   )
                   AND 
                   (
                       /* and dependent event is either BillingGroup or Account then make sure
                       that the original instance and the dependent instance have the same root billgroup
                        (depevt.tx_billgroup_support IN ('BillingGroup', 'Account') AND */
                       depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                   )
               )
    
                /* when the original event is Account */
               OR     
               (
                   (
                       origEvt.tx_billgroup_support = 'Account' 
                   )
                   AND 
                   (
                      (
                            /* and dependent event is Account then make sure
                            that the original instance and the dependent instance have the same billgroup  */
                            depevt.tx_billgroup_support = 'Account' AND
                            depinst.id_arg_billgroup = inst.id_arg_billgroup
                      )
                   
                      OR
                           /* and dependent event is BillingGroup then make sure
                           that the original instance and the dependent instance have the same root billgroup  */
                      (
                          depevt.tx_billgroup_support = 'BillingGroup' AND
                          depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                      )
                   )  /*  closes that AND dangling up there */
               ) /* closes that OR dangling up there - no not that OR, the other OR */
          )       
         
  INNER JOIN t_recevent origevent
      ON origevent.id_event = inst.id_event
  WHERE
    /*  dep event is active */
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    /*  the original instance's event is root, EOP or a checkpoint event */
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
    /* the dependency instance's event is an EOP or Checkpoint event */
    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')  AND
    /* the original instance's event is 'BillingGroup' */
    origevent.tx_billgroup_support IN ('BillingGroup', 'Account') 
     
 /* 

It is possible for adapters instances which belong to pull lists to have dependencies 
on 'BillingGroup' type adapters which exist at the parent billing group level and not at the pull list level.
If the parent billing group is 'Open' then these BillingGroup adapter instances don't even exist in t_recvent_inst.

Hence, create dummy BillingGroup type adapter instances (in a tmp table) for the parent billing groups (if necessary)
Use the tmp table to generate dependencies specifically for BillingGroup type adapters.

*/

 DECLARE @tmp_recevent_inst TABLE
  (
    id_event INT NOT NULL,
    id_arg_interval INT,
    id_arg_billgroup INT,
    id_arg_root_billgroup INT
  )

  DECLARE @tmp_billgroup TABLE
  (
     id_billgroup INT NOT NULL
  )


/*  select those parent billing groups which don't have any entries in t_recevent_inst */
INSERT INTO @tmp_billgroup(id_billgroup)
SELECT id_arg_root_billgroup 
FROM t_recevent_inst ri1
WHERE NOT EXISTS (SELECT 1 
                  FROM t_recevent_inst ri2 
                  WHERE ri1.id_arg_root_billgroup = ri2.id_arg_billgroup) 
      AND id_arg_root_billgroup IS NOT NULL                                
GROUP BY id_arg_root_billgroup

/*  create fake instance rows only for 'BillingGroup' type adapters */
INSERT INTO  @tmp_recevent_inst (id_event,
                                                        id_arg_interval,
                                                        id_arg_billgroup,
                                                        id_arg_root_billgroup)
SELECT evt.id_event id_event,
             bg.id_usage_interval id_arg_interval,
             tbg.id_billgroup,
             tbg.id_billgroup
FROM @tmp_billgroup tbg
  INNER JOIN t_billgroup bg ON bg.id_billgroup = tbg.id_billgroup 
  INNER JOIN t_usage_interval ui ON ui.id_interval = bg.id_usage_interval
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
  INNER JOIN t_recevent_eop sch ON 
               /*  the schedule is not constrained in any way */
               ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
               /*  the schedule's cycle type is constrained */
               (sch.id_cycle_type = uc.id_cycle_type) OR
               /* the schedule's cycle is constrained */
               (sch.id_cycle = uc.id_usage_cycle))
    INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
    
    WHERE 
      /*  event must be active */
      evt.dt_activated <= @dt_now AND
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      /*  event must be of type: end-of-period */
      (evt.tx_type in ('EndOfPeriod')) AND
      evt.tx_billgroup_support = 'BillingGroup'

 INSERT INTO @deps
  SELECT
    inst.id_event,
    origevent.tx_billgroup_support,
    inst.id_instance,
    inst.id_arg_billgroup,
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    depevt.tx_billgroup_support,
    -1,
    depinst.id_arg_billgroup,
    depinst.id_arg_interval,
    NULL,
    NULL,
    'NotCreated',
    'Y'  /*  b_critical_dependency */
  FROM @instances inst
   INNER JOIN t_recevent origEvt
      ON origEvt.id_event = inst.id_event
  INNER JOIN t_recevent_dep dep 
      ON dep.id_event = inst.id_event
  INNER JOIN t_recevent depevt 
      ON depevt.id_event = dep.id_dependent_on_event
  INNER JOIN @tmp_recevent_inst depinst 
      ON depinst.id_event = depevt.id_event AND
             /*  when the original event is Account */
             origEvt.tx_billgroup_support = 'Account' AND 
             /* and dependent event is BillingGroup then make sure */
             /*  that the original instance and the dependent instance have the same root billgroup */ 
             depevt.tx_billgroup_support = 'BillingGroup' AND
             depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                       
  INNER JOIN t_recevent origevent
      ON origevent.id_event = inst.id_event
  WHERE
    /* dep event is active */
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    /* the original instance's event is EOP event */
    inst.tx_type IN ('EndOfPeriod') AND
    /* the dependency instance's event is an EOP event */
    depevt.tx_type IN ('EndOfPeriod')  AND
    /*  the original instance's event is 'Account' */
    origevent.tx_billgroup_support IN ('Account') 

/* SELECT * FROM @deps */  

  /*
   inserts EOP cross-interval dependencies
  */
  INSERT INTO @deps
  SELECT 
    inst.id_event,
    NULL, /*  original tx_billgroup_support */
    inst.id_instance,
    inst.id_arg_billgroup,
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    NULL, /*  tx_billgroup_support */
    depinst.id_instance,
    depinst.id_arg_billgroup,
    ui.id_interval,
    NULL,
    NULL,
    ISNULL(depinst.tx_status, 'Missing'),
    'N'  /*  b_critical_dependency */
  FROM @instances inst
  INNER JOIN t_usage_interval ui ON ui.dt_end < inst.dt_arg_end 
  CROSS JOIN 
  (
    /*  returns the event dependencies of the end root event
    this event depends on all EOP events */
    SELECT
      depevt.id_event,
      depevt.tx_name
    FROM t_recevent evt
    INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
    INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
    WHERE
      evt.tx_name = '_EndRoot' AND
      /*  end root event is active */
      evt.dt_activated <= @dt_now AND
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      /*  dep event is active */
      depevt.dt_activated <= @dt_now AND
      (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
      /*  the dependency instance's event is an EOP or Checkpoint event */
      depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 
  ) depevt
  LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                                                                          depinst.id_arg_interval = ui.id_interval
  WHERE
    /*  the original instance's event is root, EOP or a checkpoint event */
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
    /*  don't consider hard closed intervals */
    ui.tx_interval_status <> 'H'

  /*
   inserts scheduled dependencies (including complete missing instances)
  */
  INSERT INTO @deps
  SELECT
    inst.id_event,
    NULL, /*  original tx_billgroup_support */
    inst.id_instance,
    NULL, /*  id_arg_billgroup */
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    depevt.tx_billgroup_support,
    depinst.id_instance,
    NULL, /*  id_arg_billgroup */
    NULL, /*  id_arg_interval */
    ISNULL(depinst.dt_arg_start, inst.dt_arg_start),
    ISNULL(depinst.dt_arg_end, inst.dt_arg_end),
    CASE WHEN inst.id_instance = depinst.id_instance THEN
      /*  treats the identity dependency as successful */
      'Succeeded'
    ELSE
      ISNULL(depinst.tx_status, 'Missing')
    END,
     'N'  /* b_critical_dependency */
  FROM @instances inst
  INNER JOIN t_recevent_dep dep ON dep.id_event = inst.id_event
  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
  LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
    /*  enforce that the instance's dependency's start arg and end arg */
    /*  at least partially overlap with the original instance's start and end arguments */
    depinst.dt_arg_start <= inst.dt_arg_end AND
    depinst.dt_arg_end >= inst.dt_arg_start
  WHERE
    /*  dep event is active */
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    depevt.tx_type = 'Scheduled'

/* SELECT * FROM @deps ORDER BY tx_orig_name ASC */

  /* inserts partially missing scheduled dependency instances (start to min)
   covers the original instance's start date to the minimum start date
  of all scheduled instances of an event */
  
  INSERT INTO @deps
  SELECT
    inst.id_event,
    NULL, /* original tx_billgroup_support */
    inst.id_instance,
    NULL, /*  id_arg_billgroup */
    inst.tx_name,
    missingdeps.tx_name,
    missingdeps.id_event,
    NULL, /*-- tx_billgroup_support */
    NULL, /*-- id_instance,*/
    NULL, /*-- id_arg_billgroup */
    NULL, /*-- id_arg_interval */
    inst.dt_arg_start,
    dbo.SubtractSecond(missingdeps.dt_min_arg_start),
    'Missing', /* -- tx_status, */
     'N'  /* -- b_critical_dependency */
  FROM @instances inst
  INNER JOIN
  (
    /* -- gets the minimum arg start date per scheduled event */
    SELECT
      deps.id_orig_instance,
      deps.id_event,
      deps.tx_name,
      MIN(deps.dt_arg_start) dt_min_arg_start
    FROM @deps deps
    INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
    WHERE
      evt.tx_type = 'Scheduled' AND
      deps.tx_status <> 'Missing'
    GROUP BY
      deps.id_orig_instance,
      deps.id_event,
      deps.tx_name
  ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
  WHERE
    /* -- only adds a missing instance if the minimum start date is too late */
    missingdeps.dt_min_arg_start > inst.dt_arg_start 


/* --SELECT * FROM @deps ORDER BY tx_orig_name ASC */

  /* -- inserts partially missing scheduled dependency instances (max to end)
  -- covers the maximum end date of all scheduled instances of an event to the
  -- original instance's end date */
  INSERT INTO @deps
  SELECT
    inst.id_event,
    NULL, /* -- original tx_billgroup_support */
    inst.id_instance,
    NULL, /* -- id_arg_billgroup */
    inst.tx_name,
    missingdeps.tx_name,
    missingdeps.id_event,
    NULL, /* -- tx_billgroup_support */
    NULL, /* -- id_instance, */
    NULL, /*-- id_arg_billgroup */
    NULL, /*-- id_arg_interval */
    dbo.AddSecond(missingdeps.dt_max_arg_end),
    inst.dt_arg_end,
    'Missing', /* -- tx_status, */
     'N'  /* -- b_critical_dependency */
  FROM @instances inst
  INNER JOIN
  (
    /* -- gets the maximum arg end date per scheduled event */
    SELECT
      deps.id_orig_instance,
      deps.id_event,
      deps.tx_name,
      MAX(deps.dt_arg_end) dt_max_arg_end
    FROM @deps deps
    INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
    WHERE
      evt.tx_type = 'Scheduled' AND
      deps.tx_status <> 'Missing'
    GROUP BY
      deps.id_orig_instance,
      deps.id_event,
      deps.tx_name
  ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
  WHERE
    /* -- only adds a missing instance if the maximum end date is too early */
    missingdeps.dt_max_arg_end < inst.dt_arg_end 

/* --SELECT * FROM @deps ORDER BY tx_orig_name ASC */
  RETURN
  END
