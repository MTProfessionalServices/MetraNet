
CREATE OR REPLACE PROCEDURE OPENUSAGEINTERVAL
(
  dt_now DATE,     /* MetraTech system date */
  id_interval INT,     /* specific usage interval to reopen, the interval must be soft-closed */
  ignoreDeps INT,      /* whether to ignore the reverse dependencies for re-opening the interval */
  pretend INT,         /* if pretend is true, the interval is not actually reopened */
  status OUT INT    /* return code: 0 is successful */
)
AS
count INT;
id_instance INT;
deps_tab int;
BEGIN

  status := -999;

  /* checks that the interval is soft closed */
  
  SELECT COUNT(*) INTO count
  FROM t_usage_interval
  WHERE
    id_interval = OpenUsageInterval.id_interval AND
    tx_interval_status = 'C';

  IF OpenUsageInterval.count = 0 THEN
    SELECT COUNT('x') INTO OpenUsageInterval.count
    FROM t_usage_interval
    WHERE id_interval = OpenUsageInterval.id_interval;

    IF OpenUsageInterval.count = 0 THEN
      /* interval not found */
      OpenUsageInterval.status := -1;
    ELSE
      /* interval not soft closed */
      OpenUsageInterval.status := -2;
    END IF;
    ROLLBACK;
    RETURN;
  END IF;

  /*  */
  /* retrieves the instance ID of the start root event for the given interval */
  /*  */
    begin
      for i in (
	  SELECT inst.id_instance id_instance
	  FROM t_recevent_inst inst
	  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
	  WHERE
		/* event must be active */
		evt.dt_activated <= OpenUsageInterval.dt_now and
		(evt.dt_deactivated IS NULL OR OpenUsageInterval.dt_now < evt.dt_deactivated) AND
		/* instance must match the given interval */
		inst.id_arg_interval = OpenUsageInterval.id_interval AND
		evt.tx_name = '_StartRoot' AND
		evt.tx_type = 'Root')
        loop
            OpenUsageInterval.id_instance := i.id_instance;
        end loop;
	end;

  IF OpenUsageInterval.id_instance IS NULL THEN
    /* start root instance was not found! */
    OpenUsageInterval.status := -3;
    ROLLBACK;
    RETURN;
  END IF;


  /*  */
  /* checks start root's reversal dependencies */
  /*  */
/*
  IF OpenUsageInterval.ignoreDeps = 0 THEN
      deps_tab := dbo.GetEventReversalDeps(OpenUsageInterval.dt_now, OpenUsageInterval.id_instance);

    SELECT COUNT(*) INTO OpenUsageInterval.count
    FROM tmp_deps deps
    WHERE deps.tx_status <> 'NotYetRun';
*/


  IF OpenUsageInterval.ignoreDeps = 0 THEN
	 deps_tab := dbo.GetEventReversalDeps(OpenUsageInterval.dt_now, OpenUsageInterval.id_instance);
     SELECT COUNT(*) INTO OpenUsageInterval.count
	 FROM tmp_deps deps
	 WHERE deps.tx_status <> 'NotYetRun';
    IF OpenUsageInterval.count > 0 THEN
      /* not all instances in the interval have been reversed successfuly */
      OpenUsageInterval.status := -4;
      ROLLBACK;
      RETURN;
    END IF;
  END IF;

  /* just pretending, so don't do the update */
  IF OpenUsageInterval.pretend != 0 THEN
    status := 0; /* success */
    COMMIT;
    RETURN;
  END IF;

  UPDATE t_usage_interval SET tx_interval_status = 'O'
  WHERE
    id_interval = OpenUsageInterval.id_interval AND
    tx_interval_status = 'C';

  IF SQL%ROWCOUNT = 1 THEN
    status := 0; /* success */
    COMMIT;
  ELSE
    /* couldn't update the interval */
    status := -5;
    ROLLBACK;
  END IF;
END;

  