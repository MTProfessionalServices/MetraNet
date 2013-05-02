
if object_id('%%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage') is null 
begin
	select * into %%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage 
		from %%%NETMETER_PREFIX%%%t_failed_transaction
		where 0=1

	alter table %%%NETMETERSTAGE_PREFIX%%%t_failed_transaction_stage
		add constraint pk_t_failed_transaction_stage
		primary key clustered (id_failed_transaction)
end
				