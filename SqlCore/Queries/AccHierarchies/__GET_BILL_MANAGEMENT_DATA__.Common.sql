
          select nm_login, nm_space 
          from t_bill_manager imp
          inner join t_account_mapper map on imp.id_acc = map.id_acc
          where id_manager = %%ID_ACC%% and map.nm_space = '%%NM_SPACE%%'
        