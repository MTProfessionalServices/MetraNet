
          declare @taxVendor int;
          declare @id_usage_interval int;
          declare @id_tax_run int;
          declare @id_bill_group int;

          set @taxVendor = %%TAX_VENDOR%%
          set @id_tax_run = %%ID_TAX_RUN%%
          set @id_usage_interval = %%ID_USAGE_INTERVAL%%
          set @id_bill_group = %%ID_BILL_GROUP%%
      