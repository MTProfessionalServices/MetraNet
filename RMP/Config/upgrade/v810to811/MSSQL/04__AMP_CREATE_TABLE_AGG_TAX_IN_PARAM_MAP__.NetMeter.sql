if not exists(select 1 from sys.tables where name = 'agg_tax_in_param_map')
BEGIN
  PRINT N'CREATING TABLE AGG_TAX_IN_PARAM_MAP'
  BEGIN TRY
    CREATE TABLE [dbo].[agg_tax_in_param_map](
	[id_tax_vendor] [int] NOT NULL,
	[tax_vendor_param] [nvarchar](200) NOT NULL,
	[id_view] [int] NOT NULL,
	[charge_name] [nvarchar](200) NOT NULL,
	[filter] [nvarchar](4000) NULL,
	[population_string] [nvarchar](4000) NULL,
	[default_value] [nvarchar](255) NULL,
	 CONSTRAINT [agg_tax_in_param_map1_pk] PRIMARY KEY CLUSTERED 
   (
	[id_tax_vendor] ASC,
	[tax_vendor_param] ASC,
	[id_view] ASC,
	[charge_name] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]  
  END TRY
  BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
  END CATCH;
END
ELSE
  PRINT N'AGG_TAX_IN_PARAM_MAP table exists'	    