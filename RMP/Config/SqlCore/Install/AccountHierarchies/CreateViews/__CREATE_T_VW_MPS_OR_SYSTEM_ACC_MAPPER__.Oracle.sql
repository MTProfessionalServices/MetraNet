
			 create or replace view VW_MPS_OR_SYSTEM_ACC_MAPPER as
			 SELECT mapper.nm_login, mapper.nm_space, mapper.id_acc,
			 (CASE WHEN tac.id_acc IS NULL
			 THEN translate('' using nchar_cs)
			 ELSE c_firstname || translate(' ' using nchar_cs) ||  c_lastname
			 END) AS fullname,
			 CASE WHEN (tac.c_firstname IS NULL OR tac.c_firstname = ' ') AND (tac.c_lastname IS NULL or tac.c_lastname = ' ')
			 THEN mapper.nm_login ||' (' || mapper.id_acc || ')'
			 WHEN tac.c_firstname IS NULL or tac.c_firstname = ' '
			 THEN tac.c_lastname ||' (' || mapper.id_acc || ')'
			 WHEN tac.c_lastname IS NULL or tac.c_lastname = ' '
			 THEN tac.c_firstname ||' (' ||  mapper.id_acc || ')'
			 ELSE tac.c_firstname ||  ' ' || tac.c_lastname|| ' (' || mapper.id_acc || ')'
			 END AS displayname,
			 CASE WHEN (tac.c_firstname IS NULL or tac.c_firstname = ' ') AND (tac.c_lastname IS NULL or tac.c_lastname = ' ')
			 THEN mapper.nm_login
			 WHEN tac.c_firstname IS NULL or tac.c_firstname = ' '
			 THEN tac.c_lastname
			 WHEN tac.c_lastname IS NULL or tac.c_lastname = ' '
			 THEN tac.c_firstname
			 ELSE tac.c_firstname || ' ' || tac.c_lastname
			 END AS hierarchydisplayname,
			 ns.tx_typ_space
			 FROM t_account_mapper mapper
			 INNER JOIN t_enum_data ed ON
			 UPPER(ed.nm_enum_data) = UPPER('METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO')
			 INNER JOIN t_namespace ns ON UPPER (mapper.nm_space) = UPPER(ns.nm_space)
			 AND (UPPER(ns.tx_typ_space) = UPPER('system_mps')
			 OR UPPER(ns.tx_typ_space) = UPPER('system_user')
			 OR UPPER(ns.tx_typ_space) = UPPER('system_auth'))
			 LEFT OUTER JOIN t_av_contact tac ON tac.id_acc = mapper.id_acc
			 AND tac.c_contacttype = ed.id_enum_data
		 