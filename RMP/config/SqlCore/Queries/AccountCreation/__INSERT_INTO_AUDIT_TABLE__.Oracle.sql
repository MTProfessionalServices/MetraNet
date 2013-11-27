
			INSERT INTO %%%NETMETER%%%.%%TABLE_NAME%%(id_audit,id_event,id_userid,id_entitytype,id_entity,dt_crt)
			SELECT id_audit,id_event,id_userid,id_entitytype,id_entity,dt_crt FROM %%TMP_TABLE_NAME%%
			