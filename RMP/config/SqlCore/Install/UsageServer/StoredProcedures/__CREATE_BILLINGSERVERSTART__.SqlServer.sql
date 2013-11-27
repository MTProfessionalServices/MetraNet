
CREATE PROCEDURE BillingServerStart
 @dt_now DATETIME,
 @tx_machine nvarchar(128),
 @id_server int OUTPUT,
 @id_service int OUTPUT,
 @status int OUTPUT 
AS
BEGIN
  /* Used to upsert records indicating a particular billing server is starting or coming online. */
  /* Will return errors in status if there was an incomplete shutdown or crash previously. */
  /* Caller can choose to repair and call start again or abort */
	if (select COUNT(*) from t_billingserver where tx_machine=@tx_machine and b_online = 'Y') > 0
	  BEGIN
	  select @status = -1  /* Server is already started with this machine id; alert the caller and assume they will call cleanup if they want to try again */
	  return
	  END
	
    /* Attempt updating the machine */	
	update t_billingserver 
		set 
		  b_online = 'Y'
		where
		tx_machine = @tx_machine

	if (@@ROWCOUNT = 0)
	  insert into t_billingserver(tx_machine, b_online, b_paused) values (@tx_machine, 'Y', 'N') /* Machine didn't exist so insert a row for it */

	select @id_server=id_billingserver from t_billingserver where tx_machine=@tx_machine
			
	/*Fix any services listed as running by ending them*/
	update t_billingserver_service 
	  set tt_end = dateadd(s, -1, @dt_now)
	where id_billingserver=@id_server and tt_end is null
	
	/*Insert our new entry in the services table*/
	insert into t_billingserver_service (id_billingserver, tt_start, tt_end)
	values (@id_server, @dt_now, null)
	
	select @id_service = @@IDENTITY
	
	select @status = 0	
END
  