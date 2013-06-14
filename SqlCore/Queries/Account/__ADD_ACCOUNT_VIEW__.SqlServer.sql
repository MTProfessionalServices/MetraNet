
          select * from t_account_type_view_map  vmap
            inner join t_enum_data ed
            on vmap.id_account_view = ed.id_enum_data
            where id_type = %%ACCOUNTTYPEID%% and ed.nm_enum_data = '%%ACCOUNTVIEWNAME%%'
          if (@@rowcount = 0) 
          begin
		        insert into t_account_type_view_map (id_type, id_account_view, account_view_name)
            select %%ACCOUNTTYPEID%%, id_enum_data, '%%REALACCOUNTVIEWNAME%%'
            from t_enum_data where nm_enum_data = '%%ACCOUNTVIEWNAME%%'
          end  
			