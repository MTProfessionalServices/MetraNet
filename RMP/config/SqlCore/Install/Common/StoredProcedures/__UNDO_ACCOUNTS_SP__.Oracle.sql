
       create procedure UndoAccounts (p_id_acc IN int, p_nm_login IN nvarchar2,
        p_nm_space IN nvarchar2)
       as
       begin
       delete from t_account_mapper where id_acc = p_id_acc ;
       delete from t_account where id_acc = p_id_acc ;
       delete from t_acc_usage_cycle where id_acc = p_id_acc ;
       delete from t_user_credentials where upper(nm_login) = upper(p_nm_login) and upper(nm_space) = upper(p_nm_space) ;
       delete from t_acc_usage_interval where id_acc = p_id_acc ;
       delete from t_site_user where upper(nm_login) = upper(p_nm_login);
       delete from t_av_internal where id_acc = p_id_acc ;
       end;
       