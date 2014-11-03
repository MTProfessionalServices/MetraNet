
			CREATE OR REPLACE force VIEW vw_hierarchyname (hierarchyname, id_acc) AS
				select 
					case when (tac.c_firstname is NULL OR tac.c_firstname = ' ') AND
							  (tac.c_lastname is NULL OR tac.c_lastname = ' ') then mapper.nm_login
					else case when tac.c_firstname is null OR tac.c_firstname = ' ' then translate(tac.c_lastname using nchar_cs)
					else case when tac.c_lastname is null OR tac.c_lastname = ' ' then translate(tac.c_firstname using nchar_cs)
					else translate(concat(tac.c_firstname,concat(' ',tac.c_lastname)) using nchar_cs)
			   end
			  end
				end as hierarchyname,
				mapper.id_acc id_acc
				from t_account_mapper mapper
					INNER JOIN t_namespace on upper(mapper.nm_space) = upper(t_namespace.nm_space)
					AND upper(t_namespace.tx_typ_space) = upper('system_mps')
					INNER JOIN t_enum_data ed on upper(ed.nm_enum_data) = upper('metratech.com/accountcreation/contacttype/bill-to')
					LEFT OUTER JOIN t_av_contact tac on tac.id_acc = mapper.id_acc AND
					tac.c_contacttype = ed.id_enum_data
				