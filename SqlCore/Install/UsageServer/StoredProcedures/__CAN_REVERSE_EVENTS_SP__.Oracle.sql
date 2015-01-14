
CREATE OR REPLACE PROCEDURE CANREVERSEEVENTS(dt_now DATE, id_instances VARCHAR2, lang_code int, RES OUT SYS_REFCURSOR)
AS
BEGIN
  /*  */
  /* initially all instances are considered okay */
  /* a succession of queries attempt to find a reason */
  /* why an instance can not be reversed */

  /* builds up a table from the comma separated list of instance IDs */
  execute immediate 'truncate table t_CanExecuteEventsTempTbl';

  INSERT INTO t_CanExecuteEventsTempTbl
  SELECT
    args.column_value,
    COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
    'OK'
  FROM table(cast(dbo.CSVToInt(CANREVERSEEVENTS.id_instances)as  tab_id_instance)) args
  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.column_value
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);
  /* is the event not active */
  UPDATE t_CanExecuteEventsTempTbl results SET tx_reason = 'EventNotActive'
  where exists (
  SELECT 'X'
  FROM t_recevent_inst inst ,t_recevent evt
  WHERE 
  inst.id_instance = results.id_instance and
  evt.id_event = inst.id_event and
    /* event is NOT active */
    evt.dt_activated > CANREVERSEEVENTS.dt_now AND
    (evt.dt_deactivated IS NOT NULL OR CANREVERSEEVENTS.dt_now >= evt.dt_deactivated)
    );
    
  /* is the event not reversible */
  FOR data in (select results.rowid as "rowid", evt.tx_reverse_mode as tx_reverse_mode FROM t_CanExecuteEventsTempTbl results
              INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
              INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
              WHERE
            /* event is NOT reversible */
            evt.tx_reverse_mode = 'NotImplemented'
            )
  loop
      UPDATE t_CanExecuteEventsTempTbl SET tx_reason = data.tx_reverse_mode
      where rowid = data."rowid";
  end loop;
  
  
  
  /* is the instance in an invalid state */
  for data in (select results.rowid as "rowid", inst.tx_status as tx_status FROM t_CanExecuteEventsTempTbl results
              INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
              WHERE
              inst.tx_status NOT IN ('ReadyToReverse', 'Succeeded', 'Failed')
              )
  loop
  UPDATE t_CanExecuteEventsTempTbl SET tx_reason = data.tx_status
  where rowid = data."rowid";
  end loop;
  
  
  
  /* is the interval hard closed */
  UPDATE t_CanExecuteEventsTempTbl results SET tx_reason = 'HardClosed'
  WHERE EXISTS (
  SELECT 'X'
  FROM t_recevent_inst inst,t_usage_interval ui
  WHERE 
  inst.id_instance = results.id_instance AND
  ui.id_interval = inst.id_arg_interval AND
    ui.tx_interval_status = 'H');

  OPEN RES FOR
  SELECT 
    id_instance InstanceID,
    tx_display_name EventDisplayName,
    tx_reason Reason  
  FROM t_CanExecuteEventsTempTbl;
  COMMIT;
END;
