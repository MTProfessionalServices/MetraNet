
                select 
                  nm_login CollectorName 
                from t_account_mapper map 
                inner join t_account acc on map.id_acc = acc.id_acc
                inner join t_account_state accState on acc.id_acc = accState.id_acc
                where 
                map.id_acc = %%ID_ACC%%
                and nm_space = 'system_user'
                and accState.status = 'AC'
					