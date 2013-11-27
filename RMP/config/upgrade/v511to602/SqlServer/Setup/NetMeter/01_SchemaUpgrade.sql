use %%NETMETER%%

set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('6.0.2', getdate(), 'R')
go


--PRINT N'Dropping constraints from [dbo].[t_preauthorizationlist]'
--GO
--ALTER TABLE [dbo].[t_preauthorizationlist] DROP CONSTRAINT [PK_t_preauthorizationlist]
--GO
--PRINT N'Dropping constraints from [dbo].[t_preauthorizationlist]'
--GO
--ALTER TABLE [dbo].[t_preauthorizationlist] DROP CONSTRAINT [DF__t_preauth__dt_cr__0E240DFC]
--GO

PRINT N'Dropping [dbo].[t_preauthorizationlist]'
GO
DROP TABLE [dbo].[t_preauthorizationlist]
GO

PRINT N'Altering [dbo].[t_base_props]'
GO
ALTER TABLE [dbo].[t_base_props] ALTER COLUMN [nm_desc] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Creating [dbo].[t_wf_instancestate]'
GO
CREATE TABLE [dbo].[t_wf_instancestate]
(
[id_instance] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [image] NULL,
[n_status] [int] NULL,
[n_unlocked] [int] NULL,
[n_blocked] [int] NULL,
[tx_info] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_modified] [datetime] NOT NULL,
[id_owner] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_ownedUntil] [datetime] NULL,
[dt_nextTimer] [datetime] NULL
)

GO
PRINT N'Creating index [idx_t_wf_instancestate_id_instance] on [dbo].[t_wf_instancestate]'
GO
CREATE UNIQUE CLUSTERED INDEX [idx_t_wf_instancestate_id_instance] ON [dbo].[t_wf_instancestate] ([id_instance])
GO
PRINT N'Creating [dbo].[t_ui_event_queue]'
GO
CREATE TABLE [dbo].[t_ui_event_queue]
(
[id_event_queue] [int] NOT NULL IDENTITY(1, 1),
[id_event] [int] NOT NULL,
[id_acc] [int] NULL,
[dt_crt] [datetime] NOT NULL,
[dt_viewed] [datetime] NULL,
[b_deleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[b_bubbled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_ui_event_queue] on [dbo].[t_ui_event_queue]'
GO
ALTER TABLE [dbo].[t_ui_event_queue] ADD CONSTRAINT [PK_t_ui_event_queue] PRIMARY KEY CLUSTERED  ([id_event_queue])
GO
PRINT N'Altering [dbo].[t_description]'
GO
ALTER TABLE [dbo].[t_description] ALTER COLUMN [tx_desc] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL

GO
PRINT N'Altering [dbo].[t_recur]'
GO
ALTER TABLE [dbo].[t_recur] ADD
[n_unit_name] [int] NULL,
[n_unit_display_name] [int] NULL,
[nm_unit_display_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Creating [dbo].[t_wf_completedscope]'
GO
CREATE TABLE [dbo].[t_wf_completedscope]
(
[id_instance] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_completedScope] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [image] NOT NULL,
[dt_modified] [datetime] NOT NULL
)

GO
PRINT N'Creating index [idx_t_wf_completedscope_id_instance] on [dbo].[t_wf_completedscope]'
GO
CREATE NONCLUSTERED INDEX [idx_t_wf_completedscope_id_instance] ON [dbo].[t_wf_completedscope] ([id_instance])
GO
PRINT N'Creating index [idx_t_wf_completedscope_id_completedscope] on [dbo].[t_wf_completedscope]'
GO
CREATE NONCLUSTERED INDEX [idx_t_wf_completedscope_id_completedscope] ON [dbo].[t_wf_completedscope] ([id_completedScope])
GO
PRINT N'Altering [dbo].[t_user_credentials]'
GO
ALTER TABLE [dbo].[t_user_credentials] ADD
[dt_expire] [datetime] NULL,
[dt_last_login] [datetime] NULL,
[dt_last_logout] [datetime] NULL,
[num_failures_since_login] [int] NULL,
[dt_auto_reset_failures] [datetime] NULL,
[b_enabled] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[t_user_credentials] ALTER COLUMN [tx_password] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL

GO
PRINT N'Creating [dbo].[t_ui_event]'
GO
CREATE TABLE [dbo].[t_ui_event]
(
[id_event] [int] NOT NULL IDENTITY(1, 1),
[tx_event_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[json_blob] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO
PRINT N'Creating primary key [PK_t_ui_event] on [dbo].[t_ui_event]'
GO
ALTER TABLE [dbo].[t_ui_event] ADD CONSTRAINT [PK_t_ui_event] PRIMARY KEY CLUSTERED  ([id_event])
GO
PRINT N'Creating [dbo].[t_failed_payment]'
GO
CREATE TABLE [dbo].[t_failed_payment]
(
[id_interval] [int] NOT NULL,
[id_acc] [int] NOT NULL,
[id_payment_instrument] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_original_trans] [datetime] NOT NULL,
[nm_invoice_num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_invoice] [datetime] NOT NULL,
[nm_po_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_amount] [decimal] (18, 6) NOT NULL,
[n_retrycount] [int] NULL,
[dt_lastretry] [datetime] NULL
)

GO
PRINT N'Creating primary key [PK_t_failed_payment] on [dbo].[t_failed_payment]'
GO
ALTER TABLE [dbo].[t_failed_payment] ADD CONSTRAINT [PK_t_failed_payment] PRIMARY KEY CLUSTERED  ([id_interval], [id_acc], [id_payment_instrument])
GO
PRINT N'Creating [dbo].[t_payment_history]'
GO
CREATE TABLE [dbo].[t_payment_history]
(
[id_payment_transaction] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_acct] [int] NOT NULL,
[dt_transaction] [datetime] NOT NULL,
[n_payment_method_type] [int] NOT NULL,
[nm_truncd_acct_num] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_creditcard_type] [int] NULL,
[n_account_type] [int] NULL,
[nm_invoice_num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_invoice_date] [datetime] NOT NULL,
[nm_po_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_amount] [numeric] (18, 6) NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_payment_history] on [dbo].[t_payment_history]'
GO
ALTER TABLE [dbo].[t_payment_history] ADD CONSTRAINT [PK_t_payment_history] PRIMARY KEY CLUSTERED  ([id_payment_transaction])
GO
PRINT N'Creating [dbo].[t_payment_instrument]'
GO
CREATE TABLE [dbo].[t_payment_instrument]
(
[id_payment_instrument] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_acct] [int] NULL,
[n_payment_method_type] [int] NOT NULL,
[nm_truncd_acct_num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tx_hash] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_creditcard_type] [int] NULL,
[n_account_type] [int] NULL,
[nm_exp_date] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_exp_date_format] [int] NULL,
[nm_first_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_middle_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_last_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_address1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_city] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_state] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_zip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_country] [int] NOT NULL,
[id_priority] [int] NULL,
[n_max_charge_per_cycle] [decimal] (18, 6) NULL,
[dt_created] [datetime] NOT NULL
)
GO
PRINT N'Creating primary key [PK_t_payment_instrument] on [dbo].[t_payment_instrument]'
GO
ALTER TABLE [dbo].[t_payment_instrument] ADD CONSTRAINT [PK_t_payment_instrument] PRIMARY KEY CLUSTERED  ([id_payment_instrument])
GO
PRINT N'Creating index [idx_t_payment_instrument_id_acct] on [dbo].[t_payment_instrument]'
GO
Create NONCLUSTERED INDEX idx_t_payment_instrument_id_acct on t_payment_instrument(id_acct)
GO
PRINT N'Creating [dbo].[t_payment_instrument_xref]'
GO
CREATE TABLE [dbo].[t_payment_instrument_xref]
(
[temp_acc_id] [int] NOT NULL,
[nm_login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_space] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_created] [datetime] NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_payment_instrument_xref] on [dbo].[t_payment_instrument_xref]'
GO
ALTER TABLE [dbo].[t_payment_instrument_xref] ADD CONSTRAINT [PK_t_payment_instrument_xref] PRIMARY KEY CLUSTERED  ([temp_acc_id], [nm_login], [nm_space])
GO
PRINT N'Creating [dbo].[t_pending_payment_trans]'
GO
CREATE TABLE [dbo].[t_pending_payment_trans]
(
[id_interval] [int] NOT NULL,
[id_acc] [int] NOT NULL,
[id_payment_instrument] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_invoice_num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_invoice] [datetime] NOT NULL,
[nm_po_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_amount] [decimal] (18, 6) NOT NULL,
[id_authorization] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[b_captured] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_pending_payment_trans] on [dbo].[t_pending_payment_trans]'
GO
ALTER TABLE [dbo].[t_pending_payment_trans] ADD CONSTRAINT [PK_t_pending_payment_trans] PRIMARY KEY CLUSTERED  ([id_interval], [id_acc], [id_payment_instrument])
GO
PRINT N'Creating [dbo].[t_user_credentials_history]'
GO
CREATE TABLE [dbo].[t_user_credentials_history]
(
[nm_login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_space] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tx_password] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tt_end] [datetime] NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_user_credentials_history] on [dbo].[t_user_credentials_history]'
GO
ALTER TABLE [dbo].[t_user_credentials_history] ADD CONSTRAINT [PK_t_user_credentials_history] PRIMARY KEY CLUSTERED  ([nm_login], [nm_space], [tt_end])
GO
PRINT N'Creating [dbo].[t_wf_acc_inst_map]'
GO
CREATE TABLE [dbo].[t_wf_acc_inst_map]
(
[id_acc] [int] NOT NULL,
[workflow_type] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_type_instance] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_workflow_instance] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_wf_acc_inst_map] on [dbo].[t_wf_acc_inst_map]'
GO
ALTER TABLE [dbo].[t_wf_acc_inst_map] ADD CONSTRAINT [PK_t_wf_acc_inst_map] PRIMARY KEY CLUSTERED  ([id_acc], [workflow_type], [id_type_instance])
GO
PRINT N'Adding foreign keys to [dbo].[t_ui_event_queue]'
GO
ALTER TABLE [dbo].[t_ui_event_queue] ADD
CONSTRAINT [FK_t_ui_event_queue_t_ui_event] FOREIGN KEY ([id_event]) REFERENCES [dbo].[t_ui_event] ([id_event])
GO

PRINT N'Adding index to [dbo].[t_account_ancestor]'
GO
create index ancestor_idx4 on t_account_ancestor(id_ancestor,id_descendent)
GO

PRINT N'Altering [dbo].[t_vw_base_props]'
GO
ALTER view t_vw_base_props
as
select
  td_dispname.id_lang_code, bp.id_prop, bp.n_kind, bp.n_name, bp.n_desc,
  bp.nm_name as nm_name, td_desc.tx_desc as nm_desc, bp.b_approved, bp.b_archive,
  bp.n_display_name, td_dispname.tx_desc as nm_display_name
from t_base_props bp
  left join t_description td_dispname on td_dispname.id_desc = bp.n_display_name
  left join t_description td_desc on td_desc.id_desc = bp.n_desc and td_desc.id_lang_code = td_dispname.id_lang_code
  
GO

GO
PRINT N'Altering [dbo].[t_current_id]'
GO
ALTER TABLE [dbo].[t_current_id] ADD
[id_min_id] int NULL
GO
PRINT N'Altering [dbo].[t_current_id] to avoid collisions with new mashed id'
GO
update t_current_id
set id_min_id = id_current + 1000
GO
insert into t_current_id(id_current, nm_current) VALUES(-2147483647, 'temp_acc_id')
go

PRINT N'update unit dependent recurring charge in t_base_props'
GO
update t_base_props
set n_kind = 25
where n_kind = 20
  and upper(nm_name) like '%UNIT DEPENDENT RECURRING CHARGE%'
go

UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go

