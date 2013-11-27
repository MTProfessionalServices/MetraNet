use %%NETMETER%%

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION

-- Start by cleaning up old versions of the objects being created here
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_payment_instrument_xref]') AND type in (N'U'))
DROP TABLE [dbo].[t_payment_instrument_xref]
GO

-- Resotre original t_payment_instrument_puid_xref
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[t_payment_instrument_puid_xref_old]') AND type in (N'U'))
BEGIN
	EXECUTE sp_rename N'dbo.t_payment_instrument_puid_xref_old', N't_payment_instrument_puid_xref', 'OBJECT' 
	
	alter table t_payment_instrument_puid_xref
	 add CONSTRAINT [FK_t_payment_instrument_puid_xref_t_payment_instrument] 
					FOREIGN KEY([id_payment_instrument])
					REFERENCES [dbo].[t_payment_instrument] ([id_payment_instrument])
END
GO


-- Create the new t_payment_instrument_xref table
CREATE TABLE [dbo].[t_payment_instrument_xref]
(
	[temp_acc_id] [int] NOT NULL,
	[nm_login] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[nm_space] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dt_created] [datetime] NOT NULL
	
	CONSTRAINT [PK_t_payment_instrument_xref] PRIMARY KEY CLUSTERED 
	(
		[temp_acc_id] ASC,
		[nm_login] ASC,
		[nm_space] ASC
	) 
)
GO

-- Lock the entire table so that we can work in peace
select * from t_payment_instrument_puid_xref with(TABLOCKX) where 0=1
GO

-- Insert the records with temporary id_acct values into new table
INSERT INTO t_payment_instrument_xref (temp_acc_id, nm_login, nm_space, dt_created) 
SELECT id_acct, PUID, 'microsoft.com/ols' nm_space, minDate
from 
	(select distinct tpi.id_acct, PUID, min(tpi.dt_created) minDate
		from
			t_payment_instrument_puid_xref xref
			inner join
			t_payment_instrument tpi on xref.id_payment_instrument = tpi.id_payment_instrument
		group by tpi.id_acct, PUID
	 ) subQuery
where id_acct < 0
GO

-- Drop the foreign key
IF EXISTS( select * from sys.objects where object_id = object_id('FK_t_payment_instrument_puid_xref_t_payment_instrument', 'F'))
	alter table t_payment_instrument_puid_xref
	 drop constraint FK_t_payment_instrument_puid_xref_t_payment_instrument
GO

-- Rename t_payment_instrument_puid_xref
EXECUTE sp_rename N'dbo.t_payment_instrument_puid_xref', N't_payment_instrument_puid_xref_old', 'OBJECT' 
GO

COMMIT