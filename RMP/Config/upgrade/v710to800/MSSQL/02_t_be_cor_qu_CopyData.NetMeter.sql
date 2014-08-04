SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO

PRINT N'Dropping extended properties'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_CustomDescription'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_CustomIdentifier'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_EndDate'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_QuoteID'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_StartDate'
GO

PRINT N'Renaming columns'
GO

EXEC sp_rename 't_be_cor_qu_quoteheader.c_CustomIdentifier', 'c_QuoteIdentifier', 'COLUMN';
GO
EXEC sp_rename 't_be_cor_qu_quoteheader.c_CustomDescription', 'c_QuoteDescription', 'COLUMN';
GO

PRINT N'Adding columns'
GO
ALTER TABLE dbo.t_be_cor_qu_quoteheader ADD 
  [c_GroupSubscription] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_CorporateAccountId] [bigint] NULL, 
  [c_ReportLink] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
  [c_TotalTax] [decimal] (22, 10) NULL,
  [c_Currency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_FailedMessage] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_Localization] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_EffectiveDate] [datetime] NULL,
  [c_EffectiveEndDate] [datetime] NULL,
  [c_IdQuote] [int] NOT NULL,
  [c_TotalAmount] [decimal] (22, 10) NULL,
  [c_ReportURL] [varbinary] (8000) NULL,
  [c_Status] [int] NULL,
  [c_StatusCleanup] [int] NULL,
  [c_StatusReport] [int] NULL,
  [c_AccountsInfo] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_POsInfo] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [c_QuoteCreationDate] [datetime] NULL;  
GO

PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_Description', 'String for display accounts in quote', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_AccountsInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Corporate AccountId for group subscription', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_CorporateAccountId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Currency of quote amount', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_Currency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date the quote is started', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date the quote is finished.', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_EffectiveEndDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Error message', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_FailedMessage'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates then quote is generated for group subscription', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_GroupSubscription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quoute number. Should be unique.', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_IdQuote'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Localization', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_Localization'
GO
EXEC sp_addextendedproperty N'MS_Description', 'String for display POs in quote', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_POsInfo'
GO
EXEC sp_addextendedproperty N'MS_Description', '', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_QuoteCreationDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Custom description', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_QuoteDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of quote', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_QuoteIdentifier'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Link to PDF file with report', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_ReportLink'
GO
EXEC sp_addextendedproperty N'MS_Description', 'URL to quote report file', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_ReportURL'
GO
EXEC sp_addextendedproperty N'MS_Description', '0 - None, 1 - In progress, 2 - Failed, 3 - Completed', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_Status'
GO
EXEC sp_addextendedproperty N'MS_Description', '0 - None, 1 - In progress, 2 - Failed, 3 - Completed', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_StatusCleanup'
GO
EXEC sp_addextendedproperty N'MS_Description', '0 - Skipped, 1 - In progress, 2 - Failed, 3 - Completed', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_StatusReport'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total sum of charges in quote', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_TotalAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total sum of taxes in quote', 'SCHEMA', N'dbo', 'TABLE', N't_be_cor_qu_quoteheader', 'COLUMN', N'c_TotalTax'
GO

PRINT N'Rebuilding [dbo].[t_be_cor_qu_quoteheader]'
GO
UPDATE dbo.t_be_cor_qu_quoteheader 
SET 
  c_reportlink = qc.c_reportlink,
  c_reporturl = qc.c_reportcontent,
  c_totalamount = qc.c_total,
  c_totaltax = qc.c_totaltax,  
  c_currency = qc.c_currency,  
  c_status = qc.c_status,
  c_effectivedate = qh.c_startdate,
  c_effectiveenddate = qh.c_enddate,
  c_idquote = qh.c_quoteid
FROM dbo.t_be_cor_qu_quoteheader qh 
  INNER JOIN dbo.t_be_cor_qu_quotecontent qc ON
    qh.c_QuoteHeader_Id = qc.c_QuoteHeader_Id;
GO

PRINT N'Deleting old objects'
GO
ALTER TABLE dbo.t_be_cor_qu_quoteheader DROP COLUMN c_StartDate, c_EndDate, c_QuoteID;
GO
ALTER TABLE dbo.t_be_cor_qu_quoteheader ALTER COLUMN [c_QuoteDescription] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL;
GO

DECLARE @SQLString NVARCHAR(500);
DECLARE @constrName VARCHAR(50);
SELECT @constrName = constraint_name FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE WHERE TABLE_NAME = 't_be_cor_qu_quoteicb' AND column_name = 'c_QuoteHeader_Id';
SET @SQLString = 'ALTER TABLE dbo.t_be_cor_qu_quoteicb DROP CONSTRAINT ' + @constrName;
EXECUTE sp_executesql @SQLString;
GO

ALTER TABLE dbo.t_be_cor_qu_quoteicb DROP COLUMN c_QuoteHeader_Id
GO

DROP TABLE [dbo].[t_be_cor_qu_quotecontent];
GO

IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END

ELSE PRINT 'The database update failed :('
GO
DROP TABLE #tmpErrors
GO
