
insert into t_po_account_type_map
            (id_po, id_account_type)
   select %%ID_PO%%, id_type
     from t_account_type acctype
    where %%%UPPER%%% (name) = %%%UPPER%%% ('%%NAME%%')
      and not exists (
            select id_po, id_account_type
              from t_po_account_type_map atm 
				  inner join t_account_type acctype 
				  	on acctype.id_type = atm.id_account_type
             where id_po = %%ID_PO%%
               and %%%UPPER%%% (name) = %%%UPPER%%% ('%%NAME%%'))
           