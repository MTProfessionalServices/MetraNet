
CREATE PROCEDURE BillingServerRecordHeartbeat
 @tx_machine nvarchar(128),
 @SecondsToNextPromised int, 
 @status int OUTPUT 
AS
BEGIN
  /* Updates that a heartbeat was received and when the next expeted heartbeat is */
  /* If the next expected heartbeat time (SecondsToNextPromised) is 0, then intent
  is that heartbeat checking should be turned off for this service. */
  /* Note that this stored procedure and checking queries intentially use the time
  from the database server to avoid differences in time between the various servers.
  For this reason, the actual date time is used only for comparison between what was promised
  and not be used as an actual date time for other decisions by the service or for display;
  only a comparison should be used. */
  
  declare @Now as datetime
  declare @NextPromisedHeartBeat as datetime
  
  set @Now = GETDATE()

  if (@SecondsToNextPromised = 0)
	  set @NextPromisedHeartBeat = null
  else
	  set @NextPromisedHeartBeat = DateAdd(second,@SecondsToNextPromised,@Now);

  update t_billingserver_service
    set tt_lastheartbeat = @Now,
    tt_nextheartbeatpromised = @NextPromisedHeartBeat
    where id_billingserver in (select id_billingserver from t_billingserver where tx_machine like @tx_machine)
    and tt_end is null;	

  if (@@ROWCOUNT = 0)
    set @status = -1; /*Machine entry was not found*/
  else
    set @status = 0;
  
END
  