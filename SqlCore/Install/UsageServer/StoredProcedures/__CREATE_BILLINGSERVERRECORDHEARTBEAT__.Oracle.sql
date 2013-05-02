
          
CREATE OR REPLACE PROCEDURE BillingServerRecordHeartbeat
(
 p_tx_machine IN t_billingserver.tx_machine%TYPE,   
 p_SecondsToNextPromised IN number, 
 p_status OUT number
)
IS

v_Now Date;
v_NextPromisedHeartBeat Date;

BEGIN
  
  /* Updates that a heartbeat was received and when the next expeted heartbeat is */
  /* If the next expected heartbeat time (SecondsToNextPromised) is 0, then intent
  is that heartbeat checking should be turned off for this service. */
  /* Note that this stored procedure and checking queries intentially use the time
  from the database server to avoid differences in time between the various servers.
  For this reason, the actual date time is used only for comparison between what was promised
  and not be used as an actual date time for other decisions by the service or for display;
  only a comparison should be used. */
  
   p_status :=0;
   
   select SYSDATE into v_Now from dual;
   if (p_SecondsToNextPromised = 0) THEN
     v_NextPromisedHeartBeat := NULL;
   else
     v_NextPromisedHeartBeat := v_Now + ( p_SecondsToNextPromised /(24*60*60));
   end if;
       

    update t_billingserver_service
    set tt_lastheartbeat = v_Now,
    tt_nextheartbeatpromised = v_NextPromisedHeartBeat
    where id_billingserver in (select id_billingserver from t_billingserver where tx_machine like p_tx_machine)
    and tt_end is null;
    
END;          
  