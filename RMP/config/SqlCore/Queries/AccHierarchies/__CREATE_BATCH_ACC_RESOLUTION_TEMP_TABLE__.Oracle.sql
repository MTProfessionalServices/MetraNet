
	 BEGIN 
        IF table_exists('%%TMP_TABLE_NAME%%') THEN
            EXECUTE IMMEDIATE 'DROP TABLE %%TMP_TABLE_NAME%%';
        END IF;
        EXECUTE IMMEDIATE 'CREATE TABLE %%TMP_TABLE_NAME%% 
            (id_request number(10) NOT NULL,
            nm_login nvarchar2(256) NULL,
            nm_space nvarchar2(256) NULL,
            id_acc number(10) NULL, 
            restime date NOT NULL) %%ADDITIONAL_KEYS%%' ;
	END;
