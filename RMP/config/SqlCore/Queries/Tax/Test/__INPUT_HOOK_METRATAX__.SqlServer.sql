
USE [NetMeter]

CREATE TABLE [dbo].[t_tax_input_%%ID_TAX_RUN%%](
                [id_tax_charge] [int] NOT NULL,
                [id_acc] [int] NOT NULL,
                [amount] [numeric](22, 10) NOT NULL,
                [invoice_date] [datetime] NOT NULL,
                [product_code] [varchar](255) NOT NULL
) 

insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (1, 1702627707, 100.00, '2005-02-20', 'MT100')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (2, 1702627707, 100.00, '2006-02-20', 'MT105')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (3, 1253832471, 125.00, '2007-02-20', 'MT100')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (4, 1253832471, 125.00, '2008-02-20', 'MT105')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (5, 1912172346, 110.00, '2009-02-20', 'MT100')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (6, 1912172346, 110.00, '2010-02-20', 'MT105')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (7, 977188173, 100.00, '2011-02-20', 'MT100')
insert into t_tax_input_%%ID_TAX_RUN%%(id_tax_charge, id_acc, amount, invoice_date, product_code) values (8, 977188173, 200.00, '2012-02-20', 'MT105')
      