
	select 
	/* __RESOLVE_ACC_TEMPLATE_PROPS__ */
	intermediate.id_ancestor id_ancestor, 
	intermediate.nm_ancestor_name,
	intermediate.nm_ancestor_name_space,
	intermediate.id_old_ancestor,
	ap.nm_prop, ap.nm_value, template_generations
	from
	(
		select aa.id_descendent, min(aa.num_generations) as template_generations, 		temptable.id_ancestor,
		temptable.nm_ancestor_name, temptable.nm_ancestor_name_space, 		temptable.id_old_ancestor, temptable.n_operation,
		temptable.dt_account_start, temptable.dt_hierarchy_start,
		temptable.id_acc_type
		from
		t_account_ancestor aa %%%READCOMMITTED%%%
		inner join t_acc_template atemp %%%READCOMMITTED%%% on aa.id_ancestor = atemp.id_folder
		inner join %%TEMPTABLE%% temptable %%%READCOMMITTED%%% on 			temptable.id_ancestor = aa.id_descendent AND
			temptable.id_acc_type = atemp.id_acc_type
		inner join t_enum_data ed ON ed.id_enum_data = temptable.n_operation				
		where 
		/* 1. If account is being created, then only get the template if account ancestor existed as of account creation date, or,
			   if account creation date was not specified (NULL), then make sure that startday(MetraTime), which is used as default start date for account)
			   falls into the same ancestor boundaries
			   2. If account is being updated, follow the same logic for dt_hierarchy_start date */
			((%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/ADD' 
       AND (CASE WHEN temptable.dt_account_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE temptable.dt_account_start END) between aa.vt_start and aa.vt_end) 
       OR	(%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/UPDATE' 
      AND (CASE WHEN temptable.dt_hierarchy_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE temptable.dt_hierarchy_start END) between aa.vt_start and aa.vt_end))
      AND
      /* Only get the records where ancestor id was specified */
		  temptable.id_ancestor IS NOT NULL
    
		group by aa.id_descendent,
		temptable.id_ancestor,
		temptable.nm_ancestor_name,
		temptable.nm_ancestor_name_space,
		temptable.id_old_ancestor,
		temptable.n_operation,
		temptable.dt_account_start,
		temptable.dt_hierarchy_start,
		temptable.id_acc_type
	) intermediate 
	inner join t_account_ancestor aa2 %%%READCOMMITTED%%% on intermediate.id_descendent=aa2.id_descendent 	and intermediate.template_generations = aa2.num_generations
	inner join t_acc_template a %%%READCOMMITTED%%% on a.id_folder = aa2.id_ancestor AND a.id_acc_type = intermediate.id_acc_type
	inner join t_acc_template_props ap %%%READCOMMITTED%%% on ap.id_acc_template=a.id_acc_template
	inner join t_enum_data ed ON ed.id_enum_data = intermediate.n_operation
	where 
		/* 1. If account is being created, then only get the template if account ancestor existed as of account creation date, or,
  	   if account creation date was not specified (NULL), then make sure that startday(MetraTime), which is used as default start date for account)
	     falls into the same ancestor boundaries
		   2. If account is being updated, follow the same logic for dt_hierarchy_start date */
			((%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/ADD' 
       AND (CASE WHEN intermediate.dt_account_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE intermediate.dt_account_start END) between aa2.vt_start and aa2.vt_end) 
       OR	(%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/UPDATE' 
      AND (CASE WHEN intermediate.dt_hierarchy_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE intermediate.dt_hierarchy_start END) between aa2.vt_start and aa2.vt_end))

	union

	select
	intermediate.id_acc id_ancestor,
	intermediate.nm_ancestor_name,
	intermediate.nm_ancestor_name_space,
	intermediate.id_old_ancestor,
	ap.nm_prop, ap.nm_value, template_generations
	from
	(
		select aa.id_descendent, min(aa.num_generations) as template_generations, 		map.id_acc,
		temptable.nm_ancestor_name, temptable.nm_ancestor_name_space, 		temptable.id_old_ancestor, temptable.n_operation,
		temptable.dt_account_start, 
		temptable.dt_hierarchy_start,
		temptable.id_acc_type
		from
		t_account_mapper map
		inner join t_account_ancestor aa %%%READCOMMITTED%%% ON aa.id_descendent = map.id_acc
		inner join t_acc_template atemp on aa.id_ancestor = atemp.id_folder
		inner join %%TEMPTABLE%% temptable %%%READCOMMITTED%%% 
			ON %%%UPPER%%%(map.nm_login) = %%%UPPER%%%(temptable.nm_ancestor_name) AND 					
			%%%UPPER%%%(map.nm_space) = %%%UPPER%%%(temptable.nm_ancestor_name_space) AND
			temptable.id_acc_type = atemp.id_acc_type
		inner join t_enum_data ed ON ed.id_enum_data = temptable.n_operation				
		where 
		/* 1. If account is being created, then only get the template if account ancestor existed as of account creation date, or,
  	   if account creation date was not specified (NULL), then make sure that startday(MetraTime), which is used as default start date for account)
	     falls into the same ancestor boundaries
		   2. If account is being updated, follow the same logic for dt_hierarchy_start date */
			((%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/ADD' 
       AND (CASE WHEN temptable.dt_account_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE temptable.dt_account_start END) between aa.vt_start and aa.vt_end) 
       OR	(%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/UPDATE' 
      AND (CASE WHEN temptable.dt_hierarchy_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE temptable.dt_hierarchy_start END) between aa.vt_start and aa.vt_end))
      AND
      /* Only get the records where ancestor id was not specified */
    temptable.id_ancestor IS NULL
		group by aa.id_descendent,
		map.id_acc, 
		temptable.nm_ancestor_name,
		temptable.nm_ancestor_name_space,
		temptable.id_old_ancestor,
		temptable.n_operation,
		temptable.dt_account_start,
		temptable.dt_hierarchy_start,
		temptable.id_acc_type
	) intermediate 
	inner join t_account_ancestor aa2 %%%READCOMMITTED%%% on intermediate.id_descendent=aa2.id_descendent 		and intermediate.template_generations = aa2.num_generations
	inner join t_acc_template a %%%READCOMMITTED%%% on a.id_folder = aa2.id_ancestor AND a.id_acc_type = intermediate.id_acc_type
	inner join t_acc_template_props ap %%%READCOMMITTED%%% on ap.id_acc_template=a.id_acc_template
	inner join t_enum_data ed ON ed.id_enum_data = intermediate.n_operation
			where 
		/* 1. If account is being created, then only get the template if account ancestor existed as of account creation date, or,
  	   if account creation date was not specified (NULL), then make sure that startday(MetraTime), which is used as default start date for account)
	     falls into the same ancestor boundaries
		   2. If account is being updated, follow the same logic for dt_hierarchy_start date */
			((%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/ADD' 
       AND (CASE WHEN intermediate.dt_account_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE intermediate.dt_account_start END) between aa2.vt_start and aa2.vt_end) 
       OR	(%%%UPPER%%%(ed.nm_enum_data) = 'METRATECH.COM/OPERATION/UPDATE' 
      AND (CASE WHEN intermediate.dt_hierarchy_start IS NULL THEN dbo.mtstartofday(%%%SYSTEMDATE%%%) ELSE intermediate.dt_hierarchy_start END) between aa2.vt_start and aa2.vt_end))

			