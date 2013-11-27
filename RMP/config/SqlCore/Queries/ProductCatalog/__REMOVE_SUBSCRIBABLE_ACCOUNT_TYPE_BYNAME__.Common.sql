
delete from t_po_account_type_map
      where exists(
            select id_po, id_account_type
            from   t_account_type acctype
            where  acctype.id_type = t_po_account_type_map.id_account_type
                   and id_po = %%ID_PO%%
                   and %%%UPPER%%%(name) = %%%UPPER%%%('%%NAME%%'))
           