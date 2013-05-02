
				BEGIN 
				  IF table_exists('%%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%') THEN
					  EXECUTE IMMEDIATE 'DROP TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%';
				  END IF;
				  EXECUTE IMMEDIATE 'CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%
          (
            id_request number(10) NOT NULL, 
            id_acc number(10) NOT NULL,
            acc_type NVARCHAR2(255) NOT NULL
          )';  
        END;
        