
				create or replace procedure DeleteDescription(
				a_id_desc t_description.id_desc%type)
				as
				BEGIN
					IF a_id_desc <> 0
					THEN
					delete from t_description where id_desc=a_id_desc;
					delete from t_mt_id where id_mt=a_id_desc;
	     		END IF;
				END;
		