
            CREATE VIEW VW_HIERARCHYNAME ( hierarchyname, id_acc )
            AS
            SELECT
              CASE
                WHEN (tac.c_firstname IS NULL OR tac.c_firstname = '') AND
					 (tac.c_lastname IS NULL OR tac.c_lastname = '') THEN mapper.nm_login
                WHEN tac.c_firstname IS NULL OR tac.c_firstname = '' THEN tac.c_lastname
                WHEN tac.c_lastname IS NULL OR tac.c_lastname = '' THEN tac.c_firstname
                ELSE (tac.c_firstname + (' ' + tac.c_lastname))
              END AS hierarchyname,
              mapper.id_acc id_acc
              FROM dbo.t_account_mapper mapper
              INNER JOIN dbo.t_namespace ns ON ns.nm_space = mapper.nm_space 
              INNER JOIN dbo.t_enum_data ed ON ed.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'
              LEFT OUTER JOIN t_av_contact tac ON tac.id_acc = mapper.id_acc AND tac.c_contacttype = ed.id_enum_data
              WHERE ns.tx_typ_space = 'SYSTEM_MPS'
          