
/* ===========================================================
Updates the event id's for soft closed instances. If the event is an interval-only event,
then update it only if the interval isn't hard closed.
=========================================================== */
UPDATE t_recevent_inst 
SET id_event = %%NEW_EVENT_ID%%
FROM t_recevent_inst inst 
INNER JOIN t_usage_interval ui
  ON ui.id_interval = inst.id_arg_interval
LEFT OUTER JOIN vw_all_billing_groups_status bgs
   ON bgs.id_billgroup = inst.id_arg_billgroup AND 
         bgs.id_usage_interval = inst.id_arg_interval
WHERE
  inst.id_event = %%OLD_EVENT_ID%% AND
  (
    bgs.status = 'C' 
      OR
    (inst.id_arg_billgroup IS NULL AND ui.tx_interval_status != 'H')

  )
      