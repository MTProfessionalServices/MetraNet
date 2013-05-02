
        IF NOT EXISTS (
        /* __ADD_SUBSCRIBABLE_ACCOUNT_TYPE__ */
        SELECT id_po, id_account_type from t_po_account_Type_map
        WHERE  id_po = %%ID_PO%% and id_account_type = %%ID_TYPE%%)
        BEGIN
          insert into t_po_account_Type_map
          values (%%ID_PO%%, %%ID_TYPE%%);
        END;
           