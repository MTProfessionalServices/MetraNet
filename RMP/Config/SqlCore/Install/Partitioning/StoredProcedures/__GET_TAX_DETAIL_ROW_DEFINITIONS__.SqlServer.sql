
                create proc GetTaxDetailRowDefinitions
                    @rowDefinitions varchar(1000) output
                    AS
                begin
                    set @rowDefinitions = 
                        '[id_tax_detail] [int] IDENTITY(1,1) NOT NULL,' +
                        '[id_tax_charge] [bigint] NOT NULL,' +
                        '[id_acc] [int] NOT NULL,' +
                        '[id_usage_interval] [int] NOT NULL,' +
                        '[id_tax_run] [int] NOT NULL,' +
                        '[dt_calc] [datetime] NOT NULL,' +
                        '[tax_amount] [decimal](22, 10) NOT NULL,' +
                        '[rate] [decimal](22, 10) NOT NULL,' +
                        '[tax_jur_level] [int] NOT NULL,' +
                        '[tax_jur_name] [nvarchar](255) NOT NULL,' +
                        '[tax_type] [int] NOT NULL,' +
                        '[tax_type_name] [nvarchar](255) NOT NULL,' +
                        '[is_implied] [nvarchar](10) NULL,' +
                        '[notes] [nvarchar](255) NULL';
                    return 0;
                end
                