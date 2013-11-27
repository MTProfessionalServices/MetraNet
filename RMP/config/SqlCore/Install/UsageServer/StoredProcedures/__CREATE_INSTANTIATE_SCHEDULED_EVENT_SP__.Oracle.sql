
CREATE OR REPLACE PROCEDURE INSTANTIATESCHEDULEDEVENT 
  (
    dt_now DATE,
    id_event INT,
    dt_end DATE,
    id_instance OUT INT ,
    status OUT INT
  )
AS
v_count int;
BEGIN

  InstantiateScheduledEvent.status := -99;
  InstantiateScheduledEvent.id_instance := -99;

  /*  */
  /* attempts to update an pre-existing NotYetRun instance of this event */
  /*  */
  for i in (
  SELECT inst.id_instance id_instance 
  FROM t_recevent_inst inst
  INNER JOIN 
  (
    /* finds the last instance */
    SELECT MAX(inst.dt_arg_end) dt_arg_end
    FROM t_recevent evt
    INNER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
    WHERE
      /* event is active */
      evt.dt_activated <= InstantiateScheduledEvent.dt_now AND
      (evt.dt_deactivated IS NULL OR InstantiateScheduledEvent.dt_now < evt.dt_deactivated) AND
      evt.id_event = InstantiateScheduledEvent.id_event AND
      /* event is of type scheduled */
      evt.tx_type = 'Scheduled'
  ) maxinst ON maxinst.dt_arg_end = inst.dt_arg_end
  WHERE
    inst.id_event = InstantiateScheduledEvent.id_event AND
    /* run has not yet been run */
    inst.tx_status = 'NotYetRun' AND
    /* existing end date of the latest instance must be  */
    /* before the newly requested end date */
    inst.dt_arg_end < InstantiateScheduledEvent.dt_end)
    loop
        InstantiateScheduledEvent.id_instance := i.id_instance;
        v_count := nvl(v_count,0) + 1;
    end loop;

  IF (v_count = 1) then
    UPDATE t_recevent_inst SET dt_arg_end = InstantiateScheduledEvent.dt_end WHERE id_instance = InstantiateScheduledEvent.id_instance;
    COMMIT;
    InstantiateScheduledEvent.status := 0; /* success (update) */
    RETURN;
  END if;
  v_count := 0;
  
  FOR data in
  (
  
SELECT   evt.id_event as id_event, NULL as id_arg_interval,
         MAX (dbo.addsecond (NVL (inst.dt_arg_end,
                                  dbo.subtractsecond (evt.dt_activated)
                                 )
                            )
             ) as mdate,
         instantiatescheduledevent.dt_end as dt_end,
        'N' as b_ignore_deps,
        NULL as dt_effective
        ,'NotYetRun' as tx_status
    FROM t_recevent evt LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event =
                                                                  evt.id_event
   WHERE
         /* event is active */
         evt.dt_activated <= instantiatescheduledevent.dt_now
     AND (   evt.dt_deactivated IS NULL
          OR instantiatescheduledevent.dt_now < evt.dt_deactivated
         )
     AND evt.id_event = instantiatescheduledevent.id_event
     AND
         /* event is of type scheduled */
         evt.tx_type = 'Scheduled'
GROUP BY evt.id_event
  HAVING
         /* start date must come before the requested end date */
         MAX (dbo.addsecond (NVL (inst.dt_arg_end, evt.dt_activated))) <
                                              instantiatescheduledevent.dt_end)
  loop
  INSERT INTO t_recevent_inst(ID_INSTANCE, id_event,id_arg_interval,dt_arg_start,dt_arg_end,b_ignore_deps,dt_effective,tx_status)
  values
  (seq_t_recevent_inst.NEXTVAL, data.id_event, NULL, data.mdate, data.dt_end, data.b_ignore_deps,data.dt_effective, data.tx_status);
  end loop;
  /* success! */
  IF (SQL%ROWCOUNT = 1) then
    InstantiateScheduledEvent.status := 0;    /* success (insert) */
    select seq_t_recevent_inst.currval into id_instance from dual;
    COMMIT;
    RETURN;
  END if;

  SELECT 
    count(evt.id_event) into v_count
  FROM t_recevent evt
  WHERE
    evt.dt_activated <= InstantiateScheduledEvent.dt_now AND
    (evt.dt_deactivated IS NULL OR InstantiateScheduledEvent.dt_now < evt.dt_deactivated) AND
    evt.id_event = InstantiateScheduledEvent.id_event;

  IF (v_count = 0) then
    InstantiateScheduledEvent.status := -1; /* event not found */
    ROLLBACK;
    RETURN;
  END if;

  SELECT 
    count(evt.id_event) into v_count
  FROM t_recevent evt
  WHERE
    evt.tx_type = 'Scheduled' AND
    evt.id_event = InstantiateScheduledEvent.id_event;

  IF (v_count = 0) THEN
    InstantiateScheduledEvent.status := -2; /* event is not active */
    ROLLBACK;
    RETURN;
  END IF;

  select count('X') into  v_count
  FROM t_recevent evt
  LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
  WHERE
    evt.id_event = InstantiateScheduledEvent.id_event
  GROUP BY
    evt.id_event
  HAVING
    /* start date must come before the requested end date */
    MAX(dbo.AddSecond(nvl(inst.dt_arg_end, evt.dt_activated))) < InstantiateScheduledEvent.dt_end;


  IF (v_count = 0) THEN
    InstantiateScheduledEvent.status := -3; /* last end date is greater than the proposed start date */
    ROLLBACK;
    RETURN;
  END IF;
  ROLLBACK;
  InstantiateScheduledEvent.status := -99;
END;
  