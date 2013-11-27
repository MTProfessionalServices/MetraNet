
CREATE OR REPLACE PROCEDURE MARKEVENTASSUCCEEDED
(
  dt_now DATE,
  id_instance INT,
  id_acc INT,
  tx_detail nvarchar2,
  tx_machine VARCHAR2,
  status OUT INT
)
AS
id_run int;
tcount int;
BEGIN
  MarkEventAsSucceeded.status := -99;

  UPDATE t_recevent_inst 
  SET tx_status = 'Succeeded'
  WHERE 
    id_instance = MarkEventAsSucceeded.id_instance AND
    tx_status = 'Failed';
  
  IF SQL%ROWCOUNT = 1 then  /* successfully updated */
    /* inserts a run to record the fact that the status was changed */
    /* this is important for 'cancel' to work correctly in reverse situations */
    GetCurrentID('receventrun', MarkEventAsSucceeded.id_run);
    INSERT INTO t_recevent_run
    (
      id_run,
      id_instance,
      tx_type,
      id_reversed_run,
      tx_machine,
      dt_start,
      dt_end,
      tx_status,
      tx_detail
    )
    VALUES 
    (
      MarkEventAsSucceeded.id_run,
      MarkEventAsSucceeded.id_instance,
      'Execute',
      NULL,
      MarkEventAsSucceeded.tx_machine,
      MarkEventAsSucceeded.dt_now,
      MarkEventAsSucceeded.dt_now,
      'Succeeded',
      'Manually changed status to Succeeded'
    );

    INSERT INTO t_recevent_inst_audit(id_audit,id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
    VALUES(seq_t_recevent_inst_audit.nextval,MarkEventAsSucceeded.id_instance, MarkEventAsSucceeded.id_acc, 'MarkAsSucceeded', NULL, NULL, MarkEventAsSucceeded.tx_detail, MarkEventAsSucceeded.dt_now);
    MarkEventAsSucceeded.status := 0;  /* success */
    COMMIT;
    RETURN;
  END if;
  BEGIN
	  SELECT count(1) into tcount
	  FROM t_recevent_inst 
	  WHERE 
		id_instance = MarkEventAsSucceeded.id_instance;
    if  tcount=0 then
      MarkEventAsSucceeded.status := -1;  /* instance does not exist */
      ROLLBACK;
      RETURN;
    end if;
  END;

  MarkEventAsSucceeded.status := -2;  /* instance was not in a valid state */
  ROLLBACK;
  RETURN; 
END;
  