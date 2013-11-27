
	begin
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_songdownloads') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_songdownloads (
			id_acc number(10),
			id_usage_interval number(10),
			amount numeric(22,10),
			c_totalsongs numeric(22,10),
			c_totalbytes numeric(22,10),
			numtransactions number(10)
		)');
	end if;
	
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_songdownloads (
			id_acc number(10),
			id_usage_interval number(10),      
			amount numeric(22,10),
			c_totalsongs numeric(22,10),
			c_totalbytes numeric(22,10),
			numtransactions number(10)
		)');
	end if;
	
	end;
			