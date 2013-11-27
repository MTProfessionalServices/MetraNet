				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='T_PC_INTERVAL'
				and a.id=c.constid
				and b.id=c.id
				select @stmt = N'alter table T_PC_INTERVAL drop constraint ' + @name
				exec sp_executesql @stmt
go
				DECLARE @name varchar(1000)
				declare @stmt nvarchar(2000)
				select  
				@name = ctu.CONSTRAINT_NAME 
				from information_schema.referential_constraints rc
				inner join information_schema.constraint_table_usage ctu
				on ctu.constraint_catalog = rc.constraint_catalog
				and ctu.constraint_schema = rc.constraint_schema
				and ctu.constraint_name = rc.constraint_name
				inner join information_schema.table_constraints tc
				on tc.constraint_catalog = rc.unique_constraint_catalog
				and tc.constraint_schema = rc.unique_constraint_schema
				and tc.constraint_name = rc.unique_constraint_name
				inner join information_schema.constraint_column_usage ccu
				on ctu.constraint_catalog = ccu.constraint_catalog
				and ctu.constraint_schema = ccu.constraint_schema
				and ctu.constraint_name = ccu.constraint_name
				where tc.TABLE_NAME = 'T_USAGE_CYCLE'
				and ctu.table_name='T_PC_INTERVAL'
				select @stmt = N'alter table t_pc_interval drop constraint ' + @name
				exec sp_executesql @stmt
go
        CREATE TABLE t_pc_interval_temp (id_interval int NOT NULL,
			  id_cycle int NOT NULL,
			  dt_start datetime NOT NULL,
			  dt_end datetime NOT NULL, 
			  CONSTRAINT PK_t_pc_interval 
			  PRIMARY KEY CLUSTERED (id_interval),
			  CONSTRAINT FK_t_pc_interval_cycle FOREIGN KEY (id_cycle)
        REFERENCES t_usage_cycle(id_usage_cycle)) 
go
				insert into t_pc_interval_temp select * from t_pc_interval
go
				drop table t_pc_interval
				exec sp_rename 't_pc_interval_temp','t_pc_interval'
		    CREATE INDEX cycle_pc_interval_index on t_pc_interval (id_cycle)
		    CREATE INDEX time_pc_interval_index  on t_pc_interval (dt_start, dt_end)
go


