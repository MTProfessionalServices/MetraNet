				INSERT INTO t_sys_upgrade
				(target_db_version, dt_start_db_upgrade, db_upgrade_status)
				VALUES
				(3.7, getdate(), 'R')
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_DETAILS]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_ADJUSTMENT_DETAILS]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_SUMMARY]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_ADJUSTMENT_SUMMARY]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_SUMMARY_DATAMART]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_ADJUSTMENT_SUMMARY_DATAMART]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_AJ_INFO]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_AJ_INFO]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_allrateschedules]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_pilookup]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_pilookup]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_ACCTRES]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_ACCTRES]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_ACCTRES_BYID]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_ACCTRES_BYID]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_EFFECTIVE_SUBS]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_EFFECTIVE_SUBS]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_GSUBMEMBER]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_I_GSUBMEMBER]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_po]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_allrateschedules_po]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_po_icb]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_allrateschedules_po_icb]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_po_noicb]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_allrateschedules_po_noicb]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_expanded_sub]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_expanded_sub]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_rc_arrears_fixed]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_rc_arrears_fixed]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_rc_arrears_relative]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_rc_arrears_relative]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACCTRES]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_I_ACCTRES]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACCTRES_BYID]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_I_ACCTRES_BYID]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_HIERARCHYNAME]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_HIERARCHYNAME]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_MPS_ACC_MAPPER]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[VW_MPS_ACC_MAPPER]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_pl]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_allrateschedules_pl]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vw_mps_or_system_acc_mapper]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[vw_mps_or_system_acc_mapper]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACC_MAPPER]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[T_VW_I_ACC_MAPPER]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_base_props]') and OBJECTPROPERTY(id, N'IsView') = 1)
				drop view [dbo].[t_vw_base_props]	
				go
				declare @temp_database varchar(100)
				declare @str nvarchar(1000)
				select @temp_database = db_name()
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET ANSI_PADDING ON'
				exec sp_executesql  @str
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET ANSI_NULLS ON'
				exec sp_executesql  @str
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET ANSI_WARNINGS ON'
				exec sp_executesql  @str			
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET CONCAT_NULL_YIELDS_NULL ON'
				exec sp_executesql  @str
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET QUOTED_IDENTIFIER ON'
				exec sp_executesql  @str
				select @str =  N'ALTER DATABASE '  + @temp_database + N' SET NUMERIC_ROUNDABORT OFF'
				exec sp_executesql  @str
				go
				select * into tmp_t_adjustment_transaction from t_adjustment_transaction
				go
				drop table t_adjustment_transaction
				go
				create table t_adjustment_transaction (
					id_adj_trx int primary key not null,
					id_sess int null,
					id_parent_sess int null,
					id_reason_code int not null,
					id_acc_creator INT NOT NULL,
					id_acc_payer INT NOT NULL,
					c_status VARCHAR(10) NOT NULL,
					-- Prebill  or postbill
					n_adjustmenttype INT NOT NULL,
					dt_crt DATETIME NOT NULL,
					dt_modified DATETIME NOT NULL,
					id_aj_template INT NULL,
					id_aj_instance INT NULL,
					id_aj_type INT NOT NULL,
					id_usage_interval INT NOT NULL,
					AdjustmentAmount NUMERIC(18, 6) NOT NULL,
					aj_tax_federal NUMERIC(18, 6) NOT NULL,
					aj_tax_state NUMERIC(18, 6) NOT NULL,
					aj_tax_county NUMERIC(18, 6) NOT NULL,
					aj_tax_local NUMERIC(18, 6) NOT NULL,
					aj_tax_other NUMERIC(18, 6) NOT NULL,
					am_currency nvarchar(3) NOT NULL,
					tx_default_desc nvarchar(1900) NULL,
					tx_desc nvarchar(1900) NULL,
					ARBatchID varchar(15) NULL,
					ARDelBatchID varchar(15) NULL,
					ARDelAction char(1) NULL,
					archive_sess int,
					CONSTRAINT aj_trxcheck CHECK 	(id_aj_template IS NOT NULL OR id_aj_instance IS NOT NULL))
				go
				INSERT INTO [dbo].[t_adjustment_transaction]([id_adj_trx], [id_sess], [id_parent_sess], [id_reason_code], [id_acc_creator],
				[id_acc_payer], [c_status], [n_adjustmenttype], [dt_crt], [dt_modified], [id_aj_template], [id_aj_instance], [id_aj_type], [id_usage_interval],
				[AdjustmentAmount], [aj_tax_federal],[aj_tax_state], [aj_tax_county], [aj_tax_local], [aj_tax_other],
				[am_currency], [tx_default_desc], [tx_desc], [ARBatchID], [ARDelBatchID], [ARDelAction], archive_sess) 
				SELECT [id_adj_trx], [id_sess], [id_parent_sess], [id_reason_code], [id_acc_creator], [id_acc_payer], [c_status], [n_adjustmenttype], [dt_crt],
				[dt_modified], [id_aj_template], [id_aj_instance], [id_aj_type], [id_usage_interval], [AdjustmentAmount], 
				0.0, 0.0, 0.0, 0.0, 0.0,
				[am_currency], cast(tx_default_desc as nvarchar(4000)), 
				cast(tx_desc as nvarchar(4000)), [ARBatchID], [ARDelBatchID], [ARDelAction], null FROM [dbo].[tmp_t_adjustment_transaction]
				go
				ALTER TABLE [dbo].[t_adjustment_transaction] ADD
				CONSTRAINT [t_adjustment_trx_fk1] FOREIGN KEY ([id_sess]) REFERENCES [dbo].[t_acc_usage] ([id_sess]),
				CONSTRAINT [t_adjustment_trx_fk3] FOREIGN KEY ([id_aj_template]) REFERENCES [dbo].[t_adjustment] ([id_prop]),
				CONSTRAINT [t_adjustment_trx_fk4] FOREIGN KEY ([id_aj_instance]) REFERENCES [dbo].[t_adjustment] ([id_prop])
				go
				CREATE NONCLUSTERED INDEX [t_adjustment_transaction_fk3idx] ON [dbo].[t_adjustment_transaction] ([id_sess])
				CREATE NONCLUSTERED INDEX [t_adjustment_transaction_fk1idx] ON [dbo].[t_adjustment_transaction] ([id_aj_template])
				CREATE NONCLUSTERED INDEX [t_adjustment_transaction_fk2idx] ON [dbo].[t_adjustment_transaction] ([id_aj_instance])
				go
				drop table tmp_t_adjustment_transaction
				go
				select * into tmp_t_adjustment_type from t_adjustment_type
				go
				ALTER TABLE [dbo].[t_adjustment_type_prop] DROP CONSTRAINT [adjustment_type_prop_fk1]
				go
				ALTER TABLE [dbo].[t_adjustment] DROP CONSTRAINT [t_adjustment_fk3]
				GO
				drop table t_adjustment_type
				go
				create table t_adjustment_type (
					id_prop int primary key not null,
					tx_guid VARBINARY(16) null,
					id_pi_type int not null,
					n_adjustmentType int not null, -- adjustment enumerated type
					b_supportBulk char(1) not null,
					id_formula INT NOT NULL,
					tx_default_desc ntext null,
					CONSTRAINT adj_bulkcheck CHECK 	(b_supportBulk = 'Y' or b_supportBulk = 'N'))
				go
				INSERT INTO [dbo].[t_adjustment_type]([id_prop], [tx_guid], [id_pi_type], [n_adjustmentType], [b_supportBulk], [id_formula], [tx_default_desc])
				SELECT [id_prop], [tx_guid], [id_pi_type], [n_adjustmentType], [b_supportBulk], [id_formula], [tx_default_desc] FROM [dbo].[tmp_t_adjustment_type]
				GO
				ALTER TABLE [dbo].[t_adjustment_type] ADD
				CONSTRAINT [adjustment_type_fk1] FOREIGN KEY ([id_prop]) REFERENCES [dbo].[t_base_props] ([id_prop]),
				CONSTRAINT [adjustment_type_fk2] FOREIGN KEY ([id_pi_type]) REFERENCES [dbo].[t_pi] ([id_pi])
				ALTER TABLE [dbo].[t_adjustment_type_prop] ADD
				CONSTRAINT [adjustment_type_prop_fk1] FOREIGN KEY ([id_adjustment_type]) REFERENCES [dbo].[t_adjustment_type] ([id_prop])
				ALTER TABLE [dbo].[t_adjustment] ADD
				CONSTRAINT [t_adjustment_fk3] FOREIGN KEY ([id_adjustment_type]) REFERENCES [dbo].[t_adjustment_type] ([id_prop])
				GO
				CREATE NONCLUSTERED INDEX [t_adjustment_type_fk1idx] ON [dbo].[t_adjustment_type] ([id_pi_type])
				go
				drop table tmp_t_adjustment_type
				go
				ALTER TABLE [dbo].[t_batch] DROP CONSTRAINT [UK_2_t_batch]
				GO
				ALTER TABLE [dbo].[t_batch] DROP CONSTRAINT [UK_4_t_batch]
				GO
				ALTER TABLE [dbo].[t_batch] ALTER COLUMN [tx_name] [nvarchar] (128) not null
				ALTER TABLE [dbo].[t_batch] ALTER COLUMN [tx_namespace] [nvarchar] (128) not null
				go
				ALTER TABLE [dbo].[t_batch] ADD CONSTRAINT [UK_2_t_batch] UNIQUE NONCLUSTERED  ([tx_name], [tx_namespace], [tx_sequence])
				GO
				select * into tmp_t_calc_formula from t_calc_formula
				go
				drop table t_calc_formula
				go
				create table t_calc_formula(
					id_formula int primary key identity(1, 1) not null,
					tx_formula ntext not null,
					id_engine INT NOT NULL
				)
				go
				SET IDENTITY_INSERT [dbo].[t_calc_formula] ON
				go
				INSERT INTO [dbo].[t_calc_formula]([id_formula], [tx_formula], [id_engine]) SELECT [id_formula], [tx_formula], [id_engine]
				FROM [dbo].[tmp_t_calc_formula]
				GO
				SET IDENTITY_INSERT [dbo].[t_calc_formula] Off
				go
				drop table tmp_t_calc_formula
				go
				ALTER TABLE [dbo].[t_current_id] DROP CONSTRAINT [PK_t_current_id]
				ALTER TABLE [dbo].[t_current_id] ALTER COLUMN [nm_current] [nvarchar] (20) not null
				ALTER TABLE [dbo].[t_current_id] ADD CONSTRAINT [PK_t_current_id] PRIMARY KEY CLUSTERED  ([id_current], [nm_current])
				go
				ALTER TABLE [dbo].[t_enum_data] DROP CONSTRAINT [C_nm_enum_data]
				ALTER TABLE [dbo].[t_enum_data] ALTER COLUMN [nm_enum_data] [nvarchar] (255) NOT NULL				ALTER TABLE [dbo].[t_enum_data] ADD CONSTRAINT [C_nm_enum_data] UNIQUE NONCLUSTERED  ([nm_enum_data])
				GO
				ALTER TABLE [dbo].[t_ep_map] DROP CONSTRAINT [t_ep_map_PK]
				ALTER TABLE [dbo].[t_ep_map] ALTER COLUMN [nm_ep_tablename] [nvarchar] (256) NOT NULL
				ALTER TABLE [dbo].[t_ep_map] ALTER COLUMN [nm_desc] [nvarchar] (256) NOT NULL
				ALTER TABLE [dbo].[t_ep_map] ADD CONSTRAINT [t_ep_map_PK] PRIMARY KEY CLUSTERED  ([id_principal], [nm_ep_tablename])
				GO
				ALTER TABLE [dbo].[t_group_sub] DROP CONSTRAINT [t_group_sub_check4]
				ALTER TABLE [dbo].[t_group_sub] ALTER COLUMN [tx_name] [nvarchar] (255) NOT NULL
				ALTER TABLE [dbo].[t_group_sub] ALTER COLUMN [tx_desc] [nvarchar] (255) NULL				ALTER TABLE [dbo].[t_group_sub] ADD CONSTRAINT [t_group_sub_check4] UNIQUE NONCLUSTERED  ([tx_name], [id_corporate_account])
				go
				ALTER TABLE [dbo].[t_prod_view_prop] DROP CONSTRAINT [t_prod_view_prop_view_name_IDX]
				ALTER TABLE [dbo].[t_prod_view_prop] ALTER COLUMN [nm_name] [nvarchar] (255) NOT NULL
				ALTER TABLE [dbo].[t_prod_view_prop] ALTER COLUMN [nm_column_name] [nvarchar] (255) NOT NULL
				ALTER TABLE [dbo].[t_prod_view_prop] ALTER COLUMN [nm_default_value] [nvarchar] (255)
				ALTER TABLE [dbo].[t_prod_view_prop] ALTER COLUMN [nm_space] [nvarchar] (255)
				ALTER TABLE [dbo].[t_prod_view_prop] ALTER COLUMN [nm_enum] [nvarchar] (255)
				ALTER TABLE [dbo].[t_prod_view_prop] ADD CONSTRAINT [t_prod_view_prop_view_name_IDX] UNIQUE NONCLUSTERED  ([id_prod_view], [nm_name])
				GO
				ALTER TABLE [dbo].[t_product_view_log] DROP CONSTRAINT [PK_t_product_view_log]
				ALTER TABLE [dbo].[t_product_view_log] ALTER COLUMN [nm_product_view] [nvarchar] (100) not null
				ALTER TABLE [dbo].[t_product_view_log] ADD CONSTRAINT [PK_t_product_view_log] PRIMARY KEY CLUSTERED  ([nm_product_view])
				GO
				DROP INDEX [dbo].[t_profile].[idx_nm_tag_profile]
				ALTER TABLE [dbo].[t_profile] DROP CONSTRAINT [PK_t_profile]
				ALTER TABLE [dbo].[t_profile] ALTER COLUMN [nm_tag] [nvarchar] (32) NOT NULL
				ALTER TABLE [dbo].[t_profile] ALTER COLUMN [val_tag] [nvarchar] (80) 
				ALTER TABLE [dbo].[t_profile] ALTER COLUMN [tx_desc] [nvarchar] (255)
				ALTER TABLE [dbo].[t_profile] ADD CONSTRAINT [PK_t_profile] PRIMARY KEY CLUSTERED  ([id_profile], [nm_tag])
				CREATE NONCLUSTERED INDEX [idx_nm_tag_profile] ON [dbo].[t_profile] ([nm_tag])
				GO
				ALTER TABLE [dbo].[t_recevent_inst_audit] DROP CONSTRAINT [CK1_t_recevent_inst_audit]
				ALTER TABLE [dbo].[t_recevent_inst_audit] ALTER COLUMN [tx_action] [nvarchar] (18) NOT NULL
				ALTER TABLE [dbo].[t_recevent_inst_audit] ALTER COLUMN [tx_detail] [nvarchar] (2048)
				ALTER TABLE [dbo].[t_recevent_inst_audit] ADD CONSTRAINT [CK1_t_recevent_inst_audit] CHECK (([tx_action] = 'MarkAsNotYetRun' or ([tx_action] = 'MarkAsFailed' or ([tx_action] = 'MarkAsSucceeded' or ([tx_action] = 'Cancel' or ([tx_action] = 'Unacknowledge' or ([tx_action] = 'Acknowledge' or ([tx_action] = 'SubmitForReversal' or [tx_action] = 'SubmitForExecution'))))))))
				GO
				ALTER TABLE [dbo].[t_recevent_run] DROP CONSTRAINT [CK2_t_recevent_run]
				ALTER TABLE [dbo].[t_recevent_run] ALTER COLUMN [tx_status] [nvarchar] (10) NOT NULL
				ALTER TABLE [dbo].[t_recevent_run] ALTER COLUMN [tx_detail] [nvarchar] (2048) 
				ALTER TABLE [dbo].[t_recevent_run] ADD CONSTRAINT [CK2_t_recevent_run] CHECK (([tx_status] = 'Failed' or ([tx_status] = 'Succeeded' or [tx_status] = 'InProgress')))
				GO
--				DROP INDEX [dbo].[t_se_mapper].[idx_login_space]
				ALTER TABLE [dbo].[t_se_mapper] DROP CONSTRAINT [t_se_mapper_PK]
				ALTER TABLE [dbo].[t_se_mapper] ALTER COLUMN [nm_space] [nvarchar] (40) NOT NULL
				ALTER TABLE [dbo].[t_se_mapper] ALTER COLUMN [nm_login] [nvarchar] (255) NOT NULL				ALTER TABLE [dbo].[t_se_mapper] ADD CONSTRAINT [t_se_mapper_PK] PRIMARY KEY CLUSTERED  ([id_se], [nm_space], [nm_login])
				CREATE NONCLUSTERED INDEX [idx_login_space] ON [dbo].[t_se_mapper] ([nm_login], [nm_space])
				GO
		        alter table t_se_parent add constraint t_se_parent_FK2 foreign key (id_se) references t_service_endpoint (id_se)
--				drop index t_se_parent.t_se_parent_FK2IDX
		        create clustered index t_se_parent_FK2IDX on t_se_parent (id_se)
				go
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
				ALTER TABLE [dbo].[t_rerun] ALTER COLUMN [tx_filter] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_rerun] ALTER COLUMN [tx_tag] [nvarchar] (255) 
				GO
				ALTER TABLE [dbo].[t_rerun] ADD CONSTRAINT [UQ_t_rerun] UNIQUE NONCLUSTERED  ([tx_tag])
				GO
				ALTER TABLE [dbo].[t_acc_template] ALTER COLUMN [tx_name] [nvarchar] (255)
				ALTER TABLE [dbo].[t_acc_template] ALTER COLUMN [tx_desc] [nvarchar] (255)
				ALTER TABLE [dbo].[t_acc_template_props] ALTER COLUMN [nm_prop_class] [nvarchar] (100)
				ALTER TABLE [dbo].[t_acc_template_props] ALTER COLUMN [nm_prop] [nvarchar] (256) not null
				ALTER TABLE [dbo].[t_acc_template_props] ALTER COLUMN [nm_value] [nvarchar] (256)				ALTER TABLE [dbo].[t_acc_template_subs] ALTER COLUMN [nm_groupsubname] [nvarchar] (256)
				ALTER TABLE [dbo].[t_acc_usage] ALTER COLUMN [am_currency] [nvarchar] (3) not null
				ALTER TABLE [dbo].[t_atomic_capability_type] ALTER COLUMN [tx_name] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_atomic_capability_type] ALTER COLUMN [tx_desc] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_atomic_capability_type] ALTER COLUMN [tx_progid] [nvarchar] (255) not null				ALTER TABLE [dbo].[t_atomic_capability_type] ALTER COLUMN [tx_editor] [nvarchar] (255)				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_firstname] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_lastname] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_email] [nvarchar] (100) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_phonenumber] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_company] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_address1] [nvarchar] (100) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_address2] [nvarchar] (100) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_address3] [nvarchar] (100) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_city] [nvarchar] (20) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_state] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_zip] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_facsimiletelephonenumber] [nvarchar] (40) 
				ALTER TABLE [dbo].[t_av_contact] ALTER COLUMN [c_middleinitial] [nvarchar] (1) 				ALTER TABLE [dbo].[t_av_internal] ALTER COLUMN [c_TaxExemptID] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_av_internal] ALTER COLUMN [c_SecurityAnswer] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_av_internal] ALTER COLUMN [c_StatusReasonOther] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_av_internal] ALTER COLUMN [c_currency] [nvarchar] (10) 				ALTER TABLE [dbo].[t_calc_engine] ALTER COLUMN [nm_name] [nvarchar] (255)
				ALTER TABLE [dbo].[t_charge] ALTER COLUMN [nm_description] [nvarchar] (255)
				ALTER TABLE [dbo].[t_composite_capability_type] ALTER COLUMN [tx_name] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_composite_capability_type] ALTER COLUMN [tx_desc] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_composite_capability_type] ALTER COLUMN [tx_progid] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_composite_capability_type] ALTER COLUMN [tx_editor] [nvarchar] (255) 				ALTER TABLE [dbo].[t_compositor] ALTER COLUMN [tx_description] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_compositor] ALTER COLUMN [tx_param] [nvarchar] (255) 				ALTER TABLE [dbo].[t_counter_metadata] ALTER COLUMN [FormulaTemplate] [nvarchar] (256) not null				ALTER TABLE [dbo].[t_decimal_capability] ALTER COLUMN [tx_param_name] [nvarchar] (2000)
				ALTER TABLE [dbo].[t_description] ALTER COLUMN [tx_URL_desc] [nvarchar] (255)
				ALTER TABLE [dbo].[t_enum_capability] ALTER COLUMN [tx_param_name] [nvarchar] (2000)
				ALTER TABLE [dbo].[t_invoice] ALTER COLUMN [invoice_currency] [nvarchar] (10) not null
				ALTER TABLE [dbo].[t_language] ALTER COLUMN [tx_description] [nvarchar] (255)
				ALTER TABLE [dbo].[t_namespace] ALTER COLUMN [tx_desc] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_namespace] ALTER COLUMN [nm_method] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_namespace] ALTER COLUMN [tx_typ_space] [nvarchar] (40) not null				ALTER TABLE [dbo].[t_path_capability] ALTER COLUMN [tx_param_name] [nvarchar] (2000)
				ALTER TABLE [dbo].[t_payment_method] ALTER COLUMN [nm_payment_method] [nvarchar] (40) not null
				ALTER TABLE [dbo].[t_pricelist] ALTER COLUMN [nm_currency_code] [nvarchar] (10) not null
				ALTER TABLE [dbo].[t_principal_policy] ALTER COLUMN [tx_name] [nvarchar] (255) 
				ALTER TABLE [dbo].[t_principal_policy] ALTER COLUMN [tx_desc] [nvarchar] (255) 				ALTER TABLE [dbo].[t_prod_view] ALTER COLUMN [nm_name] [nvarchar] (255)
				go
				ALTER TABLE [dbo].[t_recevent] ALTER COLUMN [tx_name] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_recevent] ALTER COLUMN [tx_display_name] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_recevent] ALTER COLUMN [tx_desc] [nvarchar] (2048) 
				go
				ALTER TABLE [dbo].[t_recevent_run_details] ALTER COLUMN [tx_detail] [nvarchar] (4000) not null
				go
				ALTER TABLE [dbo].[t_rerun_history] ALTER COLUMN [tx_comment] [nvarchar] (255)
				go
				ALTER TABLE [dbo].[t_role] ALTER COLUMN [tx_name] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_role] ALTER COLUMN [tx_desc] [nvarchar] (255) not null				ALTER TABLE [dbo].[t_sys_track_adapter_run] ALTER COLUMN [action_desc] [nvarchar] (200)
				ALTER TABLE [dbo].[t_tariff] ALTER COLUMN [tx_currency] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_usage_cycle_type] ALTER COLUMN [tx_desc] [nvarchar] (255) not null
				ALTER TABLE [dbo].[t_usage_cycle_type] ALTER COLUMN [tx_cycle_type_method] [nvarchar] (255) not null				ALTER TABLE [dbo].[t_user_credentials] ALTER COLUMN [tx_password] [nvarchar] (64) not null
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_acc_usage_tax_detail]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_acc_usage_tax_detail]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_tax_type]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_tax_type]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ctm_2outof3]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ctm_2outof3]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_acc_usage_pos]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_acc_usage_pos]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_acc_usage_tax_param]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_acc_usage_tax_param]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ctm_prod_chrg]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ctm_prod_chrg]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ctm_telco_chrg]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ctm_telco_chrg]
				go
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_access_method_cd]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_access_method_cd]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_gl_cd]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_gl_cd]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_tax_juris_lvl]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_tax_juris_lvl]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxbl]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxbl]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ctm_telco_chrg]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ctm_telco_chrg]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ctmucc_adj_reason_cd]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ctmucc_adj_reason_cd]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_taxrule_ucc_percnt_lookup]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_taxrule_ucc_percnt_lookup]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_usage_prcss_type]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_usage_prcss_type]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_dm_payer_interval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_dm_payer_interval]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_dm_payee_session]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [dbo].[t_dm_payee_session]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAggregateChargeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetAggregateChargeProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCalendarPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetCalendarPropDefs]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterParamTypeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetCounterParamTypeProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetCounterPropDefs]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetCounterProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterTypeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetCounterTypeProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetDiscountProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetDiscountProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetEffProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetEffProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetNonRecurProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetNonRecurProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPLProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetPLProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPOProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetPOProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRecurProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetRecurProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRuleSetDefProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetRuleSetDefProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetSchedProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetSchedProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetServiceEndpointPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetServiceEndpointPropDefs]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetSubProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetSubProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetUsageProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[GetUsageProps]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertInvoice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[InsertInvoice]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CreateEpSQL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				drop procedure [dbo].[sp_CreateEpSQL]
				if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_GenEpProcs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
				DROP PROCEDURE [dbo].[sp_GenEpProcs]
				go
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
				CREATE TABLE [dbo].[t_archive]
				(
				[id_interval] [int] NULL,
				[id_view] [int] NULL,
				[adj_name] [varchar] (1000) NULL,
				[status] [char] (1) NULL,
				[tt_start] [datetime] NULL,
				[tt_end] [datetime] NULL
				)
				GO
				CREATE CLUSTERED INDEX [idx_archive] ON [dbo].[t_archive] ([id_interval])
				GO
				CREATE TABLE [dbo].[t_db_values]
				(
				[parameter] [nvarchar] (100),
				[value] [nvarchar] (100)
				)
				GO
				DECLARE @str1 Nvarchar(2000)
				DECLARE @tab varchar(100)
				DECLARE @col varchar(100)
				DECLARE @CursorVar CURSOR
				DECLARE @i int
				DECLARE @count int
				set @CursorVar = CURSOR STATIC fOR
				select  O1.name,O.name FROM Sysobjects O JOIN sysforeignkeys F ON O.id =F.constid
				JOIN Sysobjects O1 ON F.fkeyid = O1.id
				JOIN Sysobjects O2 ON F.rkeyid = O2.id
				WHERE  O.type = 'F' and O.status >= 0
				AND O2.Name = 'T_USAGE_CYCLE'
				ORDER BY O1.Name, O.Name
				set @i = 0
				OPEN @CursorVar
				Set @count = @@cursor_rows
				while (@i < @count)
				begin
				select @i = @i + 1
				FETCH NEXT FROM @CursorVar into @tab,@col
				select @str1 = N'ALTER TABLE ' + @tab + N' DROP' + char(10) + char(9) + N'CONSTRAINT ' + @col
				exec sp_executesql @str1
				end
				CLOSE @CursorVar
				DEALLOCATE @CursorVar
				go
				ALTER TABLE [dbo].[t_usage_cycle] DROP CONSTRAINT [PK_t_usage_cycle]
				GO
				CREATE TABLE tmp_t_usage_cycle (
				id_usage_cycle int NOT NULL,
				id_cycle_type int NOT NULL,
				day_of_month int NULL, 
				tx_period_type char(1) NOT NULL, 
				day_of_week int NULL, 
				first_day_of_month int NULL, 
				second_day_of_month int NULL, 
				start_day int NULL, 
				start_month int NULL, 
				start_year int NULL)
				go
				INSERT INTO [dbo].[tmp_t_usage_cycle]([id_usage_cycle], [id_cycle_type], [day_of_month], [tx_period_type], [day_of_week],
				[first_day_of_month], [second_day_of_month], [start_day], [start_month], [start_year]) SELECT [id_usage_cycle], [id_cycle_type],
				[day_of_month], [tx_period_type], [day_of_week], [first_day_of_month], [second_day_of_month], [start_day], [start_month], [start_year] 
				FROM [dbo].[t_usage_cycle]
				GO
				DROP TABLE [dbo].[t_usage_cycle]
				GO
				sp_rename N'[dbo].[tmp_t_usage_cycle]', N't_usage_cycle'
				GO
				ALTER TABLE [dbo].[t_usage_cycle] ADD CONSTRAINT [PK_t_usage_cycle] PRIMARY KEY CLUSTERED  ([id_usage_cycle])
				GO
				CREATE NONCLUSTERED INDEX [fk1idx_T_USAGE_CYCLE] ON [dbo].[t_usage_cycle] ([id_cycle_type])
				GO
				ALTER TABLE [dbo].[t_pc_interval] WITH NOCHECK ADD CONSTRAINT [FK_T_PC_INTERVAL] FOREIGN KEY ([id_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_aggregate] ADD CONSTRAINT [fk1_t_aggregate] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_group_sub] ADD CONSTRAINT [FK1_T_GROUP_SUB] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_usage_interval] ADD CONSTRAINT [FK1_T_USAGE_INTERVAL] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_acc_usage_cycle] ADD CONSTRAINT [FK2_T_ACC_USAGE_CYCLE] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_discount] ADD CONSTRAINT [fk2_t_discount] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_recur] ADD CONSTRAINT [FK2_T_RECUR] FOREIGN KEY ([id_usage_cycle]) REFERENCES [dbo].[t_usage_cycle] ([id_usage_cycle])
				ALTER TABLE [dbo].[t_usage_cycle] ADD CONSTRAINT [FK1_T_USAGE_CYCLE] FOREIGN KEY ([id_cycle_type]) REFERENCES [dbo].[t_usage_cycle_type] ([id_cycle_type])
				GO
				ALTER TABLE [dbo].[t_aggregate] ADD CONSTRAINT [fk3_t_aggregate] FOREIGN KEY ([id_prop]) REFERENCES [dbo].[t_base_props] ([id_prop])
				GO
				ALTER TABLE t_adjustment_type ADD
				n_composite_adjustment int NOT NULL CONSTRAINT DF_t_adjustment_type_t_composite_adjustment DEFAULT (0)
				go
				CREATE TABLE t_composite_adjustment
				(
				id_prop int NOT NULL,
				id_pi_type int NOT NULL,
				id_adjustment_type int NOT NULL
				)
				GO
				select * into tmp_t_gsub_recur_map from t_gsub_recur_map
				GO
				drop table t_gsub_recur_map
				GO
				create table t_gsub_recur_map ( 
						id_group int not null,
						id_prop int not null,
						id_acc int not null,
						vt_start datetime not null,
						vt_end datetime not null,
						tt_start datetime not null,
						tt_end datetime not null
			             )
				GO
				alter table t_gsub_recur_map  add constraint t_gsub_recur_map_PK PRIMARY KEY (id_group, id_prop, vt_start, vt_end, tt_start, tt_end)
				GO
				insert into t_gsub_recur_map(id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end)
				select id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end from tmp_t_gsub_recur_map
				GO
				ALTER TABLE [dbo].[t_gsub_recur_map] ADD
				CONSTRAINT [t_gsub_recur_map_fk1] FOREIGN KEY ([id_group]) REFERENCES [dbo].[t_group_sub] ([id_group]),
				CONSTRAINT [t_gsub_recur_map_fk2] FOREIGN KEY ([id_prop]) REFERENCES [dbo].[t_recur] ([id_prop]),
				CONSTRAINT [t_gsub_recur_map_fk3] FOREIGN KEY ([id_acc]) REFERENCES [dbo].[t_account] ([id_acc])
				GO
				CREATE NONCLUSTERED INDEX [t_gsub_recur_map_FK2IDX] ON [dbo].[t_gsub_recur_map] ([id_prop])
				CREATE NONCLUSTERED INDEX [t_gsub_recur_map_FK3IDX] ON [dbo].[t_gsub_recur_map] ([id_acc])
				go
				CREATE TABLE [dbo].[t_dm_payer_interval] (
				[id_acc] [int] NOT NULL	,
				[id_dm_acc]	[int]	NOT	NULL ,
				[id_usage_interval]	[int]	NOT	NULL ,
				[id_prod]	[int]	NULL ,
				[id_view]	[int]	NOT	NULL ,
				[id_pi_instance] [int] NULL	,
				[id_pi_template] [int] NULL	,
				[am_currency]	[nvarchar] (3) NOT NULL	,
				[id_se]	[int]	NULL ,
				[TotalAmount]	[numeric](38,	6) NULL	,
				[TotalFederalTax]	[numeric](38,	6) NULL	,
				[TotalStateTax]	[numeric](38,	6) NULL	,
				[TotalTax] [numeric](38, 6)	NULL ,
				[PrebillAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillFederalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillStateTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillCountyTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PrebillLocalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillOtherTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillTotalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PostbillAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillFederalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillStateTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillCountyTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PostbillLocalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillOtherTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillTotalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PrebillAdjustedAmount]	[numeric](38,	6) NULL	,
				[PostbillAdjustedAmount] [numeric](38, 6)	NULL ,
				[NumPrebillAdjustments]	[int]	NULL ,
				[NumPostbillAdjustments] [int] NULL	,
				[NumTransactions]	[int]	NULL)
				GO
				create clustered index idx_payer_interval on t_dm_payer_interval(id_acc,id_usage_interval,id_dm_acc)
				GO
				create index idx_se_payer_interval on t_dm_payer_interval(id_se)
				GO
				CREATE TABLE [dbo].[t_dm_payee_session] (
				[id_dm_acc]	[int]	NOT	NULL ,
				[id_prod]	[int]	NULL ,
				[id_view]	[int]	NOT	NULL ,
				[id_pi_template] [int] NULL	,
				[id_pi_instance] [int] NULL	,
				[am_currency]	[nvarchar] (3),
				[id_se]	[int]	NULL ,
				[dt_session] [datetime]	NULL ,
				[TotalAmount]	[numeric](38,	6) NULL	,
				[TotalFederalTax]	[numeric](38,	6) NULL	,
				[TotalStateTax]	[numeric](38,	6) NULL	,
				[TotalTax] [numeric](38, 6)	NULL ,
				[PrebillAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillFederalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillStateTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillCountyTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PrebillLocalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillOtherTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PrebillTotalTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PostbillAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillFederalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillStateTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillCountyTaxAdjustmentAmount]	[numeric](38,	6) NULL	,
				[PostbillLocalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillOtherTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PostbillTotalTaxAdjustmentAmount] [numeric](38, 6)	NULL ,
				[PrebillAdjustedAmount]	[numeric](38,	6) NULL	,
				[PostbillAdjustedAmount] [numeric](38, 6)	NULL ,
				[NumPrebillAdjustments]	[int]	NULL ,
				[NumPostbillAdjustments] [int] NULL	,
				[NumTransactions]	[int]	NULL)
				GO
				create clustered index idx_payee_session on t_dm_payee_session(id_dm_acc,dt_session)
				GO
				CREATE NONCLUSTERED INDEX [tx_UID_idx] ON [dbo].[t_rerun_sessions] ([tx_UID])
				GO
				UPDATE t_sys_upgrade
				SET db_upgrade_status = 'C',
				dt_end_db_upgrade = getdate()
				WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
				go
