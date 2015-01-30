
            CREATE OR REPLACE FORCE VIEW VW_MPS_OR_SYSTEM_HIERARCHYNAME ( hierarchyname, id_acc, icon )
            AS
            SELECT
				case when (tac.c_firstname is NULL or tac.c_firstname = ' ') AND (tac.c_lastname is NULL or tac.c_lastname = ' ') then 
					mapper.nm_login
				else case when tac.c_firstname is null or tac.c_firstname = ' ' then
					translate(tac.c_lastname using nchar_cs)
				else case when tac.c_lastname is null or tac.c_lastname = ' ' then
					translate(tac.c_firstname using nchar_cs)
				else
					translate(concat(tac.c_firstname,concat(' ',tac.c_lastname)) using nchar_cs)
						end
					end
				end as hierarchyname,
              mapper.id_acc id_acc,
              'account.gif' AS icon
              FROM t_account_mapper mapper
              INNER JOIN t_namespace ns ON ns.nm_space = mapper.nm_space 
              INNER JOIN t_enum_data ed ON upper(ed.nm_enum_data) = upper('metratech.com/accountcreation/contacttype/bill-to')
              LEFT OUTER JOIN t_av_contact tac ON tac.id_acc = mapper.id_acc AND tac.c_contacttype = ed.id_enum_data
              WHERE ns.tx_typ_space IN ('system_mps', 'system_user')
          