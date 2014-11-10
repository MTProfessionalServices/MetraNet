
				create or replace force view vw_mps_acc_mapper as
				select
				mapper.nm_login,
				mapper.nm_space,
				mapper.id_acc,
				case when tac.id_acc is NULL then translate('' using nchar_cs) else
					concat(c_firstname,concat(' ',c_lastname)) end as fullname,
				case when (tac.c_firstname is NULL or tac.c_firstname = ' ') and (tac.c_lastname is NULL or tac.c_lastname = ' ')then
					concat(mapper.nm_login, CONCAT (' (', CONCAT (mapper.id_acc, ')')))
				else case when tac.c_firstname is null or tac.c_firstname = ' ' then
					translate(CONCAT (tac.c_lastname, CONCAT (' (', CONCAT (mapper.id_acc, ')'))) using nchar_cs)
				else case when tac.c_lastname is null or tac.c_lastname = ' ' then
					translate(CONCAT (tac.c_firstname, CONCAT (' (', CONCAT (mapper.id_acc, ')'))) using nchar_cs)
				else
					translate (CONCAT (concat(tac.c_firstname,concat(' ',tac.c_lastname)), CONCAT (' (', CONCAT (mapper.id_acc, ')'))) using nchar_cs)
              end
            end
			end as displayname,
			case when (tac.c_firstname is NULL or tac.c_firstname = ' ') and (tac.c_lastname is NULL or tac.c_lastname = ' ') then
				mapper.nm_login
			else case when tac.c_firstname is null or tac.c_firstname = ' ' then
				translate (tac.c_lastname using nchar_cs)
			else case when tac.c_lastname is null or tac.c_lastname = ' ' then
				translate (tac.c_firstname using nchar_cs)
            else
              translate (concat(tac.c_firstname,concat(' ',tac.c_lastname)) using nchar_cs)
            end
          end
        end as hierarchydisplayname,
        ns.tx_typ_space				
        from
				t_account_mapper mapper
				INNER JOIN t_namespace ns on upper(mapper.nm_space) = upper(ns.nm_space)
				AND lower(ns.tx_typ_space) = 'system_mps'
        INNER JOIN t_enum_data ed on lower(ed.nm_enum_data) = 'metratech.com/accountcreation/contacttype/bill-to'
				LEFT OUTER JOIN t_av_contact tac on tac.id_acc = mapper.id_acc AND
        tac.c_contacttype = ed.id_enum_data
