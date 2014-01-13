
/* ===========================================================
Returns a list of events that are compatible with currently running 
events. This is either all events if nothing is running or the 
list of events compatible with currently running events
=========================================================== */
CREATE FUNCTION GetCompatibleConcurrentEvents()
RETURNS @compatibleEvents TABLE
(
  tx_compatible_eventname nvarchar(255) NOT NULL 
)
AS
BEGIN

insert @compatibleEvents
/* All internal events */
select distinct evt.tx_name from t_recevent evt
where evt.tx_type = 'Root'
union
(
/* All unique event names when there are no running adapters (no conflicts) */
select distinct evt.tx_name from t_recevent evt
where evt.tx_type not in ('Checkpoint','Root')
/* Intentionally not checking against active events to make sure we don't
skip any older events that do not have rules or have been deactivated but still have instances */
and ((select COUNT(*) from t_recevent_run evt_run2 WHERE tx_status = 'InProgress') = 0)
)
union
(
  /* List of events compatible with currently running events */
	select tx_compatible_eventname
	from (
		  SELECT
				evt2.tx_name
		  FROM t_recevent_run evt_run
		  INNER JOIN t_recevent_inst evt_inst2 ON evt_inst2.id_instance = evt_run.id_instance
		  INNER JOIN t_recevent evt2 ON evt2.id_event = evt_inst2.id_event
		  WHERE evt_run.tx_status = 'InProgress'
		  GROUP BY evt2.tx_name, evt2.id_event
	) r inner join t_recevent_concurrent c on r.tx_name = c.tx_eventname
	group by tx_compatible_eventname
	having COUNT(*) = (select COUNT(*) 
					   from (select id_run 
							 from t_recevent_run evt_run 
							 where evt_run.tx_status = 'InProgress' 
							 group by id_run) d
					  )
)

  RETURN
END
