
CREATE or replace PROCEDURE FAILZOMBIERECURRINGEVENTS
(
  dt_now DATE,          /* system's time */
  tx_machine VARCHAR2,  /* macine to check for zombies on */
  count OUT INT,           /* number of zombies found and failed */
  res OUT sys_refcursor
)
AS

BEGIN

  FailZombieRecurringEvents.count := 0;

	/* Clear out results left from any previous session */
	delete from t_zombiesTempTbl;

  /* finds any zombie recurring events for the given machine */
  INSERT INTO t_zombiesTempTbl
  SELECT 
    inst.id_instance,
    run.id_run
  FROM t_recevent_inst inst
  LEFT OUTER JOIN
  (
    /* finds the last run's ID */
    SELECT 
      id_instance,
    MAX(dt_start) dt_start
    FROM t_recevent_run run
    GROUP BY
      id_instance
  ) lastrun ON lastrun.id_instance = inst.id_instance
  LEFT OUTER JOIN t_recevent_run run ON run.dt_start = lastrun.dt_start
  WHERE 
    (inst.tx_status IN ('Running', 'Reversing') OR run.tx_status = 'InProgress') AND
    /* only look at runs which are being processed by the given machine */
    /* in a multi-machine case, we don't want to fail valid runs */
    /* being processed on a different machine */
    run.tx_machine = FailZombieRecurringEvents.tx_machine;
  count := SQL%ROWCOUNT;

  /* fails the zombie instances */
  UPDATE t_recevent_inst inst
  SET tx_status = 'Failed'
  WHERE EXISTS (SELECT 'X' FROM
                  t_zombiesTempTbl zombies where zombies.id_instance = inst.id_instance);
                  

  /* fails the zombie runs  */
  UPDATE t_recevent_run run
  SET tx_status = 'Failed',
      dt_end = FAILZOMBIERECURRINGEVENTS.dt_now,
      tx_detail = 'Run was identified as a zombie'
  where exists (select 'x' from
                 t_zombiesTempTbl zombies where zombies.id_run = run.id_run);

  open res for
  SELECT 
    id_instance InstanceID,
    id_run RunID
  FROM t_zombiesTempTbl;
  COMMIT;
END;
  