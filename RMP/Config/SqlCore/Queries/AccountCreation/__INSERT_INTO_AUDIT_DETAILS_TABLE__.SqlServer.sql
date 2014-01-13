
			INSERT INTO %%%NETMETER%%%..%%TABLE_NAME%%(id_audit,tx_details)
			SELECT id_audit,tx_details FROM %%TMP_TABLE_NAME%% WITH(READCOMMITTED)
			WHERE %%TMP_TABLE_NAME%%.tx_details IS NOT NULL AND %%TMP_TABLE_NAME%%.tx_details != ''
			