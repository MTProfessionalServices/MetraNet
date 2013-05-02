
				select 	acc.nm_login, contact.c_lastname, contact.c_firstname, c_phonenumber, 
					c_company, c_address1, c_city, c_state, c_zip, cdesc.tx_desc as [c_country]
				from 		t_account_mapper acc 
				inner join 	t_av_contact contact on acc.id_acc = contact.id_acc
				left outer join t_enum_data country on contact.c_country = country.id_enum_data
				left outer join t_description cdesc on country.id_enum_data = cdesc.id_desc
						and cdesc.id_lang_code = 840
				where acc.nm_login = '%%CUST_NO%%'	--%%START_DT%%,%%END_DT%%
			
			