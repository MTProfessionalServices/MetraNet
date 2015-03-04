if not exists(select 1 from sys.tables where name = 'agg_tax_out_param_map')
BEGIN
  PRINT N'CREATING TABLE AGG_TAX_OUT_PARAM_MAP'
  BEGIN TRY
    CREATE TABLE [dbo].[agg_tax_out_param_map](
	[id_tax_vendor] [int] NOT NULL,
    [id_view_in] [int] NOT NULL,
	[charge_name_in] [nvarchar](200) NOT NULL,
    [pv_table] [nvarchar](255) NOT NULL,
	[filter] [nvarchar](4000) NULL
    ) ON [PRIMARY] 
	END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH;
END
ELSE
  PRINT N'AGG_TAX_OUT_PARAM_MAP table exists'
