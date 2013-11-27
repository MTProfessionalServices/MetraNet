
CREATE PROCEDURE BillingServerStop
 @dt_now DATETIME,
 @tx_machine nvarchar(128),
 @status int OUTPUT
AS
BEGIN
  /* Used to indicate that a particular billing server is stopping or going off-line */
  select @status =0
      update t_billingserver 
			set 
			  b_online = 'N'
			where
			tx_machine = @tx_machine
			and b_online = 'Y'

			if (@@ROWCOUNT = 0)
			  BEGIN
			  set @status = -1; /* The start/stop are out of sync as we could not find an entry for the named server */
			  /*continue to clean up and mark the service as off line anyway*/
			  update t_billingserver 
					set 
					  b_online = 'N'
					where
					tx_machine = @tx_machine
			  END

			/* Should be only one service but and any for this server that are running */
			update t_billingserver_service 
			  set tt_end = dateadd(s, -1, @dt_now)
			where id_billingserver in (select id_billingserver from t_billingserver where tx_machine like @tx_machine)
			  and tt_end is null
			  
			if (@@ROWCOUNT != 1)
			  BEGIN
			  set @status = -2; /* The start/stop are out of sync on the services table */
			  return
			  END
			 
			
END
  