
      /*
      	Returns 1 if the system is enabled for partitioning.
      */
      
      create function IsSystemPartitioned ()
      returns int
      as
      begin
      
      	if exists (select b_partitioning_enabled from t_usage_server 
      						where b_partitioning_enabled = 'Y')
      		return 1
      
      	return 0
      end
      
 	