
		CREATE PROCEDURE AdapterConcurrencyInitialize 
		(
		  @status INT OUTPUT
		)
		AS  
		  BEGIN 
		  delete from t_recevent_concurrent;
		  set @status = 0;
		  END
  