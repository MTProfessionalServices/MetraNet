
         select 
                id_manager AdminID,
                bm.id_acc AccountID,
                m.nm_login BillManager,
                m1.nm_login BillManagee
         from t_bill_manager bm
         inner join t_account_mapper m on bm.id_manager = m.id_acc
         inner join t_account_mapper m1 on bm.id_acc = m1.id_acc
         
        