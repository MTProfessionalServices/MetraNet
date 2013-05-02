
      select 
        atype.name as accountTypeName,
        atype.id_type as accountTypeID,
        acc.id_folder as templateFolderID,
        acc.dt_crt as templateDateCreated,
        acc.tx_name as templateName,
        acc.tx_desc as templateDesc,
	      acc.id_acc_template	as templateID
      from t_acc_template acc
      inner join t_account_type atype
        on acc.id_acc_type = atype.id_type
      where id_folder in
       (select id_folder
          from t_acc_template template
       		  INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
       		  INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
					WHERE id_descendent = %%ACCOUNTID%% 
					  AND %%REFDATE%% between vt_start AND vt_end and num_generations = 0)
				