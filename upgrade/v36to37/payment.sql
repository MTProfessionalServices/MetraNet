				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='T_PAYMENT_AUDIT'
				and a.id=c.constid
				and b.id=c.id

				select @stmt = N'alter table T_PAYMENT_AUDIT drop constraint ' + @name
				exec sp_executesql @stmt
go

ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_action] [nvarchar] (255)  NOT NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_routingnumber] [nvarchar] (9)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_lastfourdigits] [nvarchar] (4)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_accounttype] [nvarchar] (32)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_bankname] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_expdate] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [tx_IP_subscriber] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [tx_phone_number] [nvarchar] (30)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [tx_IP_CSR] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [id_CSR] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [tx_notes] [nvarchar] (255)  NULL
go

ALTER TABLE [dbo].[t_payment_audit] ADD CONSTRAINT [PK_t_payment_audit] PRIMARY KEY CLUSTERED  ([id_audit])
GO

ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_customer] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_address] [nvarchar] (255)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_city] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_state] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_zip] [nvarchar] (10)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_country] [nvarchar] (30)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_bankname] [nvarchar] (40)  NOT NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_reserved1] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_ach] ALTER COLUMN [nm_reserved2] [nvarchar] (40)  NULL
GO

ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_customer] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_address] [nvarchar] (255)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_city] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_state] [nvarchar] (20)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_zip] [nvarchar] (10)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_country] [nvarchar] (30)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_bankname] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_cardid] [nvarchar] (4)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_cardverifyvalue] [nvarchar] (4)  NULL
ALTER TABLE [dbo].[t_ps_creditcard] ALTER COLUMN [nm_pcard] [nvarchar] (1)  NULL
GO

				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='t_ps_pcard'
				and a.id=c.constid
				and b.id=c.id

				select @stmt = N'alter table t_ps_pcard drop constraint ' + @name
				exec sp_executesql @stmt
go
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_lastfourdigits] [nvarchar] (4)  NOT NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_customervatnumber] [nvarchar] (17)  NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_companyaddress] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_companypostalcode] [nvarchar] (10)  NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_companyphone] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_reserved1] [nvarchar] (40)  NULL
ALTER TABLE [dbo].[t_ps_pcard] ALTER COLUMN [nm_reserved2] [nvarchar] (40)  NULL
GO
ALTER TABLE [dbo].[t_ps_pcard] ADD CONSTRAINT [PK_t_ps_pcard] PRIMARY KEY CLUSTERED  ([id_acc], [nm_lastfourdigits], [id_creditcardtype])
Go

