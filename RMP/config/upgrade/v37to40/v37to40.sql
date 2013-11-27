				set nocount on
				go
				INSERT INTO t_sys_upgrade
				(target_db_version, dt_start_db_upgrade, db_upgrade_status)
				VALUES
				(4.0, getdate(), 'R')
				go
				set nocount on
				declare @su int
				select @su=id_acc from t_account_mapper where nm_login = 'su'
				declare @id_identity int
				declare @id_entity int
				declare @var1 nvarchar(2000)
				declare @time datetime
				set @time = getdate()
				declare c1 cursor for select table_name from information_schema.tables
				where table_name like 't_pt%'
				and table_type = 'BASE TABLE'
				open c1
				fetch next from c1 into @var1
				while (@@fetch_status = 0)
				begin
					select @id_entity = id_prop from t_base_props where reverse(substring(reverse(nm_name),1,charindex('/',reverse(nm_name))-1)) = substring(@var1,6,len(@var1))
					and nm_name like 'metratech.com/%'
					exec ('alter table ' + @var1 + ' add tt_start datetime null, tt_end datetime null,id_audit int null')
					exec insertauditevent @su,1402,2,@id_entity,@time,'Update of table information during upgrade',@id_identity=@id_identity output				
					exec ('update ' + @var1 + ' set tt_start = dbo.mtmindate(),tt_end=dbo.mtmaxdate(),id_audit=' + @id_identity)
					exec ('alter table ' + @var1 + ' alter column tt_start datetime not null')
					exec ('alter table ' + @var1 + ' alter column tt_end datetime not null')
					exec ('alter table ' + @var1 + ' alter column id_audit int not null')
					declare @name varchar(1000)
					declare @stmt nvarchar(2000) 
					select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
					where a.xtype='PK'
					and b.xtype='U'
					and b.name=@var1
					and a.id=c.constid
					and b.id=c.id
					select @stmt = N'alter table ' + @var1 + ' drop constraint ' + @name
					exec sp_executesql @stmt
					select @stmt = N'alter table ' + @var1 + ' add constraint pk_' + @var1 + ' primary key (id_sched, n_order, id_audit)'
					exec sp_executesql @stmt	
				fetch next from c1 into @var1
				end
				close c1
				deallocate c1
				go
				insert into t_current_id values (1000, 'id_dbqueue')
				insert into t_current_id values (1000, 'id_dbqueuess')
				insert into t_current_id values (1000, 'id_dbqueuesch')
				insert into t_current_id values (1000, 'id_dbqueuebatch')
				insert into t_current_id select isnull(max(id_sub),999) + 1, 'id_subscription' from t_sub
				go
				declare @audit int
				select @audit = max(id_audit)+1 from t_audit
				insert into t_current_id values (@audit, 'id_audit')
				go
				declare @profile int
				select @profile = max(id_profile)+1 from t_profile
				update t_current_id set id_current = @profile
				where nm_current = 'id_profile'
				go
				create table t_acc_bucket_map 
				(id_usage_interval int not null,
				id_acc int not null,
				bucket int not null,
				status char(1) not null,
				tt_start datetime not null, 
				tt_end datetime not null)
				create clustered index idx_acc_bucket_map on t_acc_bucket_map(bucket)
				create index idx1_acc_bucket_map on t_acc_bucket_map(id_acc,ID_USAGE_INTERVAL)
				go
				create table t_acc_ownership
				(id_owner INT NOT NULL, id_owned INT NOT NULL, id_relation_type INT NOT NULL, n_percent INT NOT NULL, 
				vt_start DATETIME NOT NULL, vt_end DATETIME NOT NULL, tt_start DATETIME NOT NULL, tt_end DATETIME NOT NULL)
				go
				alter table t_acc_ownership  
				add constraint t_acc_ownership_PK PRIMARY KEY (id_owner, id_owned, id_relation_type, n_percent, vt_start, vt_end, tt_start, tt_end)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check1 CHECK (id_owner <> id_owned)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check2 CHECK (n_percent <= 100 AND n_percent >= 0)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check3 CHECK (vt_start <= vt_end)
				alter table t_acc_ownership add CONSTRAINT t_acc_ownership_check4 CHECK (tt_start <= tt_end)
				go
				create table t_archive_queue 
				(id_svc int, 
				status varchar(1), 
				tt_start datetime, 
				tt_end datetime)
				go
				CREATE TABLE [dbo].[t_listener]
				(
				[id_listener] [int] NOT NULL IDENTITY(1, 1),
				[tx_machine] [varchar] (256)  NULL,
				[b_online] [char] (1)  NOT NULL
				)
				GO
				ALTER TABLE [dbo].[t_listener] ADD CONSTRAINT [PK_t_listener] PRIMARY KEY CLUSTERED  ([id_listener])
				GO
				ALTER TABLE [dbo].[t_listener] ADD CONSTRAINT [uk_t_listener_tx_machine] UNIQUE NONCLUSTERED  ([tx_machine])
				GO
				create table t_message
				(
				id_message int PRIMARY KEY CLUSTERED,
				id_route int,
				dt_crt datetime not null,
				dt_metered datetime not null,
				dt_assigned datetime,
				id_listener int,
				id_pipeline int,
				dt_completed datetime,
				id_feedback int,
				tx_TransactionID varchar(256), 
				tx_sc_username varchar(510),
				tx_sc_password varchar(128),
				tx_sc_namespace varchar(80),
				tx_sc_serialized text,
				tx_ip_address varchar(15) not null
				)
				go
				create table t_pipeline
				(
				id_pipeline int identity(1,1) not null PRIMARY KEY CLUSTERED,
				tx_machine nvarchar(128) not null,
				b_online char(1) not null,
				b_paused char(1) not null,
				b_processing char(1) not null
				)
				alter table t_pipeline add constraint UK1_tx_machine UNIQUE (tx_machine)
				go
				create table t_pipeline_service
				(
				id_pipeline int not null,
				id_svc int not null,
				tt_start datetime not null,
				tt_end datetime not null,
				)
				alter table t_pipeline_service add constraint pk_t_pipeline_service primary key(id_pipeline, id_svc, tt_start, tt_end)
				go
				ALTER TABLE [dbo].[t_pipeline_service] ADD CONSTRAINT [FK1_T_PIPELINE_SERVICE] FOREIGN KEY ([id_pipeline]) REFERENCES [dbo].[t_pipeline] ([id_pipeline])
				GO
				ALTER TABLE [dbo].[t_pipeline_service] ADD CONSTRAINT [FK2_T_PIPELINE_SERVICE] FOREIGN KEY ([id_svc]) REFERENCES [dbo].[t_enum_data] ([id_enum_data])
				GO
				CREATE TABLE t_service_def_log (nm_service_def nvarchar(100) NOT NULL, 
				id_revision int NOT NULL, tx_checksum varchar(100) NOT NULL,
				nm_table_name varchar(255),
				CONSTRAINT PK_t_service_def_log PRIMARY KEY CLUSTERED (nm_service_def))
				go
				CREATE TABLE t_session_state
				(
				id_sess BINARY(16) NOT NULL,
				dt_start DATETIME NOT NULL,
				dt_end DATETIME NOT NULL,
				tx_state CHAR(1) NOT NULL,
				CONSTRAINT pk_t_session_state PRIMARY KEY CLUSTERED (id_sess, dt_start,tx_state) 
				) 
				go
				create table t_session_set
				(
				id_message int not null,
				id_ss int not null,
				id_svc int not null,
				b_root char(1) not null,
				session_count int not null,
				CONSTRAINT pk_t_session_set PRIMARY KEY CLUSTERED (id_ss)
				)
				go
				CREATE NONCLUSTERED INDEX [t_session_set_fk1idx] ON [dbo].[t_session_set] ([id_message])
				GO
				CREATE TABLE t_session
				(
				id_ss INT NOT NULL,
				id_source_sess BINARY(16) NOT NULL,  -- client generated UID
				CONSTRAINT pk_t_session PRIMARY KEY CLUSTERED (id_ss, id_source_sess)	
				)
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
				where tc.TABLE_NAME = 'T_AUDIT'
				and ctu.table_name='T_AUDIT_DETAILS'
				select @stmt = N'alter table t_audit_details drop constraint ' + @name
				exec sp_executesql @stmt
				go
				CREATE TABLE tmp_t_audit (
				id_audit int NOT NULL,
				id_Event int NULL,
				id_UserId int NULL,
				id_entitytype int NULL,
				id_entity int NULL,
				dt_crt datetime NOT NULL
				)
				go
				insert into tmp_t_audit select * from t_audit
				go
				drop table t_audit
				go
				exec sp_rename 'tmp_t_audit','t_audit'
				go
				alter table t_audit add constraint PK_t_audit PRIMARY KEY CLUSTERED (id_audit)
				go
				create index fk1idx_T_AUDIT  on T_AUDIT (ID_EVENT) 
				go
				alter table T_AUDIT add constraint FK1_T_AUDIT
				foreign key (ID_EVENT) references T_AUDIT_EVENTS (ID_EVENT)
				go
				alter table T_AUDIT_DETAILS add  constraint FK1_T_AUDIT_DETAILS
				foreign key (ID_AUDIT) references T_AUDIT (ID_AUDIT) on delete cascade
				go
				ALTER TABLE t_failed_transaction ADD id_sch_ss int NULL
				GO
				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='UQ'
				and b.xtype='U'
				and b.name='T_RERUN'
				and a.id=c.constid
				and b.id=c.id
				select @stmt = N'alter table T_RERUN drop constraint ' + @name
				exec sp_executesql @stmt
				GO
				DROP VIEW [dbo].[T_VW_ACCTRES_BYID]
				GO
				DROP VIEW [dbo].[T_VW_I_ACC_MAPPER]
				GO
				DROP VIEW [dbo].[T_VW_I_ACCTRES_BYID]
				GO
				DROP VIEW [dbo].[T_VW_I_GSUBMEMBER]
				GO
				ALTER TABLE [dbo].[t_acc_ownership] ADD
				CONSTRAINT [t_acc_ownership_fk1] FOREIGN KEY ([id_owner]) REFERENCES [dbo].[t_account] ([id_acc]),
				CONSTRAINT [t_acc_ownership_fk2] FOREIGN KEY ([id_owned]) REFERENCES [dbo].[t_account] ([id_acc]),
				CONSTRAINT [t_acc_ownership_fk3] FOREIGN KEY ([id_relation_type]) REFERENCES [dbo].[t_enum_data] ([id_enum_data])
				GO
				ALTER TABLE [dbo].[t_rerun_history] ALTER COLUMN [tx_action] [varchar] (50) not null
				go
				if not exists
				(
				select 1 from information_schema.columns where table_name = 't_pv_accountcredit'
				and column_name = 'c_GuideIntervalID')
				begin
				alter table t_pv_accountcredit add c_GuideIntervalID int null
				end
				go
				CREATE TABLE [t_query_log] (
				[c_id] [int] IDENTITY (1, 1) NOT NULL ,
				[c_groupid] [varchar] (50) NOT NULL ,
				[c_id_view] [int] NULL ,
				[c_old_schema] [nvarchar] (4000) NOT NULL ,
				[c_query] [nvarchar] (4000) NOT NULL ,
				[c_timestamp] [datetime] NOT NULL CONSTRAINT [DF_t_query_log_c_timestamp] DEFAULT (getdate())
				)
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[archive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				drop procedure [dbo].[archive]
				GO
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dearchive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				drop procedure [dbo].[dearchive]
				go
				DROP INDEX [dbo].[t_acc_usage].[fk3idx_t_acc_usage]
				GO
				DROP INDEX [dbo].[t_acc_usage].[fk4idx_t_acc_usage]
				GO
				DROP INDEX [dbo].[t_acc_usage].[idx_acc_ui_view_ind]
				GO
				DROP INDEX [dbo].[t_acc_usage].[idx_payee_ind]
				GO
				CREATE NONCLUSTERED INDEX [idx_acc_ui_view_ind] ON [dbo].[t_acc_usage] ([id_acc], [id_usage_interval], [id_view])
				CREATE NONCLUSTERED INDEX [idx_payee_ind] ON [dbo].[t_acc_usage] ([id_payee], [dt_session])
				GO
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_city] [nvarchar] (40) NULL
				GO
				CREATE NONCLUSTERED INDEX [id_subidx_t_pl_map] ON [dbo].[t_pl_map] ([id_sub])
				GO
				set nocount on
				declare @var1 varchar(1000)
				DECLARE c1 CURSOR
				FOR select table_name from information_schema.tables
				where table_type='BASE TABLE'
				and table_name like 'tmp%'
				OPEN c1
				FETCH NEXT FROM c1 into @var1
				WHILE @@FETCH_STATUS = 0
				begin 
				execute ('drop table ' + @var1)
				FETCH NEXT FROM c1 into @var1
				end
				close c1
				deallocate c1
				go
				CREATE NONCLUSTERED INDEX [idx_t_account_id_acc_ext] ON [t_account] ([id_acc_ext])
				GO
				UPDATE t_sys_upgrade
				SET db_upgrade_status = 'C',
				dt_end_db_upgrade = getdate()
				WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
				go
