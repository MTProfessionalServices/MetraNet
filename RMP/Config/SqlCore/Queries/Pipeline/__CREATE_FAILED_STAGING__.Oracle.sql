
begin
   if not table_exists ('%%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage') then
      exec_ddl('create table %%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage
          as select * from %%%NETMETER_PREFIX%%%t_failed_transaction where 0=1');

      exec_ddl('alter table %%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage 
          add constraint pk_t_failed_transaction_stage 
          primary key (id_failed_transaction)');  

   end if;
end;
			