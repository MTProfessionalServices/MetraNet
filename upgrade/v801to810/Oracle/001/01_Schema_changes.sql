SET DEFINE OFF

DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT (NVL(MAX(upgrade_id), 0) + 1)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;

    INSERT INTO t_sys_upgrade
      (
        upgrade_id,
        target_db_version,
        dt_start_db_upgrade,
        db_upgrade_status
      )
    VALUES
      (
        last_upgrade_id,
        '8.1.0',
        SYSDATE,
        'R'
      );
END;
/

CREATE TABLE t_localized_items
(
	id_local_type int NOT NULL,     			/* Composite key: This is foreign key to t_localized_items_type.*/
	id_item int NOT NULL,						/* Composite key: Localize identifier. This is foreign key to t_recevent and other tables*/
	id_item_second_key int default -1 NOT NULL,	/* Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value */
	id_lang_code int NOT NULL,      			/* Composite key: Language identifier displayed on the MetraNet Presentation Server */
	tx_name NVARCHAR2(255) NULL,   				/* The localized DisplayName */
	tx_desc NVARCHAR2(2000) NULL,  				/* The localized Description */
CONSTRAINT PK_t_localized_items PRIMARY KEY (id_local_type, id_item, id_item_second_key, id_lang_code)
)
/

COMMENT ON TABLE  t_localized_items 						IS  'The t_localized_items table contains the localized DisplayName and Description of entyties (for example t_recevent, t_composite_capability_type, t_atomic_capability_type tables) for the languages supported by the MetraTech platform.(Package:Pipeline) ';
/
COMMENT ON COLUMN t_localized_items.id_local_type 			IS	'Composite key: This is foreign key to t_localized_items_type.';
/
COMMENT ON COLUMN t_localized_items.id_item					IS	'Composite key: Localize identifier. This is foreign key to t_recevent and other tables (see constraints)';
/
COMMENT ON COLUMN t_localized_items.id_item_second_key 		IS 'Composite key: Second localize identifier. This is foreign key, for example, to t_compositor (it is atomoc capability) and other tables with composite PK. In case second key is not used set -1 as default value';
/
COMMENT ON COLUMN t_localized_items.id_lang_code			IS	'Composite key: Language identifier displayed on the MetraNet Presentation Server';
/
COMMENT ON COLUMN t_localized_items.tx_name 				IS 	'The localized DisplayName';
/
COMMENT ON COLUMN t_localized_items.tx_desc 				IS 	'The localized DEscription';
/

CREATE TABLE t_localized_items_type
(
	id_local_type int NOT NULL,     	/* PK, where '1' - Localization type for Recurring Adapters,
													 '2' - 'Localization type for Composite Capability,
													 '3' - 'Localization type for Atomic Capability */	
	local_type_description NVARCHAR2(255) NOT NULL,	/* The type description */
CONSTRAINT PK_t_localized_items_type PRIMARY KEY (id_local_type)
)
/
COMMENT ON TABLE t_localized_items_type							IS  'Dictionary table for t_localized_items.id_local_type colum. Contains id localization type and their description';
/
COMMENT ON COLUMN t_localized_items_type.id_local_type 			IS	'Primary key.';
/
COMMENT ON COLUMN t_localized_items_type.local_type_description	IS	'Description type';
/


alter table t_localized_items add constraint FK_LOCAL_TO_LOCAL_ITEMS_TYPE
					foreign key(id_local_type) references t_localized_items_type(id_local_type);
/
					
alter table t_localized_items add constraint FK_LOCALIZE_TO_T_LANGUAGE
					foreign key(id_lang_code) references t_language (id_lang_code);
/


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
/


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
  
/

CREATE OR REPLACE procedure CanReverseEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from tmp_deps;
   exec_deps := dbo.GetEventReversalDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for 
      SELECT
        orig_evt.tx_name OriginalEventName,
        orig_evt.tx_display_name OriginalEventDisplayName,        
        COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,    
        evt.tx_type EventType,
        evt.tx_reverse_mode ReverseMode,
        deps.OriginalInstanceID,
        deps.EventID,
        deps.EventName,
        deps.InstanceID,
        deps.ArgIntervalID,
        deps.ArgStartDate,
        deps.ArgEndDate,
        deps.Status,
        /* the corrective action that must occur */
        CASE deps.Status WHEN 'Succeeded' THEN 'Reverse'
                        WHEN 'Failed' THEN 'Reverse'
                        WHEN 'ReadyToRun' THEN 'Cancel'
                        WHEN 'Running' THEN 'TryAgainLater'
                        ELSE 'Unknown' END Action,
        nvl(deps.BillGroupName, 'Not Available') BillGroupName
      FROM
      (
        SELECT 
          MIN(deps.id_orig_instance) OriginalInstanceID,
          deps.id_event EventID,
          deps.tx_name EventName,
          deps.id_instance InstanceID,
          deps.id_arg_interval ArgIntervalID,
          deps.dt_arg_start ArgStartDate,
          deps.dt_arg_end ArgEndDate,
          deps.tx_status Status,
          bg.tx_name BillGroupName
        FROM tmp_deps deps
        LEFT OUTER JOIN t_billgroup bg ON bg.id_billgroup = deps.id_billgroup
        WHERE 
          /* excludes input instances */
          (deps.id_instance NOT IN (select column_value 
                      from table(dbo.csvtoint(p_id_instances))) 
               OR deps.id_instance IS NULL) AND
          /* only look at deps that need an action to be taken */
          deps.tx_status NOT IN ('NotYetRun', 'ReadyToReverse', 'Reversing')
        GROUP BY 
          deps.id_instance,
          deps.id_event,
          deps.tx_name,
          deps.id_arg_interval,
          deps.dt_arg_start,
          deps.dt_arg_end,
          deps.tx_status,
          bg.tx_name
      ) deps
      INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
      INNER JOIN t_recevent_inst orig_inst ON orig_inst.id_instance = deps.OriginalInstanceID
      INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
      LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanReverseEventDeps;
/


CREATE OR REPLACE procedure CanExecuteEventDeps (
   p_dt_now               date,
   p_id_instances         varchar2,
   lang_code              int,
   p_result         out   sys_refcursor
)
as
   exec_deps   int;
begin

   delete from	tmp_deps;
   exec_deps := dbo.GetEventExecutionDeps(p_dt_now, p_id_instances);                                                            /*  */

  open p_result for 
    select
      orig_evt.tx_name OriginalEventName,
      orig_evt.tx_display_name OriginalEventDisplayName,
      COALESCE(loc.tx_name, evt.tx_display_name) EventDisplayName,    
      evt.tx_type EventType,
      deps.OriginalInstanceID,
      deps.EventID,
      deps.EventName,
      deps.InstanceID,
      deps.ArgIntervalID,
      deps.ArgStartDate,
      deps.ArgEndDate,
      deps.Status,
      /*  the corrective action that must occur */
      CASE deps.Status WHEN 'NotYetRun' THEN 'Execute'
                       WHEN 'Failed' THEN 'Reverse'
                       WHEN 'ReadyToRun' THEN 'Cancel'
                       WHEN 'Reversing' THEN 'TryAgainLater'
                       ELSE 'Unknown' END AS Action,
      nvl(deps.BillGroupName, N'Not Available') BillGroupName
    FROM
    (
      SELECT 
        MIN(deps_inner.id_orig_instance) OriginalInstanceID,
        deps_inner.id_event EventID,
        deps_inner.tx_name EventName,
        deps_inner.id_instance InstanceID,
        deps_inner.id_arg_interval ArgIntervalID,
        deps_inner.dt_arg_start ArgStartDate,
        deps_inner.dt_arg_end ArgEndDate,
        deps_inner.tx_status Status,
        bg.tx_name as BillGroupName
      FROM  tmp_deps deps_inner
          /* table(exec_deps) deps_inner */ 
      LEFT OUTER JOIN t_billgroup bg 
        ON bg.id_billgroup = deps_inner.id_billgroup
      WHERE 
        /* excludes input instances */
        (deps_inner.id_instance NOT IN ( select column_value 
                      from table(dbo.csvtoint(p_id_instances))) 
            OR deps_inner.id_instance IS NULL) AND
        /* only look at deps that need an action to be taken */
        deps_inner.tx_status NOT IN ('Succeeded', 'ReadyToRun', 'Running')
      GROUP BY 
        deps_inner.id_instance,
        deps_inner.id_event,
        deps_inner.tx_name,
        deps_inner.id_arg_interval,
        deps_inner.dt_arg_start,
        deps_inner.dt_arg_end,
        deps_inner.tx_status,
        bg.tx_name
    ) deps
    INNER JOIN t_recevent evt ON evt.id_event = deps.EventID
    INNER JOIN t_recevent_inst orig_inst 
      ON orig_inst.id_instance = deps.OriginalInstanceID
    INNER JOIN t_recevent orig_evt ON orig_evt.id_event = orig_inst.id_event
    LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = lang_code AND evt.id_event=loc.id_item);

end CanExecuteEventDeps;
  
/