
        create procedure DeleteProductOffering(@poID int) as
        BEGIN
          /* Delete Extended Properties */
          declare @sqlStr nvarchar(255)
          declare @epTableName nvarchar(200)
          declare epTables cursor for
          select nm_ep_tablename from t_ep_map where id_principal= 100

          open epTables

          fetch next from epTables into @epTableName

          while @@FETCH_STATUS = 0
          BEGIN
            set @sqlStr = 'delete from ' + @epTableName + ' where id_prop = ' + cast(@poID as nvarchar(10))
            Execute (@sqlStr)

            fetch next from epTables into @epTableName
          END

          close epTables
          deallocate epTables

          /* Delete Account Type Restrictions */
          delete from t_po_account_type_map where id_po = @poID

          /* Retrieve ProductOffering Non-Shared Pricelist */
          declare @plID int 
          declare @status int
          select @plID = id_nonshared_pl from t_po where id_po = @poID

          declare @id_eff_date int, @id_avail_date int
          select @id_eff_date = id_eff_date from t_po where id_po = @poID
          select @id_avail_date = id_avail from t_po where id_po = @poID

          /* Delete ProductOffering */
          delete from t_po where id_po = @poID

          /* Delete ProductOffering Non-Shared Pricelist */
          exec sp_DeletePriceList @plID, @status

          print @status

          /* Delete ProductOffering base props */
          exec DeleteBaseProps @poID

          /* Delete effective and available dates */
          delete from t_effectivedate where id_eff_date = @id_eff_date
          delete from t_effectivedate where id_eff_date = @id_avail_date
        END
   