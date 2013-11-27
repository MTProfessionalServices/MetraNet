				update t_account set id_type = (select id_type from t_account_type where name='IndependentAccount')
				where acc_type = 'IND'
				update t_account set id_type = (select id_type from t_account_type where name='SystemAccount')
				where acc_type in ('CSR','MOM','MCM','SYS')
				update t_account set id_type = (select id_type from t_account_type where name='CoreSubscriber')
				where acc_type = 'SUB'
				update t_account set id_type = (select id_type from t_account_type where name='DepartmentAccount')
				where id_acc in (select id_acc from t_av_internal where c_folder =1 )
				and (id_type is null or acc_type = 'SUB')
				update t_account set id_type = (select id_type from t_account_type where name='CorporateAccount')
				where id_acc in (
				select id_descendent from t_account_ancestor 
				where id_ancestor = 1 AND num_generations = 1)
				and (id_type is null or acc_type = 'SUB')
				update t_account set id_type = (select id_type from t_account_type where name='Root')
				where id_acc = 1
				go
				update acc set id_acc_type = a.id_type
				from t_acc_template acc inner join t_account a on acc.id_folder = a.id_acc
				go
				alter table t_acc_template alter column id_acc_type int not null
				go
				ALTER TABLE [dbo].[t_acc_template] ADD CONSTRAINT [pk_t_acc_template] PRIMARY KEY CLUSTERED  ([id_folder], [id_acc_type])
				GO
				declare @max_id int
				select @max_id = max(id_acc_template) from t_acc_template

				insert into t_acc_template (id_folder,dt_crt,tx_name,tx_desc,b_ApplyDefaultPolicy,id_acc_type)
				select a.id_folder,a.dt_crt,a.tx_name,a.tx_desc,a.b_applydefaultpolicy,b.id_descendent_type
				,a.b_applydefaultpolicy from t_acc_template a
				inner join t_acctype_descendenttype_map b
				on a.id_acc_type = b.id_type
				where a.id_acc_type <> b.id_descendent_type

				insert into t_acc_template_props (id_acc_template,nm_prop_class,nm_prop,nm_value)
				select
				b.id_acc_template,a.nm_prop_class,a.nm_prop,a.nm_value
				from t_acc_template_props a inner join t_acc_template c
				on a.id_acc_template = c.id_acc_template
				inner join t_acc_template b
				on c.id_folder = b.id_folder
				and c.id_acc_type <> b.id_acc_type
				where b.id_acc_template > @max_id

				insert into t_acc_template_subs (id_po,id_group,id_acc_template,vt_start,vt_end)
				select
				a.id_po,a.id_group,b.id_acc_template,a.vt_start,a.vt_end
				from t_acc_template_subs a inner join t_acc_template c
				on a.id_acc_template = c.id_acc_template
				inner join t_acc_template b
				on c.id_folder = b.id_folder
				and c.id_acc_type <> b.id_acc_type
				where b.id_acc_template > @max_id
				go
				alter table t_account drop constraint t_account_check
				go
				alter table t_account drop column acc_type
				go
				alter table t_account alter column id_type int not null
				go
        insert into t_account(id_acc,id_acc_ext,id_type,dt_crt) 
				select -1, newid(), t_account_type.id_type, dbo.mtmindate()
        from t_account_type where name = 'ROOT'
        go
				insert into t_account_ancestor values (-1,-1,0,'N',dbo.MTMinDate(),dbo.MTMaxDate(),'/')
				go
				insert into t_account_mapper(nm_login,nm_space,id_acc)
				values ('synthetic_root','mt',-1)
				go
				declare @id int
				select @id = max(id_acc) from t_account
				insert into t_current_id(id_current,nm_current) values(@id+1,'id_acc2')
				go				
ALTER TABLE t_account ADD CONSTRAINT fk1_t_account FOREIGN KEY (id_type) REFERENCES t_account_type(id_type)
GO
				DECLARE @name nvarchar(4000)
				declare @table nvarchar(4000)
				declare @stmt nvarchar(4000)
				DECLARE c1 cursor for select  --*
					RC.CONSTRAINT_NAME,CTU.TABLE_NAME
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
				where tc.TABLE_NAME = 'T_ACCOUNT'
				open c1
				fetch next from c1 into @name,@table
				while (@@fetch_status = 0)
				begin
					select @stmt = N'alter table ' + @table + ' drop constraint ' + @name
					exec sp_executesql @stmt
					fetch next from c1 into @name,@table
				end
				close c1
				deallocate c1
go
CREATE TABLE tmp_t_account
(
[id_acc] [int] NOT NULL,
[id_acc_ext] [varbinary] (16) NOT NULL,
[id_type] [int] NOT NULL,
[dt_crt] [datetime] NOT NULL
)
GO
INSERT INTO tmp_t_account([id_acc], [id_acc_ext], [id_type], [dt_crt]) SELECT [id_acc], [id_acc_ext], [id_type], [dt_crt] FROM [dbo].[t_account]
GO
DROP TABLE [dbo].[t_account]
GO
sp_rename N'[dbo].[tmp_t_account]', N't_account'
GO
ALTER TABLE [dbo].[t_account] ADD CONSTRAINT [PK_ACCOUNT] PRIMARY KEY CLUSTERED  ([id_acc])
GO
CREATE NONCLUSTERED INDEX [idx_t_account_id_acc_ext] ON [dbo].[t_account] ([id_acc_ext])
GO
alter table t_account add constraint fk1_t_account foreign key (id_type) REFERENCES t_account_type (id_type)
go
ALTER TABLE [dbo].[t_principal_policy] ADD
CONSTRAINT [FK1_T_PRINCIPAL_POLICY] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_av_internal] ADD
CONSTRAINT [FK_t_av_internal] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_acc_ownership] ADD
CONSTRAINT [t_acc_ownership_fk1] FOREIGN KEY ([id_owner]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [t_acc_ownership_fk2] FOREIGN KEY ([id_owned]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_pl_map] ADD
CONSTRAINT [FK1_T_PL_MAP] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_member_history] ADD
CONSTRAINT [FK1_t_billgroup_member_history] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_materialization] ADD
CONSTRAINT [FK1_t_billgroup_materialization] FOREIGN KEY ([id_user_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_group_sub] ADD
CONSTRAINT [FK2_T_GROUP_SUB] FOREIGN KEY ([id_discountAccount]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [FK3_T_GROUP_SUB] FOREIGN KEY ([id_corporate_account]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_account_state_history] ADD
CONSTRAINT [FK1_T_ACCOUNT_STATEHIS] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_payment_redirection] ADD
CONSTRAINT [FK1_T_PAYMENT_REDIRECTION] FOREIGN KEY ([id_payer]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [FK2_T_PAYMENT_REDIRECTION] FOREIGN KEY ([id_payee]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_acc_usage] ADD
CONSTRAINT [fk2_t_acc_usage] FOREIGN KEY ([id_payee]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_account_ancestor] ADD
CONSTRAINT [fk1_t_account_ancestor] FOREIGN KEY ([id_ancestor]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [fk2_t_account_ancestor] FOREIGN KEY ([id_descendent]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_gsubmember] ADD
CONSTRAINT [FK2_T_GSUBMEMBER] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_gsub_recur_map] ADD
CONSTRAINT [t_gsub_recur_map_fk3] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_gsubmember_historical] ADD
CONSTRAINT [FK2_T_GSUBMEMBERHIS] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_acc_template] ADD
CONSTRAINT [FK1_T_ACC_TEMPLATE] FOREIGN KEY ([id_folder]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_member] ADD
CONSTRAINT [FK2_t_billgroup_member] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_acc_usage_cycle] ADD
CONSTRAINT [fk1_t_acc_usage_cycle] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_constraint] ADD
CONSTRAINT [FK2_t_billgroup_constraint] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_member_tmp] ADD
CONSTRAINT [FK2_t_billgroup_member_tmp] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_constraint_tmp] ADD
CONSTRAINT [FK2_t_billgroup_constraint_tmp] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_billgroup_source_acc] ADD
CONSTRAINT [FK2_t_billgroup_source_acc] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_impersonate] ADD
CONSTRAINT [FK1_T_IMPERSONATE] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [FK2_T_IMPERSONATE] FOREIGN KEY ([id_owner]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_acc_usage_interval] ADD
CONSTRAINT [fk1_t_acc_usage_interval] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_av_contact] ADD
CONSTRAINT [FK_t_av_contact] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_recevent_run_failure_acc] ADD
CONSTRAINT [FK2_t_recevent_run_failure_acc] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_sub] ADD
CONSTRAINT [FK1_T_SUB] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_sub_history] ADD
CONSTRAINT [FK1_T_SUB_HISTORY] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_account_state] ADD
CONSTRAINT [FK1_T_ACCOUNT_STATE] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
ALTER TABLE [dbo].[t_payment_redir_history] ADD
CONSTRAINT [FK1_T_PAYMENT_REDIRECTION_HIS] FOREIGN KEY ([id_payer]) REFERENCES [dbo].[t_account] ([id_acc]),
CONSTRAINT [FK2_T_PAYMENT_REDIRECTION_HIS] FOREIGN KEY ([id_payee]) REFERENCES [dbo].[t_account] ([id_acc])
GO
   /* Start billing group upgrade */
   DECLARE @intervals TABLE
   ( 
      id_identity INT IDENTITY(1000, 1),
      id_usage_interval INT NOT NULL
   )

   /* Populate @intervals */
   INSERT INTO @intervals(id_usage_interval)
   SELECT aui.id_usage_interval
   FROM t_acc_usage_interval aui
   INNER JOIN vw_paying_accounts pa
      ON pa.IntervalID = aui.id_usage_interval
   GROUP BY aui.id_usage_interval

   /* Populate t_billgroup_materialization  */
   DECLARE @accountId INT
   SET @accountId = (SELECT TOP 1 id_acc 
                     FROM t_account_mapper)

   INSERT INTO t_billgroup_materialization (id_user_acc, 
                                            dt_start, 
                                            id_parent_billgroup, 
                                            id_usage_interval, 
                                            tx_status,
                                            tx_type)
   SELECT @accountId, 
               GetDate(),
               NULL,
               id_usage_interval,
               'Succeeded',
               'Full'
   FROM @intervals

   /* Populate t_billgroup_tmp - so that it generates bill group id's and
      increments the bill group id seed. This is necessary because 
      regular creation of billing groups, pull lists etc. depend on this seed. */
   INSERT INTO t_billgroup_tmp (id_materialization,
                                                   tx_name,
                                                   tx_description)
   SELECT bgm.id_materialization, 
               'Default-Upgrade', 
               'This billing group is created by the upgrade script'
   FROM @intervals intervals
   INNER JOIN t_billgroup_materialization bgm
     ON bgm.id_usage_interval = intervals.id_usage_interval
 
   /* Populate t_billgroup  */
   INSERT INTO t_billgroup (id_billgroup, 
                                           tx_name, 
                                           tx_description, 
                                           id_usage_interval, 
                                           id_parent_billgroup, 
                                           tx_type)
   SELECT bgt.id_billgroup, 
               bgt.tx_name, 
               bgt.tx_description, 
               bgm.id_usage_interval, 
               bgm.id_parent_billgroup, 
               bgm.tx_type
   FROM t_billgroup_tmp bgt    
   INNER JOIN t_billgroup_materialization bgm 
       ON bgm.id_materialization = bgt.id_materialization

   /* Populate t_billgroup_member  */
   INSERT INTO t_billgroup_member (id_billgroup, 
                                   id_acc, 
                                   id_materialization, 
                                   id_root_billgroup)
   SELECT bg.id_billgroup, 
               pa.AccountID,
               bgm.id_materialization,
               bg.id_billgroup
   FROM t_billgroup bg
   INNER JOIN t_billgroup_materialization bgm
      ON bgm.id_usage_interval = bg.id_usage_interval
   INNER JOIN vw_paying_accounts pa
      ON pa.IntervalID = bg.id_usage_interval

   /* Update tx_status in t_acc_usage_interval */
   UPDATE aui
   SET tx_status = ui.tx_interval_status
   FROM t_acc_usage_interval aui
   INNER JOIN vw_paying_accounts pa
      ON pa.IntervalID = aui.id_usage_interval AND
            pa.AccountID = aui.id_acc
   INNER JOIN t_usage_interval ui
      ON ui.id_interval = aui.id_usage_interval

   /* Update tx_interval_status in t_acc_usage_interval */
   UPDATE t_usage_interval 
   SET tx_interval_status = 'O'
   WHERE tx_interval_status = 'C'
/* End billing group upgrade */
go
				UPDATE t_sys_upgrade
				SET db_upgrade_status = 'C',
				dt_end_db_upgrade = getdate()
				WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
				go
