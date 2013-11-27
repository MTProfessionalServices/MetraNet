
create or replace procedure upsertaccounttypeservicedefmap (
	p_accounttype number, 
	p_operation nvarchar2, 
	p_servicedefname nvarchar2
)
as
	serviceid number;
	opid number;
begin

	InsertEnumData(p_operation, opid);
	InsertEnumData(p_servicedefname, serviceid);

	update t_account_type_servicedef_map set 
		id_service_def = serviceid
		where id_type = p_accounttype
		  and operation = opid;
		
	if (SQL%ROWCOUNT = 0) then

		insert into t_account_type_servicedef_map 
			(id_type, operation, id_service_def) 
		values 
			(p_accounttype, opid, serviceid);

	end if;
	
end;
			