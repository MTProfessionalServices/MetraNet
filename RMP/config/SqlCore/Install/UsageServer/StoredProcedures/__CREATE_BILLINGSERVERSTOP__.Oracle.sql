
CREATE PROCEDURE BillingServerStop
(
 p_dt_now DATE,
 p_tx_machine IN t_billingserver.tx_machine%TYPE,   
 p_status OUT number
)
IS
BEGIN
  /* Used to indicate that a particular billing server is stopping or going off-line */
  p_status:= 0;
  
  update t_billingserver 
        set 
          b_online = 'N'
        where
        tx_machine = p_tx_machine
        and b_online = 'Y';

   IF (sql%rowcount = 0) THEN
      p_status := -1; /* The start/stop are out of sync as we could not find an entry for the named server */
      /*continue to clean up and mark the service as off line anyway*/
      update t_billingserver 
            set 
              b_online = 'N'
            where
            tx_machine = p_tx_machine;
      END IF;

    /* Should be only one service but and any for this server that are running */
    update t_billingserver_service 
      set tt_end = dbo.SubtractSecond(p_dt_now)
    where id_billingserver in (select id_billingserver from t_billingserver where tx_machine like p_tx_machine)
      and tt_end is null;
              
   IF (sql%rowcount = 0) THEN
      p_status := -2; /* The start/stop are out of sync on the services table */
      return;
      END IF;
             
            
END;
  