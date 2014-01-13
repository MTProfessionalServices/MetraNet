
        BEGIN
          delete from t_po_account_Type_map
          /* __REMOVE_SUBSCRIBABLE_ACCOUNT_TYPES__ */
          WHERE  id_po = %%ID_PO%%;
        END;
           