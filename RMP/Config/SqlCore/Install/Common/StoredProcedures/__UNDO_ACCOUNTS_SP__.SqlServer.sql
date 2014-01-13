
	create proc UndoAccounts @id_acc int, @nm_login nvarchar(255), @nm_space nvarchar(40) as
         begin tran
           if exists (select * from t_account_mapper where id_acc = @id_acc)
             begin delete from t_account_mapper where id_acc = @id_acc end

           if exists (select * from t_account where id_acc = @id_acc)
             begin delete from t_account where id_acc = @id_acc end

           if exists (select * from t_acc_usage_cycle where id_acc = @id_acc)
             begin delete from t_acc_usage_cycle where id_acc = @id_acc end

           if exists (select * from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space)
             begin delete from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space end

           if exists (select * from t_acc_usage_interval where id_acc = @id_acc)
             begin delete from t_acc_usage_interval where id_acc = @id_acc end

           if exists (select * from t_site_user where nm_login = @nm_login)
			       begin delete from t_site_user where nm_login = @nm_login end

           if exists (select * from t_av_internal where id_acc = @id_acc)
             begin delete from t_av_internal where id_acc = @id_acc end
         commit tran
			 