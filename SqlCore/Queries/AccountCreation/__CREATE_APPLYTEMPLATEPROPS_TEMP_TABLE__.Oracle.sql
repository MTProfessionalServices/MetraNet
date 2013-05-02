
      BEGIN 
				IF table_exists('%%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%') THEN
					EXECUTE IMMEDIATE 'DROP TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%';
				END IF;
				EXECUTE IMMEDIATE 'CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%
                  ( id_request number(10) NOT NULL, 
                  n_operation number(10) NOT NULL,
                  dt_account_start DATE NULL, 
                  dt_hierarchy_start DATE NULL,
                  nm_ancestor_name NVARCHAR2(255), 
                  nm_ancestor_name_space NVARCHAR2(255), 
                  id_ancestor NUMBER(10) NULL, 
                  id_old_ancestor NUMBER(10) NULL, 
                  id_acc_type NUMBER(10) NOT NULL
              )';  
			END;
 		