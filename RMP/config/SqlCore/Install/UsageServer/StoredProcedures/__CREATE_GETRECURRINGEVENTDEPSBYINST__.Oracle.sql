
CREATE OR REPLACE
procedure GetRecurringEventDepsByInst (
  p_dep_type varchar2,
  p_dt_now date,
  p_id_instances varchar2,
  p_status_filter varchar2,
  p_cur out sys_refcursor
  )
as
  deps int;
begin

  delete from tmp_deps;

  deps := case lower(p_dep_type)
    when 'execution' then dbo.GetEventExecutionDeps(p_dt_now, p_id_instances)
    when 'reversal' then dbo.GetEventReversalDeps(p_dt_now, p_id_instances)
    else null
    end;
    
  if (deps = 0 ) then 
    raise_application_error(-20000, 'Invalid dependency type: ' || p_dep_type);
  end if;
  
  /* after we've called GetEvent[dep_type]Deps the temp table 
    tmp_deps should be in scope and contain the records we need */

  open p_cur for '
    SELECT 
      deps.id_orig_instance OriginalInstanceID,
      deps.tx_orig_name OriginalEventName,
      deps.tx_orig_billgroup_support OriginalBillGroupSupportType,
      deps.tx_name EventName,
      evt.tx_type EventType,
      deps.id_instance InstanceID,
      deps.id_arg_interval ArgIntervalID,
      deps.dt_arg_start ArgStartDate,
      deps.dt_arg_end ArgEndDate,
      deps.tx_status Status,
      deps.id_orig_billgroup OriginalBillingGroupID,
      deps.id_billgroup BillingGroupID,
      deps.b_critical_dependency IsCriticalDependency,
      deps.tx_billgroup_support BillGroupSupportType
    FROM tmp_deps deps 
    INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
    WHERE 
      /* excludes identity dependencies */
      (deps.id_orig_instance <> deps.id_instance OR
      /* allows missing instances in case of execution deps */
      deps.id_instance IS NULL)'
      || p_status_filter ||'
    /* this ordering is expected by usm for display purposes */
    ORDER BY OriginalInstanceID ASC, ArgIntervalID DESC, 
      EventType ASC, EventName ASC, ArgStartDate DESC';

end GetRecurringEventDepsByInst;
    