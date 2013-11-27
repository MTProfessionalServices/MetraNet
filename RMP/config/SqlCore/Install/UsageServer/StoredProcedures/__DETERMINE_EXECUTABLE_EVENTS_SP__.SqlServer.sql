
CREATE PROCEDURE DetermineExecutableEvents (@dt_now DATETIME, @id_instances VARCHAR(4000))
AS

BEGIN
  BEGIN TRAN

  if object_id('tempdb..#tmp_deps') is not null drop table #tmp_deps
  CREATE TABLE #tmp_deps
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

  -- GetEventExecutionDeps populates #tmp_deps table
  -- Parameter table have bad performance when >100 records returned, so using temp table for that.
  EXEC GetEventExecutionDeps @dt_now, @id_instances

  DECLARE @compatibleEvents TABLE
  (
    tx_compatible_eventname nvarchar(255) NOT NULL 
  )
  INSERT INTO @compatibleEvents  
  SELECT * from GetCompatibleConcurrentEvents()

  --
  -- returns the final rowset of all events that are 'ReadyToRun' and
  -- have satisfied dependencies. the rows are sorted in the order
  -- that they should be executed. 
  --
  SELECT 
    evt.tx_name EventName,
    evt.tx_class_name ClassName,
    evt.tx_config_file ConfigFile,
    evt.tx_extension_name Extension,
    evt.tx_type EventType,
    evt_mach.tx_canrunonmachine EventMachineTag,
    inst.id_instance InstanceID,
    inst.id_arg_interval ArgInterval,
    inst.id_arg_billgroup ArgBillingGroup,
    inst.dt_arg_start ArgStartDate,
    inst.dt_arg_end ArgEndDate,
    dependedon.total DependentScore
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT JOIN t_recevent_machine evt_mach ON evt.id_event = evt_mach.id_event /* Multiple machine rules results in multiple events; not great but not an issue */
  INNER JOIN 
  (
    -- counts the total amount of dependencies per runnable instance
    SELECT 
      deps.id_orig_instance,
      COUNT(*) total
    FROM #tmp_deps deps
    GROUP BY
      deps.id_orig_instance 
  ) total_deps ON total_deps.id_orig_instance = inst.id_instance
  INNER JOIN 
  (
    -- counts the amount of satisfied dependencies per runnable instance
    SELECT 
      deps.id_orig_instance,
      COUNT(*) total
    FROM #tmp_deps deps
    WHERE deps.tx_status = 'Succeeded'
    GROUP BY
      deps.id_orig_instance 
  ) sat_deps ON sat_deps.id_orig_instance = inst.id_instance
  INNER JOIN 
  (
    -- determines how 'depended on' each runnable instance is
    -- the most 'depended on' instance should be run first in order
    -- to unblock the largest amount of other adapters in the shortest amount of time
    SELECT 
      inst.id_orig_instance,
      COUNT(*) total
    FROM #tmp_deps inst
    INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_orig_event
    GROUP BY
      inst.id_orig_instance
  ) dependedon ON dependedon.id_orig_instance = inst.id_instance
  INNER JOIN
  (
    /* Determines if any instances are running and which are compatible to also run at the same time */
	  /* Events that do not conflict at the moment (compatible with running events or nothing is running) */
	  SELECT ce.tx_compatible_eventname FROM @compatibleEvents ce
  ) compatible ON evt.tx_name = compatible.tx_compatible_eventname   
  -- LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  LEFT OUTER JOIN vw_all_billing_groups_status bgs 
      ON bgs.id_billgroup = inst.id_arg_billgroup
   WHERE
   (total_deps.total = sat_deps.total OR inst.b_ignore_deps = 'Y') AND
   -- instance's effective date has passed or is NULL ('Execute Later')
  (inst.dt_effective IS NULL OR inst.dt_effective <= @dt_now)  AND
   -- billing group, if any, must be in the closed state
  (inst.id_arg_billgroup IS NULL OR bgs.status = 'C') 
  ORDER BY dependedon.total DESC, inst.id_instance ASC

  COMMIT
END
