
/* ===========================================================
Attempts to 'Open' the given billing group.

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : @id_billgroup does not exist
   -3 : The billgroup is not soft closed
   -4 : Unable to find _StartRoot instance for @id_billgroup
   -5 : Not all instances, which depend on the billing group, have been reversed successfully
   -6 : Could not update billing group status to 'C'
=========================================================== */
CREATE OR REPLACE
PROCEDURE OpenBillingGroup
(
  p_dt_now DATE,      /* MetraTech system date */
  p_id_billgroup INT, /* specific billing group to reopen, the billing group must be soft-closed */
  p_ignoreDeps INT,   /* whether to ignore the reverse dependencies for re-opening the billing group */
  p_pretend INT,      /* if pretend is true, the billing group is not actually reopened */
  status out INT      /* return code: 0 is successful */
)
AS
  id_instance int;
  billingGroupStatus varchar2(1);
  cnt int := 0;
  rev_deps int;
BEGIN
  status := -1;
  
  /*  checks that the billing group exists */
  SELECT count(id_billgroup) into cnt
  FROM t_billgroup
  WHERE id_billgroup = p_id_billgroup;
                          
  IF cnt < 1 then
    status := -2;
    rollback;
    return;
  END if;

  /* checks that the billing group is soft closed */
  SELECT bg.status into billingGroupStatus
  FROM vw_all_billing_groups_status bg
  WHERE id_billgroup = p_id_billgroup;

  IF (billingGroupStatus <> 'C') then
    status := -3;
    ROLLBACK;
    RETURN;
  END if;

  /* retrieves the instance ID of the start root event for the 
    * given billing group
    */
  SELECT max(inst.id_instance), count(inst.id_instance) 
  into id_instance, cnt
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt
      ON evt.id_event = inst.id_event
  WHERE
    /* event must be active */
    evt.dt_activated <= p_dt_now and
    (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
    /* instance must match the given billing group */
    inst.id_arg_billgroup = p_id_billgroup AND
    evt.tx_name = '_StartRoot' AND
    evt.tx_type = 'Root';

  IF id_instance IS NULL or cnt <> 1 then
    /* start root instance was not found! */
    status := -4;
    rollback;
    return;
  end if;
  
  /* checks start root's reversal dependencies
    */
  IF p_ignoreDeps = 0 then


    rev_deps := dbo.GetEventReversalDeps(p_dt_now, id_instance);
    select count(*) into cnt
    FROM  tmp_deps deps
    WHERE deps.tx_status <> 'NotYetRun';

    IF cnt > 0 then
      /* not all instances, which depend on the billing group, 
        * have been reversed successfully
        */
      status := -5;
      ROLLBACK;
      RETURN;
    end if;
  END if;

  /* just pretending, so don't do the update */
  IF p_pretend != 0 then
    status := 0; /* success */
    COMMIT;
    RETURN;
  END if;

  UpdateBillingGroupStatus(p_id_billgroup, 'O');
  
  IF (sqlcode != 0) then
    status := -6;
    ROLLBACK;
    RETURN;
  END if;

   status := 0; /* success */
   commit;

end OpenBillingGroup;
  