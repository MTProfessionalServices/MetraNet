
		create or replace procedure sp_InsertAtomicCapType 
		(aGuid RAW, aName NVARCHAR2, aDesc NVARCHAR2, aProgid NVARCHAR2, aEditor NVARCHAR2,
		ap_id_prop OUT int)
		as
		begin
            	INSERT INTO t_atomic_capability_type(ID_CAP_TYPE, tx_guid,tx_name,tx_desc,tx_progid,tx_editor) VALUES ( 
            	seq_t_atomic_capability_type.nextval, aGuid, aName, aDesc, aProgid, aEditor);
            	select seq_t_atomic_capability_type.CurrVal into ap_id_prop from dual;
	    end;
				