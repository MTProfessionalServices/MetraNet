
	begin
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_fashionsale') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_fashionsale 
		(
		id_acc number(10),
		id_usage_interval number(10),
		taxes number(22,10),
		c_totalprice number(22,10),
		numtransactions number(10)
		)');
	end if;
	
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale') then
  exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_fashionsale (
		id_acc number(10),
		id_usage_interval number(10),
		taxes number(22,10),
		c_totalprice number(22,10),
		numtransactions number(10)
		)');
	end if;

	end;
		