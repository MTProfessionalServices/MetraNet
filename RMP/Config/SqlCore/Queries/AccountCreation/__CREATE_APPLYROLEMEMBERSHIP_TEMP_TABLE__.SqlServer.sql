
        IF OBJECT_ID('%%TMP_TABLE_NAME%%') IS NOT NULL DROP TABLE %%TMP_TABLE_NAME%%
        CREATE TABLE %%TMP_TABLE_NAME%%
        (
			    id_request INT NOT NULL, 
					id_acc INT NOT NULL,
					acc_type nvarchar(40) NOT NULL
		    )
			