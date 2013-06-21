
CREATE TABLE [t_tax_input_%%ID_TAX_RUN%%](
                [id_tax_charge] [bigint] NOT NULL,
                [id_acc] [int] NOT NULL,
                [amount] [numeric](22, 10) NOT NULL,
                [invoice_date] [datetime] NOT NULL,
                [product_code] [varchar](255),
                [is_implied_tax] [varchar](1),
				[tax_informational] [varchar](1)
) 
      
