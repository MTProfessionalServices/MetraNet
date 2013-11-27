
		begin
		  if not table_exists('%%TABLE_NAME%%') then
			execute immediate 'create table %%TABLE_NAME%% (
						  id_request number(10),
						  id_acc number(10),
						  acc_cycle_id number(10),
						  default_pl number(10),
						  RecordDate date,
						  id_pi_template number(10),
						  id_sub number(10))';
			end if;
		end;
  		