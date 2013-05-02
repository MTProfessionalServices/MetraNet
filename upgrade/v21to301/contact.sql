				declare @id int
				select @id = id_enum_data from t_enum_data where 
				nm_enum_data = 'METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO' 
				insert into t_av_contact(id_acc,c_contacttype) select id_acc,@id from t_account
