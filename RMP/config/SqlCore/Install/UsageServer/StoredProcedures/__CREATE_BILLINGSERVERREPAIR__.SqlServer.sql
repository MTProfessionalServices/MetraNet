
CREATE PROCEDURE BillingServerRepair
 @dt_now DATETIME,
 @tx_machine nvarchar(128),
 @status int OUTPUT
AS
BEGIN
  /* Used to clean up entries in t_billingserver and t_billingserver_service tables for a particular machine */
  /* Most likely caused by crash or faulty shutdown, there are 'running' entries that are no longer running  */
  /* Pattern is for Start to alert the caller when this happens and caller can decide to exit/abort or call  */
  /* repair and then start again if they are sure they are the only server using the identifier. */
  
  /* Set all servers using the identifier to offline */
  select @status =0
      update t_billingserver 
			set 
			  b_online = 'N'
			where
			tx_machine = @tx_machine
			and b_online = 'Y'

	  
	/* Fix any service entries listed as running by ending them */
	update t_billingserver_service 
	  set tt_end = dateadd(s, -1, @dt_now)
	where id_billingserver in (select id_billingserver from t_billingserver where tx_machine like @tx_machine)
	  and tt_end is null
		
END			
  