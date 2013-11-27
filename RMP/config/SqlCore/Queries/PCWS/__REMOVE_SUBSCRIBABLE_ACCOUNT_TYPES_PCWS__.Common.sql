
        BEGIN
          delete from t_po_account_Type_map
          /* __REMOVE_SUBSCRIBABLE_ACCOUNT_TYPES_PCWS__ */
          WHERE  id_po = %%ID_PO%%;
        END;
           