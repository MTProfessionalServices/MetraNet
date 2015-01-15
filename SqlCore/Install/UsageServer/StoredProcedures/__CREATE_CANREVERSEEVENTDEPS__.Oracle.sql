
CREATE OR REPLACE procedure CanReverseEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from tmp_deps;
   exec_deps := dbo.GetEventReversalDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for 
      SELECT
        orig_evt.tx_name OriginalEventName,
        orig_evt.tx_display_name OriginalEventDisplayName,        
        COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,    
        evt.tx_type EventType,
        evt.tx_reverse_mode ReverseMode,
        deps.OriginalInstanceID,
        deps.EventID,
        deps.EventName,
        deps.InstanceID,
        deps.ArgIntervalID,
        deps.ArgStartDate,
        deps.ArgEndDate,
        deps.Status,
        /* the corrective action that must occur */
        CASE deps.Status WHEN 'Succeeded' THEN 'Reverse'
                        WHEN 'Failed' THEN 'Reverse'
                        WHEN 'ReadyToRun' THEN 'Cancel'
                        WHEN 'Running' THEN 'TryAgainLater'
                        ELSE 'Unknown' END Action,
        nvl(deps.BillGroupName, 'Not Available') BillGroupName
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
        FROM tmp_deps deps
        LEFT OUTER JOIN t_billgroup bg ON bg.id_billgroup = deps.id_billgroup
        WHERE 
          /* excludes input instances */
          (deps.id_instance NOT IN (select column_value 
                      from table(dbo.csvtoint(p_id_instances))) 
               OR deps.id_instance IS NULL) AND
          /* only look at deps that need an action to be taken */
          deps.tx_status NOT IN ('NotYetRun', 'ReadyToReverse', 'Reversing')
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
      LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanReverseEventDeps;
  