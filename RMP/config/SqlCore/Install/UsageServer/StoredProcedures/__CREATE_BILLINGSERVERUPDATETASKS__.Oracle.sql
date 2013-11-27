
        CREATE OR REPLACE PROCEDURE BillingServerUpdateTasks
        (
        p_tx_machine IN t_billingserver.tx_machine%TYPE,   
        p_canCreateScheduledEvents IN char,
        p_canCreateIntervals IN char,
        p_canSoftCloseIntervals IN char,
        p_willCreateScheduledEvents OUT char ,
        p_willCreateIntervals OUT char ,
        p_willSoftCloseIntervals OUT char ,
        p_status         OUT number
        )
IS
        BEGIN              
        
         p_willCreateScheduledEvents := 'N';
         p_willCreateIntervals := 'N';
         p_willSoftCloseIntervals := 'N';
         
         /*Lock the table for exclusive write access; others can query it */
         LOCK TABLE t_billingserver IN EXCLUSIVE MODE;
         
         /* Update our entries for the specified machine */
         update t_billingserver 
         set
           b_CanCreateScheduledEvents = p_canCreateScheduledEvents,
           b_CanCreateIntervals = p_canCreateIntervals,
           b_CanSoftCloseIntervals = p_canSoftCloseIntervals,
          /* p_willCreateScheduledEvents = CASE
               WHEN (select COUNT(*) from t_billingserver where b_WillCreateScheduledEvents ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canCreateScheduledEvents = 'Y') THEN 'Y'
               ELSE 'N'
             END,
           p_willCreateIntervals = CASE 
               WHEN (select COUNT(*) from t_billingserver where b_WillCreateIntervals ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canCreateIntervals = 'Y') THEN 'Y'
               ELSE 'N'
             END,
           p_willSoftCloseIntervals = CASE
               WHEN (select COUNT(*) from t_billingserver where b_WillSoftCloseIntervals ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canSoftCloseIntervals = 'Y') THEN 'Y'
               ELSE 'N'
             END,*/
           b_WillCreateScheduledEvents = CASE WHEN ((select COUNT(*) from t_billingserver where b_WillCreateScheduledEvents ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canCreateScheduledEvents = 'Y')) THEN 'Y' ELSE 'N' END,
           b_WillCreateIntervals = CASE WHEN ((select COUNT(*) from t_billingserver where b_WillCreateIntervals ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canCreateIntervals = 'Y')) THEN 'Y' ELSE 'N'  END,
           b_WillSoftCloseIntervals =  CASE WHEN ((select COUNT(*) from t_billingserver where b_WillSoftCloseIntervals ='Y' and b_online = 'Y' and tx_machine not like p_tx_machine) = 0 AND (p_canSoftCloseIntervals = 'Y')) THEN 'Y' ELSE 'N'  END
         where tx_machine like p_tx_machine;
                  
         IF (sql%rowcount = 0) THEN
           p_status := -1; /*Machine entry was not found*/
           return;
         END IF;      
         
         /*Read back and return if this server should be performing various actions */
         select
           b_WillCreateScheduledEvents, b_WillCreateIntervals, b_WillSoftCloseIntervals
           into
           p_willCreateScheduledEvents, p_willCreateIntervals, p_willSoftCloseIntervals
         from t_billingserver
         where tx_machine like p_tx_machine;
          
         p_status := 0;
        END;
  