
		CREATE PROCEDURE BillingServerUpdateTasks
		@tx_machine VARCHAR(128),   
		@canCreateScheduledEvents char(1),
		@canCreateIntervals char(1),
		@canSoftCloseIntervals char(1),
		@willCreateScheduledEvents char(1) OUTPUT,
		@willCreateIntervals char(1) OUTPUT,
		@willSoftCloseIntervals char(1) OUTPUT,
        @status INT OUTPUT
		  AS              
		BEGIN              
        
         set @willCreateScheduledEvents = 'N';
		 set @willCreateIntervals = 'N';
		 set @willSoftCloseIntervals = 'N';
		  
         update t_billingserver 
         set
           b_CanCreateScheduledEvents = @canCreateScheduledEvents,
           b_CanCreateIntervals = @canCreateIntervals,
           b_CanSoftCloseIntervals = @canSoftCloseIntervals,
           @willCreateScheduledEvents = CASE
               WHEN (select COUNT(*) from t_billingserver where b_WillCreateScheduledEvents ='Y' and b_online = 'Y' and tx_machine not like @tx_machine) = 0 AND (@canCreateScheduledEvents = 'Y') THEN 'Y'
			   ELSE 'N'
			 END,
		   @willCreateIntervals = CASE 
			   WHEN (select COUNT(*) from t_billingserver where b_WillCreateIntervals ='Y' and b_online = 'Y' and tx_machine not like @tx_machine) = 0 AND (@canCreateIntervals = 'Y') THEN 'Y'
			   ELSE 'N'
			 END,
           @willSoftCloseIntervals = CASE
               WHEN (select COUNT(*) from t_billingserver where b_WillSoftCloseIntervals ='Y' and b_online = 'Y' and tx_machine not like @tx_machine) = 0 AND (@canSoftCloseIntervals = 'Y') THEN 'Y'
		       ELSE 'N'
			 END,
		   b_WillCreateScheduledEvents = @willCreateScheduledEvents,
		   b_WillCreateIntervals = @willCreateIntervals,
		   b_WillSoftCloseIntervals = @willSoftCloseIntervals
         where tx_machine like @tx_machine
		 
		 if (@@ROWCOUNT = 0)
		 BEGIN
		   set @status = -1; /*Machine entry was not found*/
		   return
		 END	  
		 
		 set @status = 0;
		END
  