
/* ===========================================================
Determines reversible instances.
=========================================================== */
CREATE PROCEDURE DetermineReversibleEvents (@dt_now DATETIME, @id_instances VARCHAR(4000))
AS

BEGIN
  BEGIN TRAN

  DECLARE @deps TABLE
  (
   id_orig_event INT NOT NULL,
  tx_orig_billgroup_support VARCHAR(15),-- useful for debugging
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
  INSERT INTO @deps  
  SELECT * from GetEventReversalDeps(@dt_now, @id_instances)

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
    evt.tx_reverse_mode ReverseMode,
    evt.tx_type EventType,
    evt_mach.tx_canrunonmachine EventMachineTag,
    run.id_run RunIDToReverse,
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
    -- finds the the run to reverse (the last execution's run ID)
    SELECT 
      id_instance,
      MAX(dt_start) dt_start
    FROM t_recevent_run run
    WHERE tx_type = 'Execute'
    GROUP BY
      id_instance
  ) maxrun ON maxrun.id_instance = inst.id_instance
  INNER JOIN t_recevent_run run ON run.dt_start = maxrun.dt_start AND
                                   run.id_instance = maxrun.id_instance
  INNER JOIN 
  (
    -- counts the total amount of dependencies per reversible instance
    SELECT 
      deps.id_orig_instance,
      COUNT(*) total
    FROM @deps deps
    GROUP BY
      deps.id_orig_instance 
  ) total_deps ON total_deps.id_orig_instance = inst.id_instance
  INNER JOIN 
  (
    -- counts the amount of satisfied dependencies per reversible instance
    SELECT 
      deps.id_orig_instance,
      COUNT(*) total
    FROM @deps deps
    WHERE deps.tx_status = 'NotYetRun'
    GROUP BY
      deps.id_orig_instance 
  ) sat_deps ON sat_deps.id_orig_instance = inst.id_instance
  INNER JOIN 
  (
    -- determines how 'depended on' (from an forward perspective) each instance is
    -- the least 'depended on' instance should be run first in order
    -- to unblock the largest amount of other adapters in the shortest amount of time
    SELECT 
      inst.id_orig_instance,
      COUNT(*) total
    FROM @deps inst
    INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_orig_event
    GROUP BY
      inst.id_orig_instance
  ) dependedon ON dependedon.id_orig_instance = inst.id_instance
  INNER JOIN
  (
    /* Determines if any instances are running and which are compatible to also run at the same time */
	/* Events that do not conflict at the moment (compatible with running events or nothing is running) */
	SELECT tx_compatible_eventname FROM GetCompatibleConcurrentEvents()
  ) compatible ON evt.tx_name = compatible.tx_compatible_eventname     
  LEFT OUTER JOIN vw_all_billing_groups_status bgs 
      ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE
    (total_deps.total = sat_deps.total OR inst.b_ignore_deps = 'Y') AND
    -- instance's effective date has passed or is NULL ('Execute Later')
    (inst.dt_effective IS NULL OR inst.dt_effective <= @dt_now) AND
    -- billing group, if any, must be in the closed state
    (inst.id_arg_billgroup IS NULL OR bgs.status = 'C') 
  ORDER BY dependedon.total ASC, inst.id_instance ASC

  COMMIT
END
