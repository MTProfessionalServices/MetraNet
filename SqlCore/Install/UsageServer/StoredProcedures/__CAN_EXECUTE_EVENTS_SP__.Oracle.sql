
CREATE or replace PROCEDURE CANEXECUTEEVENTS(dt_now DATE, id_instances VARCHAR2, lang_code int, res out sys_refcursor)
AS
BEGIN

  /*  */
  /* initially all instances are considered okay */
  /* a succession of queries attempt to find a problem with executing them */
  /*  */

  execute immediate 'truncate table t_CanExecuteEventsTempTbl';
  
  /* builds up a table from the comma separated list of instance IDs */

  INSERT INTO t_CanExecuteEventsTempTbl
  SELECT
    args.COLUMN_VALUE,
    COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
    'OK'
  FROM table(cast(dbo.CSVToInt(CANEXECUTEEVENTS.id_instances) as  tab_id_instance)) args
  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.COLUMN_VALUE
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

  /* is the event not active */
  UPDATE t_CanExecuteEventsTempTbl results
  SET tx_reason = 'EventNotActive'
  where exists
  (
  SELECT 'X'
  FROM t_recevent_inst inst , t_recevent evt 
  WHERE
  inst.id_instance = results.id_instance
  AND
  evt.id_event = inst.id_event
  AND
    /* event is NOT active */
    evt.dt_activated > CanExecuteEvents.dt_now AND
    (evt.dt_deactivated IS NOT NULL OR CanExecuteEvents.dt_now >= evt.dt_deactivated)
   );

  /* is the instance in an invalid state */
    for data in (
		  select results.rowid as r_rowid, inst.tx_status as i_inst_tx_status
		  FROM t_CanExecuteEventsTempTbl results, t_recevent_inst inst
		  WHERE   inst.id_instance = results.id_instance and
		  inst.tx_status NOT IN ('NotYetRun', 'ReadyToRun')
	    )
    loop
        UPDATE t_CanExecuteEventsTempTbl results
          SET tx_reason = data.i_inst_tx_status
          where rowid = data.r_rowid;
    end loop;



  /* is the interval hard closed */
  UPDATE t_CanExecuteEventsTempTbl results
  SET tx_reason = 'HardClosed'
  where exists (
  SELECT 'X'
  FROM t_recevent_inst inst,t_usage_interval ui
  WHERE 
  inst.id_instance = results.id_instance AND
  ui.id_interval = inst.id_arg_interval AND
    ui.tx_interval_status = 'H'
    );
    
  open res for
  SELECT 
    id_instance InstanceID,
    tx_display_name EventDisplayName,
    tx_reason Reason  
  FROM t_CanExecuteEventsTempTbl;
  COMMIT;
END;
  