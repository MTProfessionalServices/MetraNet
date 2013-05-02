
        IF EXISTS (
        /* __REMOVE_SUBSCRIBABLE_ACCOUNT_TYPE__ */
        SELECT id_po, id_account_type from t_po_account_Type_map
        WHERE  id_po = %%ID_PO%% and id_account_type = %%ID_TYPE%%)
        BEGIN
          delete from t_po_account_Type_map
          WHERE  id_po = %%ID_PO%% and id_account_type = %%ID_TYPE%%;
        END;
           