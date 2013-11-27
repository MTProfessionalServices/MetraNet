
	begin
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_audiocall') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_audiocall (
		id_acc number(10),
		amount numeric(22,10),
		c_actualduration numeric(22,10),
		c_bridgeamount numeric(22,10),
		c_setupcharge numeric(22,10),
		numtransactions number(10)
		)');
	end if;

	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_audiocall (	
		id_acc number(10),
		amount numeric(22,10),
		c_actualduration numeric(22,10),
		c_bridgeamount numeric(22,10),
		c_setupcharge numeric(22,10),
		numtransactions number(10)
		)');
	end if;
	
	end;
			