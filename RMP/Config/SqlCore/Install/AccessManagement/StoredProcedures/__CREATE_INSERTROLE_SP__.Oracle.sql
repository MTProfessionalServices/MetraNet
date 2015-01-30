
	create or replace procedure sp_InsertRole(aGuid RAW, aName NVARCHAR2, aDesc NVARCHAR2,
						aCSRAssignable VARCHAR2, aSubAssignable VARCHAR2, ap_id_prop OUT int)
        as
        begin
	        INSERT INTO t_role (id_role, tx_guid, tx_name, tx_desc, csr_assignable, subscriber_assignable) VALUES (seq_t_role.nextval, 
	        aGuid, aName, aDesc, aCSRAssignable, aSubAssignable);
	        select seq_t_role.CurrVal into ap_id_prop from dual;
	        exception
		        when others then
		        select -99 into ap_id_prop from dual;
        END;
        