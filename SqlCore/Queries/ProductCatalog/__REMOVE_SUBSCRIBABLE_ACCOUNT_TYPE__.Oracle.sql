
        /* __REMOVE_SUBSCRIBABLE_ACCOUNT_TYPE__ */
        declare v_count number(10);
        begin
        v_count := 0;
        SELECT count(id_po) into v_count from t_po_account_Type_map
        WHERE  id_po = %%ID_PO%% and id_account_type = %%ID_TYPE%%;
        if (v_count  > 0)
        then
          delete from t_po_account_Type_map
          WHERE  id_po = %%ID_PO%% and id_account_type = %%ID_TYPE%%;
        end if;
        end;
           