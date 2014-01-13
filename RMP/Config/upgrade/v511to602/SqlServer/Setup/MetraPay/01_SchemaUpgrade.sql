use %%METRAPAY%%

PRINT N'Dropping foreign keys from [dbo].[t_ps_ach] [dbo].[t_ps_pcard] and [t_ps_creditcard] to the T_PS_TABLE'
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
where tc.TABLE_NAME = 'T_PS_ACCOUNT'
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


--PRINT N'Dropping constraints from [dbo].[t_ps_account]'
--GO
--ALTER TABLE [dbo].[t_ps_account] DROP CONSTRAINT [PK_t_ps_account]
--GO

PRINT N'Dropping [dbo].[t_ps_account]'
GO
DROP TABLE [dbo].[t_ps_account]
GO
PRINT N'Dropping constraints from [dbo].[t_ps_creditcard]'
GO
ALTER TABLE [dbo].[t_ps_creditcard] DROP CONSTRAINT [PK_t_ps_creditcard]
GO

--PRINT N'Dropping [dbo].[t_ps_creditcard]'
--GO
--DROP TABLE [dbo].[t_ps_creditcard]
--GO

-- Rename the table to preserve the data
EXECUTE sp_rename N'dbo.t_ps_creditcard', N't_ps_creditcard_old', 'OBJECT' 
GO


PRINT N'Creating [dbo].[t_ps_audit]'
GO
CREATE TABLE [dbo].[t_ps_audit]
(
[id_audit] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_request_type] [int] NOT NULL,
[id_transaction] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_transaction] [datetime] NOT NULL,
[n_payment_method_type] [int] NOT NULL,
[nm_truncd_acct_num] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_creditcard_type] [int] NULL,
[n_account_type] [int] NULL,
[nm_invoice_num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_invoice_date] [datetime] NULL,
[nm_po_number] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_amount] [numeric] (18, 6) NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_ps_audit] on [dbo].[t_ps_audit]'
GO
ALTER TABLE [dbo].[t_ps_audit] ADD CONSTRAINT [PK_t_ps_audit] PRIMARY KEY CLUSTERED  ([id_audit])
GO
PRINT N'Creating [dbo].[t_ps_credit_card]'
GO
CREATE TABLE [dbo].[t_ps_credit_card]
(
[id_payment_instrument] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_credit_card_type] [int] NOT NULL,
[nm_expirationdt] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_expirationdt_format] [int] NOT NULL,
[nm_startdate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_issuernumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO
PRINT N'Creating primary key [PK_t_ps_creditcard] on [dbo].[t_ps_credit_card]'
GO
ALTER TABLE [dbo].[t_ps_credit_card] ADD CONSTRAINT [PK_t_ps_creditcard] PRIMARY KEY CLUSTERED  ([id_payment_instrument])
GO
PRINT N'Creating [dbo].[t_ps_payment_instrument]'
GO
CREATE TABLE [dbo].[t_ps_payment_instrument]
(
[id_payment_instrument] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_payment_method_type] [int] NOT NULL,
[nm_account_number] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_first_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_middle_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_last_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_address1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_city] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nm_state] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_zip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_country] [int] NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_ps_payment_instrument] on [dbo].[t_ps_payment_instrument]'
GO
ALTER TABLE [dbo].[t_ps_payment_instrument] ADD CONSTRAINT [PK_t_ps_payment_instrument] PRIMARY KEY CLUSTERED  ([id_payment_instrument])
GO
PRINT N'Creating [dbo].[t_ps_preauth]'
GO
CREATE TABLE [dbo].[t_ps_preauth]
(
[id_preauth_tx_id] [nvarchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id_pymt_instrument] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dt_transaction] [datetime] NOT NULL,
[nm_invoice_num] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_invoice_date] [datetime] NULL,
[nm_po_number] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nm_description] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[n_currency] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[n_amount] [numeric] (18, 6) NOT NULL,
[n_request_params] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)

GO
PRINT N'Creating primary key [PK_t_ps_preauth] on [dbo].[t_ps_preauth]'
GO
ALTER TABLE [dbo].[t_ps_preauth] ADD CONSTRAINT [PK_t_ps_preauth] PRIMARY KEY CLUSTERED  ([id_preauth_tx_id])
GO

