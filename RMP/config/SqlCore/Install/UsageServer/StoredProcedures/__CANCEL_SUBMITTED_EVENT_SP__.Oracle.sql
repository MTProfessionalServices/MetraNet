
CREATE OR REPLACE PROCEDURE CANCELSUBMITTEDEVENT
(
  p_dt_now DATE,
  p_id_instance INT,
  p_id_acc INT,
  p_tx_detail nvarchar2,
  p_status out INT
)
AS
current_status varchar2(14);
previous_status varchar2(14);
BEGIN

  p_status := -99;
  
  /* gets the instances current status */
  BEGIN
  for i in (
  SELECT 
    inst.tx_status tx_status 
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    /* event is active */
    evt.dt_activated <= p_dt_now AND
    (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
    inst.id_instance = p_id_instance)
  loop
    current_status := i.tx_status;
  end loop;
  if current_status is null then
    p_status := -1;  /* instance was not found */
    ROLLBACK;
    RETURN;
  end if;
  END;

  IF current_status = 'ReadyToRun' THEN
    /* the only way to get to ReadyToRun is from NotYetRun */
    previous_status := 'NotYetRun';
  ELSIF current_status = 'ReadyToReverse' then
   /* the only way to get to ReadyToReverse is from Succeeded or Failed */
    /* determines which of these two statuses by looking at the last run's status */
    /* Oracle processes where claus first rather than order by */
    /* Changing query accordingly , vishal verma */
    BEGIN
    SELECT tx_status into previous_status
    FROM (select tx_status from t_recevent_run run
            WHERE run.id_instance = p_id_instance
            ORDER BY run.dt_end desc)
            where rownum < 2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  ELSE
    p_status := -2;  /* instance cannot be cancelled because it is not in a legal state */
    ROLLBACK;
    RETURN;
  END IF;
  /* reverts the instance's state to what it was previously */
  UPDATE t_recevent_inst
  SET tx_status = previous_status, b_ignore_deps = 'N', dt_effective = NULL
  WHERE id_instance = p_id_instance;

  /* records the action */
    INSERT INTO t_recevent_inst_audit(id_audit, id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
  VALUES(seq_t_recevent_inst_audit.nextval, p_id_instance, p_id_acc, 'Cancel', NULL, NULL, p_tx_detail, p_dt_now);
  p_status := 0;  /* success */
  COMMIT;
END;
