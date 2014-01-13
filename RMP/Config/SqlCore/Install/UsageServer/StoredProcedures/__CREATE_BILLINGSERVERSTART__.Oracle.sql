
CREATE OR REPLACE PROCEDURE BillingServerStart
( p_dt_now IN DATE,
 p_tx_machine IN t_billingserver.tx_machine%TYPE,
 p_id_server OUT t_billingserver.ID_BILLINGSERVER%TYPE,
 p_id_service OUT number,
 p_status         OUT number
)
IS
v_totalrunning number(10);
BEGIN
  /* Used to upsert records indicating a particular billing server is starting or coming online. */
  /* Will return errors in status if there was an incomplete shutdown or crash previously. */
  /* Caller can choose to repair and call start again or abort */
  select COUNT(*) into v_totalrunning from t_billingserver where tx_machine=p_tx_machine and b_online = 'Y';
    if v_totalrunning > 0 THEN
      p_status := -1;  /* Server is already started with this machine id; alert the caller and assume they will call cleanup if they want to try again */
      return;
      END IF;
    
    /* Attempt updating the machine */    
    update t_billingserver 
        set 
          b_online = 'Y'
        where
        tx_machine = p_tx_machine;

    if (sql%rowcount  =  0) THEN
      insert into t_billingserver(id_billingserver, tx_machine, b_online, b_paused) values (seq_t_billingserver.nextval, p_tx_machine, 'Y', 'N'); /* Machine didn't exist so insert a row for it */
     END IF;
     
    select id_billingserver into p_id_server from t_billingserver where tx_machine=p_tx_machine;
            
    /*Fix any services listed as running by ending them*/
    update t_billingserver_service 
      set tt_end = dbo.SubtractSecond(p_dt_now)
    where id_billingserver=p_id_server and tt_end is null;
    
    /*Insert our new entry in the services table*/
    select seq_t_billingserver_service.nextval into p_id_service from dual;
    
    insert into t_billingserver_service (id_svc, id_billingserver, tt_start, tt_end)
    values (p_id_service, p_id_server, p_dt_now, null);
    
    /* p_id_service := @@IDENTITY;*/
    
    p_status := 0;
END;
  