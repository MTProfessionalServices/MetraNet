use %%NETMETER%%

set nocount on
go
INSERT INTO t_sys_upgrade
(target_db_version, dt_start_db_upgrade, db_upgrade_status)
VALUES	('6.2', getdate(), 'C')

go

/**************************************************************/
/   RMP\Config\DBINstall\Queries.xml
/**************************************************************/

PRINT N'Drop [dbo].[t_payment_instrument]'

DROP TABLE [dbo].[t_payment_instrument]

CREATE TABLE [dbo].[t_payment_instrument]
(
	[id_payment_instrument] [nvarchar](72) NOT NULL,
	[id_acct] [int] NULL,
	[n_payment_method_type] [int] NOT NULL,
	[nm_truncd_acct_num] [nvarchar](50) NOT NULL,
	[tx_hash] [nvarchar](255) NOT NULL,
	[id_creditcard_type] [int] NULL,
	[n_account_type] [int] NULL,
	[nm_exp_date] [nvarchar](10) NULL,
	[nm_exp_date_format] [int] NULL,
	[nm_first_name] [nvarchar](50) NOT NULL,
	[nm_middle_name] [nvarchar](50) NULL,
	[nm_last_name] [nvarchar](50) NOT NULL,
	[nm_address1] [nvarchar](255) NOT NULL,
	[nm_address2] [nvarchar](255) NULL,
	[nm_city] [nvarchar](100) NOT NULL,
	[nm_state] [nvarchar](40) NULL,
	[nm_zip] [nvarchar](10) NULL,
	[id_country] [int] NOT NULL,
	[id_priority] [int] NULL,
	[n_max_charge_per_cycle] [decimal](18, 6) NULL,
	[dt_created] [datetime] NOT NULL,
	CONSTRAINT [PK_t_payment_instrument] PRIMARY KEY CLUSTERED
	(
		[id_payment_instrument] ASC
	)
)




/**************************************************************/
/   RMP\Config\DBINstall\BusinessEntities\Queries.xml
/**************************************************************/


PRINT N'Create [dbo].[t_be_entity_sync_data]'


DROP TABLE [dbo].[t_be_entity_sync_data]

create table [t_be_entity_sync_data] 
(
      id [uniqueidentifier] NOT NULL,
		  [tx_entity_name] [nvarchar](255) not null,
      [tx_hbm_checksum] [nvarchar](255) not null,
      [dt_sync_date] [datetime] not null,
      primary key (id)
)



/**************************************************************/
/   RMP\Config\DBINstall\MetraPay\Queries.xml
/**************************************************************/

PRINT N'Create [dbo].[t_ps_preauth]'

DROP TABLE [dbo].[t_ps_preauth]

CREATE TABLE t_ps_preauth
(
	id_preauth_tx_id [nvarchar](72) NOT NULL,
	id_pymt_instrument nvarchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	dt_transaction datetime NOT NULL,
	nm_invoice_num nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	dt_invoice_date datetime NULL,
	nm_po_number nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	nm_description nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	n_currency nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	n_amount numeric(18, 6) NOT NULL,
	n_request_params nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	CONSTRAINT PK_t_ps_preauth PRIMARY KEY CLUSTERED
	(
	  id_preauth_tx_id
	)
)


/**************************************************************/
/   RMP\Config\DBINstall\MetraFlow\Queries.xml                */
/**************************************************************/
   
PRINT N'Create [dbo].[t_mf_tracking_scripts]'

create table t_mf_tracking_scripts
(
   id_tracking nvarchar(64) PRIMARY KEY NOT NULL,
   script_name nvarchar(128) NOT NULL,
   dt_start datetime NOT NULL,
   was_completed int NOT NULL
)




PRINT N'Create [dbo].[t_mf_tracking_instructions]'

create table t_mf_tracking_instructions
(
	id_tracking nvarchar(64) NOT NULL,
        seq_no int NOT NULL,
        instruction_no int NOT NULL,
        dt_start datetime NOT NULL,
        dt_end datetime NULL,
        description nvarchar(128) NOT NULL,
        primary key (id_tracking, seq_no)
)



PRINT N'Create [dbo].[t_mf_tracking_env]'


create table t_mf_tracking_env
(
     id_tracking nvarchar(64) NOT NULL,
     seq_no int NOT NULL,
     name nvarchar(64) NOT NULL,
     value nvarchar(128) NOT NULL,
     arg_type int NOT NULL,
     primary key (id_tracking, seq_no, name)
)




