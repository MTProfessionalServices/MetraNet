
					create or replace procedure sp_InsertCompositeCapType 
						(aGuid RAW, aName VARCHAR2, aDesc VARCHAR2, aProgid VARCHAR2, aEditor VARCHAR2,
						aCSRAssignable VARCHAR2, aSubAssignable VARCHAR2, aMultipleInstances VARCHAR2,  aUmbrellaSensitive VARCHAR2, ap_id_prop OUT int)
						as
            begin
            	INSERT INTO t_composite_capability_type VALUES (seq_t_cct.nextval, 
            	aGuid, aName, aDesc, aProgid, aEditor, aCSRAssignable, aSubAssignable, aMultipleinstances, aUmbrellaSensitive);
							select seq_t_cct.CurrVal into ap_id_prop from dual;
  					END;
				