
        IF OBJECT_ID('%%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%') IS NOT NULL DROP TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%
        CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%%%TMP_TABLE_NAME%%
        (
			    id_request INT NOT NULL, 
			    n_operation INT NOT NULL,
			    dt_account_start datetime NULL,
			    dt_hierarchy_start datetime NULL,
			    nm_ancestor_name NVARCHAR(255), 
			    nm_ancestor_name_space NVARCHAR(255), 
			    id_ancestor INT NULL, 
			    id_old_ancestor INT NULL, 
			    id_acc_type int NOT NULL
		    )
			