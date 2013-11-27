
      
/* ===========================================================
1) Clone t_recevent_inst data for the new billing group
2) Clone t_recevent_run data for the new billing group
3) Clone t_recevent_run_details data for the new billing group 
4) Clone t_recevent_run_batch data for the new billing group

Returns the following error codes:
    -1 : Unknown error occurred
    -2 : The given id_materialization has a NULL id_parent_billgroup
    -3 : The given id_materialization is not a 'PullList' 
    -4 : The given id_materialization is not 'InProgress' 
    -5 : No billing group id found in t_billgroup_tmp for the given id_materialization
    -6 : No instances need to be copied
=========================================================== */
CREATE OR REPLACE
PROCEDURE CopyAdapterInstances
(
  p_id_materialization INT,
  p_status out INT,
  p_id_billgroup_parent out INT,
  p_id_billgroup_child out INT,
  p_cur out sys_refcursor
)
AS

  v_tx_materialization_status VARCHAR2(10);
  v_tx_materialization_type VARCHAR2(10);
  v_id_usage_interval INT;
  tmp_newinstancesCount INT;

  v_id_instance_temp INT;
  v_id_instance_parent INT;
  v_id_instance_child INT;
  v_id_run_temp INT;
  v_id_run_parent INT;
  v_id_run_child INT;
  v_id_run_parent_out INT;
  v_id_run_child_out INT;
  v_newrunsCount INT;
  v_tx_instance_status VARCHAR2(14);
  v_min_id_run_temp INT;

begin
  /* Initialize output variables */
  p_status := -1;
  p_id_billgroup_parent := -1;
  p_id_billgroup_child := -1;
  p_cur := empty_cursor;


  for x in (SELECT id_parent_billgroup, 
              tx_status, 
              tx_type,
              id_usage_interval
            FROM t_billgroup_materialization 
            WHERE id_materialization = p_id_materialization) 
  loop
    p_id_billgroup_parent := x.id_parent_billgroup;
    v_tx_materialization_status := x.tx_status;
    v_tx_materialization_type := x.tx_type;
    v_id_usage_interval := x.id_usage_interval;
  end loop;

  /* Error if id_parent_billgroup is NULL */
  IF p_id_billgroup_parent IS NULL then
    p_status := -2;
    /* ROLLBACK; */
    RETURN; 
  END if;

  /* Error if tx_type is not a PullList */
  IF v_tx_materialization_type != 'PullList' then
    p_status := -3;
    /* ROLLBACK */
    RETURN ;
  END if;

  /* Error if tx_status is not InProgress */
  IF v_tx_materialization_status != 'InProgress' then
    p_status := -4;
    /* ROLLBACK; */
    RETURN ;
  END if;

  /* Get the id_billgroup for the pull list being created */
  SELECT max(id_billgroup) into p_id_billgroup_child
  FROM t_billgroup_tmp 
  WHERE id_materialization = p_id_materialization;

  IF p_id_billgroup_child IS NULL then
     p_status := -5;
     /* ROLLBACK; */
     RETURN; 
  END if;

  /*
   We need to clone those adapter instances from the
   parent billing group which have an adapter granularity of 'Account'
   t_recevent.tx_billgroup_support = 'Account'
  */

  /* Get the existing t_recevent_inst which will be copied */
  INSERT into tmp_newinstances
  SELECT seq_tmp_newinstances.nextval,
    id_instance,
    NULL,
    ri.id_event,
    tx_status,
    NULL,
    NULL
  FROM t_recevent_inst ri
  INNER JOIN t_recevent re 
    ON re.id_event = ri.id_event
  WHERE ri.id_arg_billgroup = p_id_billgroup_parent
    AND ri.id_arg_interval =  v_id_usage_interval
    AND re.tx_billgroup_support IN ('Account');

  /* Return if there's nothing to be copied */
  SELECT COUNT(id_instance_temp) into tmp_newinstancesCount
  FROM tmp_newinstances;

  IF (tmp_newinstancesCount = 0) then
    p_status := 0;
    -- ROLLBACK
    RETURN; 
  END if;

  for newinst in (SELECT id_instance_parent,
                    tx_status, id_instance_temp
                  FROM tmp_newinstances)
  loop
     /* retrieve the id_instance which needs to be copied */

    select seq_t_recevent_inst.nextval
    into v_id_instance_child
    from dual;
    
     /* copy */
    INSERT into t_recevent_inst
    SELECT 
      v_id_instance_child,  /* id_instance */
      id_event, 
      id_arg_interval,
      p_id_billgroup_child, 
      dbo.GetBillingGroupAncestor(p_id_billgroup_child), 
      dt_arg_start, 
      dt_arg_end,
      b_ignore_deps, 
      dt_effective, 
      tx_status
    FROM t_recevent_inst
    WHERE id_instance = newinst.id_instance_parent;

    /* update tmp_newinstances with the id_instance_child */
    UPDATE tmp_newinstances
    SET id_instance_child = v_id_instance_child
    WHERE id_instance_temp = newinst.id_instance_temp;

    /* copy the rows in t_recevent_run for id_instance_parent */

    /* populate tmp_newruns with the parent rows */
    insert into tmp_newruns
    select seq_tmp_newruns.nextval,
      id_run,
      NULL,
      tx_type,
      dt_start
    from t_recevent_run
    where id_instance = newinst.id_instance_parent;
    
    /*  set the count of tmp_newruns */
    SELECT COUNT(id_run_temp) into v_newrunsCount
    FROM tmp_newruns;

    for newrun in (select id_run_temp, id_run_parent from tmp_newruns)
    loop
      /* get the run id for the child */
      GetCurrentID('receventrun', v_id_run_child);
      
      /* copy */
      INSERT into t_recevent_run
      SELECT v_id_run_child, v_id_instance_child, 
        tx_type, id_reversed_run, tx_machine, 
        dt_start, dt_end, tx_status, tx_detail
      FROM t_recevent_run
      WHERE id_run = newrun.id_run_parent;
      
      /* update tmp_newruns with the id_run_child */
      UPDATE tmp_newruns
      SET id_run_child = v_id_run_child
      WHERE id_run_temp = newrun.id_run_temp;
      
    END loop; /* the inner while loop ends here */
    
    /*
    Get the @id_run_parent_out and @id_run_child_out. This logic must remain 
    the same as the logic in the 'DetermineReversibleEvents'  StoredProc which
    calculates 'RunIDToReverse'       
    */
    
    IF (newinst.tx_status = 'Succeeded' OR newinst.tx_status = 'Failed') then
      
      v_id_run_parent_out := null; 
      v_id_run_child_out := null;
      for x in (
          SELECT id_run_parent, id_run_child
          FROM tmp_newruns nr
          WHERE tx_type = 'Execute' 
            AND dt_start IN (SELECT MAX(dt_start) FROM tmp_newruns))
      loop
        v_id_run_parent_out := x.id_run_parent; 
        v_id_run_child_out := x.id_run_child;
      end loop;

      /* update tmp_newinstances with the appropriate parent and child run */
      UPDATE tmp_newinstances
      SET id_run_parent = v_id_run_parent_out,
        id_run_child = v_id_run_child_out
      WHERE id_instance_temp = newinst.id_instance_temp;

    END if;

    /* Copy t_recevent_run_details data for the new billing group */
    INSERT INTO t_recevent_run_details(id_detail, id_run,
      tx_type,
      tx_detail,
      dt_crt)
    SELECT seq_t_recevent_run_details.nextval,
	  nr.id_run_child,
      rd.tx_type,
      rd.tx_detail,
      rd.dt_crt
    FROM t_recevent_run_details rd
    INNER JOIN tmp_newruns nr 
      ON nr.id_run_parent = rd.id_run ;

    /* Copy t_recevent_run_batch data for the new billing group  */
    INSERT INTO t_recevent_run_batch(id_run, tx_batch_encoded)
    SELECT nr.id_run_child, rb.tx_batch_encoded
    FROM t_recevent_run_batch rb
    INNER JOIN tmp_newruns nr 
      ON nr.id_run_parent = rb.id_run;
    
    DELETE tmp_newruns;
    
  END loop;

  p_status := 0;
  open p_cur for SELECT * FROM tmp_newinstances;

  /* COMMIT  */

end CopyAdapterInstances;
 	