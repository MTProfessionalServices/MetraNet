
		if EXISTS (SELECT * FROM master..sysdatabases where name='%%DATABASE_NAME%%')
			select partition_name from %%%NETMETER_PREFIX%%%t_partition
		