
                -- t_tax_details doesn't exist yet, so create it unpartitioned
                -- 
                -- return 0 on success, 1 on failure
                create proc CreateUnpartitionedTaxDetailsTable
                as
                begin
                    -- Stored procedure return value
                    declare @ret int 
                    set @ret = 0

                    declare @taxDetailRowDefinitions varchar(1000)
                    exec GetTaxDetailRowDefinitions @taxDetailRowDefinitions out
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed GetTaxDetailRowDefinitions', 16, 1);
                        return 1
                    end

                    declare @createTableCommand varchar(1000)
                    set @createTableCommand = 'CREATE TABLE [t_tax_details](' +
                        @taxDetailRowDefinitions +
                        ') ON [PRIMARY]';
                    exec(@createTableCommand);
                    if (@@ERROR <> 0) 
                    begin
                        raiserror('Failed [%s]', 16, 1, @createTableCommand);
                        return 1
                    end

                    CREATE UNIQUE CLUSTERED INDEX TaxDetailIndex ON t_tax_details
                    (
                        id_usage_interval ASC,
                        id_acc ASC,
                        id_tax_detail ASC
                    ) ON [PRIMARY]
                        
                    return @ret
                end
                