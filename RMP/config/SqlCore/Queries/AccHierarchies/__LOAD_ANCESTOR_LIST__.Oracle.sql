
      SELECT 
	      id_ancestor, 
	      hn.hierarchyname as nm_login,
	      tat.name as AccountType, 
        (CASE WHEN tas.status IS NULL THEN 'AC' ELSE tas.status END) AccountStatus,
        (CASE WHEN tavi.c_Folder IS NULL THEN CAST(0 as CHAR(1)) ELSE tavi.c_Folder END) Folder
      FROM 
	      t_account_ancestor ans
	      inner join t_account_mapper tam on id_acc = ans.id_ancestor
        inner join t_namespace ns on tam.nm_space = ns.nm_space
        inner join t_account ta on tam.id_acc = ta.id_acc
        inner join t_account_type tat on tat.id_type = ta.id_type
	      left outer join t_account_state tas 
		      on tas.id_acc = tam.id_acc
			      AND %%REF_DATE%% between tas.vt_start AND tas.vt_end
	      left outer join t_av_internal tavi on tavi.id_acc = ta.id_acc
        inner join vw_mps_or_system_hierarchyname hn on ta.id_acc = hn.id_acc
      WHERE 
	      ans.id_descendent = %%DESCENDENT%% AND
          %%REF_DATE%% between ans.vt_start AND ans.vt_end
        /*  AND ans.num_generations <> 0 */
        and ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
      ORDER BY 
        num_generations desc
			