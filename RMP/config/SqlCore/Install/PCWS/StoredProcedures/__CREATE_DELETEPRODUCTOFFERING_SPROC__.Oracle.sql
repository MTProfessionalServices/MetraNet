
        create or replace procedure DeleteProductOffering(p_poID int) as
		  l_sqlStr varchar2(255);
          l_epTableName nvarchar2(200);
          l_epTables sys_refcursor;
          l_plID int;
          l_status int;
          l_id_eff_date int;
          l_id_avail_date int;
        BEGIN
          /* Delete Extended Properties */
          
          open l_epTables for select nm_ep_tablename from t_ep_map where id_principal= 100;

          LOOP
            fetch l_epTables into l_epTableName;
            EXIT when l_epTables%NOTFOUND;
          
            l_sqlStr := 'delete from ' || l_epTableName || ' where id_prop = ' || cast(p_poID as nvarchar2);
            execute immediate l_sqlStr;
          END LOOP;

          close l_epTables;

          /* Delete Account Type Restrictions */
          delete from t_po_account_type_map where id_po = p_poID;

          /* Retrieve ProductOffering Non-Shared Pricelist */
          select id_nonshared_pl into l_plID from t_po where id_po = p_poID;

          select id_eff_date into l_id_eff_date from t_po where id_po = p_poID;
          select id_avail into l_id_avail_date from t_po where id_po = p_poID;

          /* Delete ProductOffering */
          delete from t_po where id_po = p_poID;

          /* Delete ProductOffering Non-Shared Pricelist */
          sp_DeletePriceList( l_plID, l_status );

          /* Delete ProductOffering base props */
          DeleteBaseProps( p_poID);

          /* Delete effective and available dates */
          delete from t_effectivedate where id_eff_date = l_id_eff_date;
          delete from t_effectivedate where id_eff_date = l_id_avail_date;
        END;
		