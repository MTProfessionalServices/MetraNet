
        select id_type, name as AccountTypeName from t_po_account_Type_map map
        inner join t_account_type at on at.id_type = map.id_account_type
        where id_po = %%ID_PO%%
        