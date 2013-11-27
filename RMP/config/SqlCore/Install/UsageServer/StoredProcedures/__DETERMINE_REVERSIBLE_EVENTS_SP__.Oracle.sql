
create or replace 
procedure DetermineReversibleEvents(
  p_dt_now date,   
  p_id_instances varchar2,   
  p_result out sys_refcursor) 
as
  deps int;
begin

  delete from tmp_deps;
  deps := dbo.geteventreversaldeps(p_dt_now, p_id_instances);

  /* returns the final rowset of all events that are 'ReadyToRun' and
     have satisfied dependencies. the rows are sorted in the order
     that they should be executed. 
  */

  open p_result for
  select evt.tx_name eventname,
    evt.tx_class_name classname,
    evt.tx_config_file configfile,
    evt.tx_extension_name extension,
    evt.tx_reverse_mode reversemode,
    evt.tx_type eventtype,
    evt_mach.tx_canrunonmachine EventMachineTag,
    run.id_run runidtoreverse,
    inst.id_instance instanceid,
    inst.id_arg_interval arginterval,
    inst.id_arg_billgroup argbillinggroup,
    inst.dt_arg_start argstartdate,
    inst.dt_arg_end argenddate,
    dependedon.total dependentscore
  from t_recevent_inst inst
  inner join t_recevent evt on 
    evt.id_event = inst.id_event
    LEFT JOIN t_recevent_machine evt_mach
                  ON evt.id_event = evt_mach.id_event /* Multiple machine rules results in multiple events; not great but not an issue */
  inner join ( 
    /* finds the the run to reverse (the last execution's run ID) */
    select id_instance, max(dt_start) dt_start
    from t_recevent_run run
    where tx_type = 'Execute'
    group by id_instance 
  ) maxrun 
    on maxrun.id_instance = inst.id_instance
  inner join t_recevent_run run 
    on run.dt_start = maxrun.dt_start
    and run.id_instance = maxrun.id_instance
  inner join ( 
    /* counts the total amount of dependencies per reversible instance */
    select deps.id_orig_instance, count(*) total
    from tmp_deps deps
    group by deps.id_orig_instance
  ) total_deps 
    on total_deps.id_orig_instance = inst.id_instance
  inner join ( 
    /* counts the amount of satisfied dependencies per reversible instance */
    select deps.id_orig_instance, count(*) total
    from tmp_deps deps
    where deps.tx_status = 'NotYetRun'
    group by deps.id_orig_instance
  ) sat_deps 
    on sat_deps.id_orig_instance = inst.id_instance
  inner join (
    /* determines how 'depended on' (from an forward perspective) each instance is
      the least 'depended on' instance should be run first in order
      to unblock the largest amount of other adapters in the shortest amount of time
    */
    select inst.id_orig_instance, count(*) total
    from tmp_deps inst
          /* from table(deps) inst ... should use collection var but it doesn't 
          work with the join; possible oracle bug 
          */
    inner join t_recevent_dep dep 
      on dep.id_dependent_on_event = inst.id_orig_event
    group by inst.id_orig_instance
  ) dependedon 
    on dependedon.id_orig_instance = inst.id_instance 
  left outer join vw_all_billing_groups_status bgs 
    on bgs.id_billgroup = inst.id_arg_billgroup
  where (total_deps.total = sat_deps.total 
        or inst.b_ignore_deps = 'Y')
    and /* instance's effective date has passed or is NULL ('Execute Later') */
        (inst.dt_effective is null or inst.dt_effective <= p_dt_now)
    and /* billing group, if any, must be in the closed state */
        (inst.id_arg_billgroup is null or bgs.status = 'C')
  order by dependedon.total asc, inst.id_instance asc
  ;

   /* no commit so tmp_deps presists for caller */
  
end DetermineReversibleEvents;
  