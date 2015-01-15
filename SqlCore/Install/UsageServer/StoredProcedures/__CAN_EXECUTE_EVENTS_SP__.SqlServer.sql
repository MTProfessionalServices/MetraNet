
CREATE PROCEDURE CanExecuteEvents(@dt_now DATETIME, @id_instances VARCHAR(4000), @lang_code INT = 840 )
AS

BEGIN
  BEGIN TRAN

  DECLARE @results TABLE
  (  
    id_instance INT NOT NULL,
    tx_display_name nvarchar(255),
    tx_reason VARCHAR(80)
  )

  --
  -- initially all instances are considered okay
  -- a succession of queries attempt to find a problem with executing them
  --

  -- builds up a table from the comma separated list of instance IDs
  INSERT INTO @results
  SELECT
    args.value,
    COALESCE(loc.tx_name, evt.tx_display_name) tx_display_name,
    'OK'
  FROM CSVToInt(@id_instances) args
  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.value
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_localized_items loc on (id_local_type = 1  /*Adapter type*/ AND id_lang_code = @lang_code AND evt.id_event=loc.id_item)

  -- is the event not active?
  UPDATE @results SET tx_reason = 'EventNotActive'
  FROM @results results
  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    -- event is NOT active
    evt.dt_activated > @dt_now AND
    (evt.dt_deactivated IS NOT NULL OR @dt_now >= evt.dt_deactivated) 

  -- is the instance in an invalid state?
  UPDATE @results SET tx_reason = inst.tx_status
  FROM @results results
  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
  WHERE 
    inst.tx_status NOT IN ('NotYetRun', 'ReadyToRun')

  -- is the interval hard closed?
  UPDATE @results SET tx_reason = 'HardClosed'
  FROM @results results
  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance
  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  WHERE 
    ui.tx_interval_status = 'H'

  SELECT 
    id_instance InstanceID,
    tx_display_name EventDisplayName,
    tx_reason Reason  
  FROM @results

  COMMIT
END
  