
				create or replace force  view
        vw_acc_po_restrictions AS
        select acc.id_acc, acc.id_type, atm.id_account_type as RestrictedToType, po.id_po
        from t_account acc, t_po po
        left outer join t_po_account_type_map atm on po.id_po = atm.id_po
        where 
        atm.id_account_type = acc.id_type or 
        atm.id_account_type is null
 		