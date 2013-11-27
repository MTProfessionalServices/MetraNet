set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES
('6.0.3', getdate(), 'R')
go

        insert into t_current_id values (1, 'id_template_session', 1)
go

        create table t_acc_template_session (
          id_session int not null,
          id_template_owner int not null,
          nm_acc_type nvarchar(255) not null,
          dt_submission datetime not null,
          id_submitter int not null,
          nm_host nvarchar(100) not null,
          n_status int not null,
          n_accts int not null,
          n_subs int not null
          constraint pk_t_acc_template_session PRIMARY KEY(id_session)
        )
go

        create table t_acc_template_session_detail (
        id_detail int identity(1,1),
        id_session int not null,
        n_detail_type int not null,
        n_result int not null,
        dt_detail datetime not null,
        nm_text nvarchar(4000) not null
        constraint pk_t_acc_template_session_detail PRIMARY KEY(id_detail),
        constraint fk1_t_acc_template_session_detail FOREIGN KEY (id_session) REFERENCES t_acc_template_session (id_session)
        )
go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_pc_interval]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table t_ps_ach
go
        CREATE TABLE t_ps_ach(
        [id_payment_instrument] [nvarchar](72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_routing_number] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_name] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [nm_bank_address] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_city] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_bank_state] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [nm_bank_zip] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
        [id_country] [int] NOT NULL,
        CONSTRAINT [PK_t_ps_ach] PRIMARY KEY CLUSTERED
        (
        [id_payment_instrument] ASC
        ))
GO

        CREATE TABLE t_pending_ACH_trans (
        [id_payment_transaction] [nvarchar](87) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [nm_invoice_num] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
        [n_days] int NOT NULL
        CONSTRAINT [PK_t_pending_ach_trans] PRIMARY KEY CLUSTERED
        (
        [id_payment_transaction] ASC
        ))
GO


UPDATE t_sys_upgrade
SET db_upgrade_status = 'C',
dt_end_db_upgrade = getdate()
WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
go

