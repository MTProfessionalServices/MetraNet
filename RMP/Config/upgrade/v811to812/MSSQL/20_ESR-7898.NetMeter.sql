IF NOT EXISTS (
  SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[t_failed_transaction]') AND name = 'dt_Start_Resubmit'
)
BEGIN
      ALTER TABLE [dbo].[t_failed_transaction] Add dt_Start_Resubmit datetime2(7) NULL;
END
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.columns WHERE  object_id = OBJECT_ID(N'[dbo].[t_failed_transaction]') AND name = 'resubmit_Guid'
)
BEGIN
      ALTER TABLE [dbo].[t_failed_transaction] Add resubmit_Guid uniqueidentifier NULL;
END
GO




