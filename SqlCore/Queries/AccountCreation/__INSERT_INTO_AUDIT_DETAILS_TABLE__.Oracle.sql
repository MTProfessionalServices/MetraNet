
			INSERT INTO %%%NETMETER%%%.%%TABLE_NAME%%(id_auditdetails,id_audit,tx_details)
			SELECT seq_t_audit_details.nextval,id_audit,tx_details FROM %%TMP_TABLE_NAME%%
			WHERE %%TMP_TABLE_NAME%%.tx_details IS NOT NULL AND %%TMP_TABLE_NAME%%.tx_details IS NOT NULL
			