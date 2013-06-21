
CREATE TABLE [t_tax_input_%%ID_TAX_RUN%%](
                [id_tax_charge] [bigint] NOT NULL IDENTITY(1,1), /* create a unique id for the charge*/
                [id_sess] [bigint] NOT NULL,                  /* Foreign key for source t_acc_usage/t_pv_audioconfconnection record*/
                [id_usage_interval] [int] NOT NULL,           /* Foreign key for source t_acc_usage/t_pv_audioconfconnection record*/
                [charge_name] varchar(255) NOT NULL,          /* Bridge or Transport charge in the t_pv_audioconfconnection*/
                [id_acc] [int] NOT NULL,
                [amount] [numeric](22, 10) NOT NULL,
                [invoice_date] [datetime] NOT NULL,
                [product_code] [varchar](255),
                [is_implied_tax] [varchar](1),
				[tax_informational] [varchar](1)
) 
      
