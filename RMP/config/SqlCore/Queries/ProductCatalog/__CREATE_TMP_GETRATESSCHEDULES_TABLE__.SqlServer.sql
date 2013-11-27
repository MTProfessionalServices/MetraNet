
		begin
			if OBJECT_ID('%%TABLE_NAME%%') is null 
				create table %%TABLE_NAME%% (id_request int, id_acc int, acc_cycle_id int, default_pl int,
											 RecordDate datetime, id_pi_template int, id_sub int);
										  
			if NOT EXISTS (select * from %%%NETMETERSTAGE_PREFIX%%%sysindexes where id=OBJECT_ID('%%TABLE_NAME%%')
									    and name = '%%INDEX_NAME%%')
				create index %%INDEX_NAME%% on %%TABLE_NAME%%(id_pi_template);
		end							  
  		