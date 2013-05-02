
/* ===========================================================
Return the dependencies for the given @id_instances or all 'ReadyToRun' instances
if @id_instances is NULL
=========================================================== */
 CREATE FUNCTION GetEventReversalDeps(@dt_now DATETIME, @id_instances VARCHAR(4000))
RETURNS @deps TABLE
(
  id_orig_event INT NOT NULL,
  tx_orig_billgroup_support VARCHAR(15),         -- useful for debugging
  id_orig_instance INT NOT NULL,
  id_orig_billgroup INT,                               -- useful for debugging
  tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging
  tx_name nvarchar(255) NOT NULL,           -- useful for debugging
  id_event INT NOT NULL,
  tx_billgroup_support VARCHAR(15),         -- useful for debugging
  id_instance INT,
  id_billgroup INT,                                       -- useful for debugging
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
  
  -- builds up a table from the comma separated list of instance IDs
  -- if the list is null, then add all ReadyToReverse instances
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
    WHERE tx_status = 'ReadyToReverse'
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

  --
  -- inserts all active instances found in @args
  --
  INSERT INTO @instances
  SELECT
    evt.id_event,
    evt.tx_type,
    evt.tx_name,
    inst.id_instance,
    inst.id_arg_interval,
    inst.id_arg_billgroup,
    inst.id_arg_root_billgroup,
    -- in the case of EOP then, use the interval's start date
    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
    -- in the case of EOP then, use the interval's end date
    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
  FROM t_recevent_inst inst
  INNER JOIN @args args ON args.id_instance = inst.id_instance
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
  WHERE
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)

  --
  -- inserts EOP to EOP dependencies for interval-only adapters
  --
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
      -- treats the identity dependency as NotYetRun
      'NotYetRun'
    ELSE
      depinst.tx_status
    END,
     'Y'  -- b_critical_dependency
  FROM @instances inst
  INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                                        depinst.id_arg_interval = inst.id_arg_interval
  INNER JOIN t_recevent origevent
      ON origevent.id_event = inst.id_event
  WHERE
    -- dep event is active
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    -- the original instance's event is root, EOP or a checkpoint event
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
    -- the dependency instance's event is an EOP or Checkpoint event
    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
    -- the original instance's event is 'Interval'
    origevent.tx_billgroup_support = 'Interval'

--SELECT * FROM @deps ORDER BY tx_orig_name ASC
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
      -- treats the identity dependency as NotYetRun
      'NotYetRun'
    ELSE
      depinst.tx_status
    END,
     'Y'  -- b_critical_dependency
  FROM @instances inst
  INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
          (
               -- if the depends-on instance is an interval-only instance
               (depinst.id_arg_interval = inst.id_arg_interval AND depevt.tx_billgroup_support = 'Interval') 
               OR
               -- if the depends-on instance is an account-only instance
              (depinst.id_arg_billgroup = inst.id_arg_billgroup AND depevt.tx_billgroup_support = 'Account')
               OR
              -- if the depends-on instance is a billing-group-only instance
              (depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup AND depevt.tx_billgroup_support = 'BillingGroup')
           )

  INNER JOIN t_recevent origevent
      ON origevent.id_event = inst.id_event
  WHERE
    -- dep event is active
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    -- the original instance's event is root, EOP or a checkpoint event
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
    -- the dependency instance's event is an EOP or Checkpoint event
    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
    -- the original instance's event is 'BillingGroup'
    origevent.tx_billgroup_support IN ('BillingGroup', 'Account') 

  --
  -- inserts EOP cross-interval dependencies (every instance in future intervals)
  --
  INSERT INTO @deps
  SELECT 
    inst.id_event,
    NULL, -- original tx_billgroup_support
    inst.id_instance,
    inst.id_arg_billgroup,
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    NULL, -- tx_billgroup_support
    depinst.id_instance,
    depinst.id_arg_billgroup,
    ui.id_interval,
    NULL,
    NULL,
    depinst.tx_status,
    'N' -- b_critical_dependency
  FROM @instances inst
  INNER JOIN t_usage_interval ui ON ui.dt_end > inst.dt_arg_end
  CROSS JOIN 
  (
    -- returns the event dependencies of the end root event
    -- this event depends on all EOP events
    SELECT
      depevt.id_event,
      depevt.tx_name
    FROM t_recevent evt
    INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
    INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
    WHERE
      evt.tx_name = '_EndRoot' AND
      -- end root event is active
      evt.dt_activated <= @dt_now AND
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      -- dep event is active
      depevt.dt_activated <= @dt_now AND
      (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
      -- the dependency instance's event is an EOP or Checkpoint event
      depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 
  ) depevt
  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                                        depinst.id_arg_interval = ui.id_interval
  WHERE
    -- the original instance's event is root, EOP or a checkpoint event
    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint')


  --
  -- inserts scheduled dependencies
  --
  INSERT INTO @deps
  SELECT
    inst.id_event,
    NULL, -- original tx_billgroup_support
    inst.id_instance,
    NULL, -- id_arg_billgroup
    inst.tx_name,
    depevt.tx_name,
    depevt.id_event,
    depevt.tx_billgroup_support,
    depinst.id_instance,
    NULL, -- id_arg_billgroup
    NULL, -- id_arg_interval
    ISNULL(depinst.dt_arg_start, inst.dt_arg_start),
    ISNULL(depinst.dt_arg_end, inst.dt_arg_end),
    CASE WHEN inst.id_instance = depinst.id_instance THEN
      -- treats the identity dependency as NotYetRun
      'NotYetRun'
    ELSE
      depinst.tx_status
    END,
    'N'  -- b_critical_dependency
  FROM @instances inst
  INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
    -- enforce that the instance's dependency's start arg and end arg
    -- at least partially overlap with the original instance's start and end arguments
    depinst.dt_arg_start <= inst.dt_arg_end AND
    depinst.dt_arg_end >= inst.dt_arg_start
  WHERE
    -- dep event is active
    depevt.dt_activated <= @dt_now AND
    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND
    depevt.tx_type = 'Scheduled'

--SELECT * FROM @deps ORDER BY tx_orig_name ASC
  RETURN
END
