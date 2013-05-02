
		BEGIN
			declare @dbid as int
			select @dbid = dbid FROM master..sysdatabases sdb
			inner join %%%NETMETER_PREFIX%%%t_partition pp
			on sdb.name = pp.partition_name
			where pp.b_default='Y' OR pp.b_default='y'
			if (@dbid IS NULL)
			begin
				raiserror('Default partition database was not created', 16, 1)
				return
			end
			
			declare @DatabaseExpected as int
			declare @DatabaseActual as int
			declare @DatabaseCreated as int
			
			/* We check db status incase some db is left in a weird state. */
			select @DatabaseActual = COUNT(*) FROM master..sysdatabases where name like 'N[_]%' and status = 16 
			select @DatabaseExpected = COUNT(*) FROM %%%NETMETER_PREFIX%%%t_partition
			select @DatabaseCreated = COUNT(*) FROM master..sysdatabases where name in (select partition_name from %%%NETMETER_PREFIX%%%t_partition)
			if (@DatabaseActual > @DatabaseExpected)
			begin
				raiserror('There are more partition databases (%d) than expected (%d)', 16, 1, @DatabaseActual, @DatabaseExpected)
				return
			end
			else if (@DatabaseActual < @DatabaseExpected)
			begin 
				raiserror('There are less partition databases (%d) than expected (%d)', 16, 1, @DatabaseActual, @DatabaseExpected)
				return
			end

			if (@DatabaseCreated != @DatabaseExpected)
			begin
				raiserror('The number of created partition databases (%d) does not match expected number of databases (%d)', 16, 1, @DatabaseCreated, @DatabaseExpected)
				return
			end
		END
		