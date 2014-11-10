
	    CREATE OR REPLACE procedure sp_InsertCapabilityInstance
	    (aGuid VARCHAR2, aParentInstance int, aPolicy int, aCapType int,
	    ap_id_prop OUT int)
	    as
            begin
            	INSERT INTO t_capability_instance (id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type) 
            	VALUES (seq_t_cap_instance.nextval, 
            	HEXTORAW(aGuid), aParentInstance, aPolicy, aCapType);
            	select seq_t_cap_instance.CurrVal into ap_id_prop from dual;
		exception
			when others then
				select -99 into ap_id_prop from dual;
  	      end;
				