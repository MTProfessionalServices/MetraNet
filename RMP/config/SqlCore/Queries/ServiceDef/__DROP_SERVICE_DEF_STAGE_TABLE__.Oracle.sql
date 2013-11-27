
			DECLARE 
				pragma autonomous_transaction;
				tabexists BOOLEAN;
				tabexistsNumber NUMBER;

			BEGIN
				SELECT COUNT(1) INTO tabexistsNumber FROM user_tables WHERE table_name = UPPER('%%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%');
				IF (tabexistsNumber > 0) THEN
					tabexists := TRUE;
				ELSE
					SELECT COUNT (1) INTO tabexistsNumber FROM all_tables
						WHERE owner = UPPER(TRIM(SUBSTR ('%%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%',
												 1,
												 INSTR ('%%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%','.')-1
												)))
						and table_name = UPPER (TRIM(SUBSTR ('%%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%',
												 INSTR ('%%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%','.')+1
												)));												
					tabexists :=     (tabexistsNumber > 0);                          
				END IF;
				
				IF (tabexists) THEN
						execute immediate 'drop table %%%NETMETERSTAGE_PREFIX%%%%%SDEF_NAME%%';
				END IF;
			END;			
		