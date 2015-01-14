
CREATE OR REPLACE procedure CanExecuteEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from	tmp_deps;
   exec_deps := dbo.GetEventExecutionDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for 
    select
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
      nvl(deps.BillGroupName, N'Not Available') BillGroupName
    FROM
    (
      SELECT 
        MIN(deps_inner.id_orig_instance) OriginalInstanceID,
        deps_inner.id_event EventID,
        deps_inner.tx_name EventName,
        deps_inner.id_instance InstanceID,
        deps_inner.id_arg_interval ArgIntervalID,
        deps_inner.dt_arg_start ArgStartDate,
        deps_inner.dt_arg_end ArgEndDate,
        deps_inner.tx_status Status,
        bg.tx_name as BillGroupName
      FROM  tmp_deps deps_inner
          /* table(exec_deps) deps_inner */ 
      LEFT OUTER JOIN t_billgroup bg 
        ON bg.id_billgroup = deps_inner.id_billgroup
      WHERE 
        /* excludes input instances */
        (deps_inner.id_instance NOT IN ( select column_value 
                      from table(dbo.csvtoint(p_id_instances))) 
            OR deps_inner.id_instance IS NULL) AND
        /* only look at deps that need an action to be taken */
        deps_inner.tx_status NOT IN ('Succeeded', 'ReadyToRun', 'Running')
      GROUP BY 
        deps_inner.id_instance,
        deps_inner.id_event,
        deps_inner.tx_name,
        deps_inner.id_arg_interval,
        deps_inner.dt_arg_start,
        deps_inner.dt_arg_end,
        deps_inner.tx_status,
        bg.tx_name
    ) deps
    INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
    INNER JOIN t_recevent_inst orig_inst 
      ON orig_inst.id_instance = deps.OriginalInstanceID
    INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
    LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanExecuteEventDeps;
  