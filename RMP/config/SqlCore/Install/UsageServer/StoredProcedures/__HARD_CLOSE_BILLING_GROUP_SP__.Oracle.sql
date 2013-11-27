
/* ===========================================================
Attempts to 'HardClose' the given billing group.

Returns the following error codes:
   -1 : Unknown error occurred
   -2 : @id_billgroup does not exist
   -3 : The billgroup is already HardClosed
   -4 : This is the last billing group to be hard closed and there are unassigned accounts
          which are not hard closed
   -5 : Could not update billing group status to 'H'
=========================================================== */
create or replace 
procedure HardCloseBillingGroup (
  p_id_billgroup int,   /* specific billing group to hard close */
  p_status out int  /* return code: 0 is successful */
)
as
  cnt int;
  billgrp_status char(1);
  interval_id int;

  num_hardclosed_billgrps int;
  num_billgrps int;
  last_billgrp int;

  status int;
  ignored_status int;
begin

  p_status := -1; 
  
  /* checks that the billing group exists */
  select count(1) into cnt
  from t_billgroup
  where id_billgroup = p_id_billgroup;
  
  if (cnt < 1) then
    p_status := -2;
    rollback;
    return;
  end if;

  /* checks that the billing group is soft closed */
  select status, id_usage_interval
  into billgrp_status, interval_id
  from vw_all_billing_groups_status
  where id_billgroup = p_id_billgroup;
  
  if (billgrp_status = 'H') then
    p_status := -3;
    rollback;
    return;
  end if;

  /* If this is the last billing group which is being hard closed for the interval 
    then make sure that all unassigned accounts have their status set to 'H'
  */
  
  last_billgrp := 0;
  
  select count(id_billgroup) into num_hardclosed_billgrps
  from vw_all_billing_groups_status
  where id_usage_interval = interval_id
   and status = 'H';
  
  select count(id_billgroup) into num_billgrps
  from vw_all_billing_groups_status
  where id_usage_interval = interval_id;
  
  if (num_hardclosed_billgrps = (num_billgrps - 1)) then
    last_billgrp := 1;
  end if;
  
  if (last_billgrp = 1) then
  
    select count(1) into cnt
    from vw_unassigned_accounts
    where intervalid = interval_id
    and state != 'H';
  
    if (cnt > 0) then
      status := -4;
      rollback;
      return;
    end if;

  end if;

  /* Take lock so that next two calls are sequenced. There likely will be concurrent calls to this sp.*/
  LOCK TABLE t_acc_usage_interval IN EXCLUSIVE MODE; 

  /* Update the billing group status to 'H' */
  UpdateBillingGroupStatus(p_id_billgroup, 'H');
  
  /* Update the status in t_usage_interval to hard closed, if possible. */
  UpdIntervalStatusToHardClosed(interval_id, 0, ignored_status);
  
  if (status != 0) then
    p_status := -5;
    rollback;
    return;
  end if;
  
  p_status := 0; /* success */

  commit;
  
end HardCloseBillingGroup;
  