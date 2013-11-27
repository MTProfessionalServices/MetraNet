
CREATE PROCEDURE FailZombieRecurringEvents
(
  @dt_now DATETIME,          -- system's time
  @tx_machine VARCHAR(128),  -- macine to check for zombies on
  @count INT OUTPUT          -- number of zombies found and failed
)
AS

BEGIN

  BEGIN TRAN

  SELECT @count = 0

  DECLARE @zombies TABLE
  (
    id_instance INT NOT NULL,
    id_run INT NOT NULL
  )

  -- finds any zombie recurring events for the given machine
  INSERT INTO @zombies
  SELECT 
    inst.id_instance,
    run.id_run
  FROM t_recevent_inst inst
  LEFT OUTER JOIN
  (
    -- finds the last run's ID
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
    -- only look at runs which are being processed by the given machine
    -- in a multi-machine case, we don't want to fail valid runs
    -- being processed on a different machine
    run.tx_machine = @tx_machine

  SELECT @count = @@ROWCOUNT  

  -- fails the zombie instances
  UPDATE t_recevent_inst
  SET tx_status = 'Failed'
  FROM t_recevent_inst inst
  INNER JOIN @zombies zombies ON zombies.id_instance = inst.id_instance

  -- fails the zombie runs 
  UPDATE t_recevent_run
  SET tx_status = 'Failed', dt_end = @dt_now, tx_detail = 'Run was identified as a zombie'
  FROM t_recevent_run run
  INNER JOIN @zombies zombies ON zombies.id_run = run.id_run

  SELECT 
    id_instance InstanceID,
    id_run RunID
  FROM @zombies
  COMMIT
END
  