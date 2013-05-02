
		CREATE PROCEDURE AdapterConcurrencyFinalize          
		(
		  @status INT OUTPUT
		)
		AS               
		  BEGIN 
		  /* Insert all the complementary rules (i.e. if AdapterA can run with AdapterB, then AdapterB can run with AdapterA) */
		  insert into t_recevent_concurrent (tx_eventname, tx_compatible_eventname)
			 (
			 select evt_con.tx_compatible_eventname as Event,
			   evt_con.tx_eventname CompatibleEvent
			   from t_recevent_concurrent evt_con
			   where (select COUNT(*) from t_recevent_concurrent evt_con2 where evt_con2.tx_eventname=evt_con.tx_compatible_eventname and evt_con2.tx_compatible_eventname = evt_con.tx_eventname) = 0
			) 

		  set @status = 0;
		  END
  