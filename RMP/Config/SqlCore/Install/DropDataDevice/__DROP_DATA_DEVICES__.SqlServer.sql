
			 	IF EXISTS (SELECT * FROM sysdevices where name =
				'%%DATA_DEVICE_NAME%%') EXEC sp_dropdevice
				%%DATA_DEVICE_NAME%%, DELFILE
			