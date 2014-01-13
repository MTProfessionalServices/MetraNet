CREATE OR REPLACE PROCEDURE DetermineExecutableEvents (
   dt_now             DATE,
   id_instances       VARCHAR2,
   result         OUT SYS_REFCURSOR)
AS
   deps   INT;
BEGIN
   DELETE FROM tmp_deps;

   deps := dbo.GetEventExecutionDeps (dt_now, id_instances);          

   /* returns the final rowset of all events that are 'ReadyToRun' and */
   /* have satisfied dependencies. the rows are sorted in the order */
   /* that they should be executed.  */

   OPEN result FOR
        SELECT evt.tx_name EventName,
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
               INNER JOIN t_recevent evt
                  ON evt.id_event = inst.id_event
               LEFT JOIN t_recevent_machine evt_mach
                  ON evt.id_event = evt_mach.id_event /* Multiple machine rules results in multiple events; not great but not an issue */
               INNER JOIN ( /* counts the total amount of dependencies per runnable instance */
                           SELECT   deps.id_orig_instance, COUNT (*) total
                               FROM tmp_deps deps
                           GROUP BY deps.id_orig_instance) total_deps
                  ON total_deps.id_orig_instance = inst.id_instance
               INNER JOIN ( /* counts the amount of satisfied dependencies per runnable instance */
                           SELECT   deps.id_orig_instance, COUNT (*) total
                               FROM tmp_deps deps
                              WHERE deps.tx_status = 'Succeeded'
                           GROUP BY deps.id_orig_instance) sat_deps
                  ON sat_deps.id_orig_instance = inst.id_instance
               INNER JOIN (  SELECT inst.id_orig_instance, COUNT (*) total
                               FROM    tmp_deps inst
                                    INNER JOIN
                                       t_recevent_dep dep
                                    ON dep.id_dependent_on_event =
                                          inst.id_orig_event
                           GROUP BY inst.id_orig_instance) dependedon
                  ON dependedon.id_orig_instance = inst.id_instance
               INNER JOIN (/* Determines if any instances are running and which are compatible to also run at the same time */
                           /* Events that do not conflict at the moment (compatible with running events or nothing is running) */
                           SELECT tx_compatible_eventname
                             FROM TABLE (dbo.GetCompatibleConcurrentEvents)) compatible
                  ON evt.tx_name = compatible.tx_compatible_eventname
               LEFT OUTER JOIN vw_all_billing_groups_status bgs
                  ON bgs.id_billgroup = inst.id_arg_billgroup
         WHERE (total_deps.total = sat_deps.total OR inst.b_ignore_deps = 'Y')
               AND (inst.dt_effective IS NULL OR inst.dt_effective <= dt_now)
               AND (inst.id_arg_billgroup IS NULL OR bgs.status = 'C')
      ORDER BY dependedon.total DESC, inst.id_instance ASC; /* no commit so tmp_deps presists for caller */
END DetermineExecutableEvents;