
create PROCEDURE CanExecuteEventDeps (
	@dt_now DATETIME, 
	@id_instances VARCHAR(4000), 
    @lang_code INT = 840
	)
AS

BEGIN

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


  SELECT
    orig_evt.tx_name OriginalEventName,
    orig_evt.tx_display_name OriginalEventDisplayName,    
    COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,    
    evt.tx_type EventType,
    deps.OriginalInstanceID,
    deps.EventID,
    deps.EventName,
    deps.InstanceID,
    deps.ArgIntervalID,
    deps.ArgStartDate,
    deps.ArgEndDate,
    deps.Status,
    /*  the corrective action that must occur */
    CASE deps.Status WHEN 'NotYetRun' THEN 'Execute'
                    WHEN 'Failed' THEN 'Reverse'
                    WHEN 'ReadyToRun' THEN 'Cancel'
                    WHEN 'Reversing' THEN 'TryAgainLater'
                    ELSE 'Unknown' END AS Action,
    isnull(deps.BillGroupName, 'Not Available') BillGroupName
  FROM
  (
    SELECT 
      MIN(deps.id_orig_instance) OriginalInstanceID,
      deps.id_event EventID,
      deps.tx_name EventName,
      deps.id_instance InstanceID,
      deps.id_arg_interval ArgIntervalID,
      deps.dt_arg_start ArgStartDate,
      deps.dt_arg_end ArgEndDate,
      deps.tx_status Status,
      bg.tx_name BillGroupName
    FROM #tmp_deps deps
    LEFT OUTER JOIN t_billgroup bg ON bg.id_billgroup = deps.id_billgroup
    WHERE 
      /* excludes input instances */
      (deps.id_instance NOT IN (select * from dbo.csvtoint(@id_instances)) 
			  OR deps.id_instance IS NULL) AND
      /* only look at deps that need an action to be taken */
      deps.tx_status NOT IN ('Succeeded', 'ReadyToRun', 'Running')
    GROUP BY 
      deps.id_instance,
      deps.id_event,
      deps.tx_name,
      deps.id_arg_interval,
      deps.dt_arg_start,
      deps.dt_arg_end,
      deps.tx_status,
      bg.tx_name
  ) deps
  INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
  INNER JOIN t_recevent_inst orig_inst ON orig_inst.id_instance = deps.OriginalInstanceID
  INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = @lang_code AND evt.id_event=loc.id_item)

END
 