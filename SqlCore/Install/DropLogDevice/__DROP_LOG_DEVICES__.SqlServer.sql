
				IF EXISTS (SELECT * FROM sysdevices where name =
				'%%LOG_DEVICE_NAME%%') EXEC sp_dropdevice %%LOG_DEVICE_NAME%%,
				DELFILE
			