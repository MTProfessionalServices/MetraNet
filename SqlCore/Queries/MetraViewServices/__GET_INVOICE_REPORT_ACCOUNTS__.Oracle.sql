
        SELECT 
          accmap.id_acc as id_acc,
          accmap.nm_login as external_account_id,
          av.c_firstname as firstname,
          av.c_lastname as lastname,
          av.c_middleinitial as middleinitial,
          av.c_company as company,
          av.c_address1 as address1,
          av.c_address2 as address2,
          av.c_address3 as address3,
          av.c_city as city,
          av.c_state as state,
          av.c_zip as zip,
          av.c_country as country
        FROM
          t_account_mapper accmap
          INNER JOIN t_namespace space on accmap.nm_space=space.nm_space
					inner join t_enum_data ed on lower(ed.nm_enum_data) = 'metratech.com/accountcreation/contacttype/bill-to'
          LEFT OUTER JOIN t_av_contact av ON av.id_acc = accmap.id_acc
					and av.c_contacttype = ED.ID_enum_data
        WHERE
          accmap.id_acc in (:idAcc, :idPayer)
          AND lower(space.tx_typ_space)='system_mps'
        