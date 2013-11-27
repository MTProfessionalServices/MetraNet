
      begin
	      delete from t_account_type_servicedef_map
	      where id_type in (
		      select id_type from t_account_type
		      where %%%UPPER%%%(name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%'));

	      delete from t_account_type_view_map
	      where id_type in (
		      select id_type from t_account_type
		      where %%%UPPER%%%(name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%'));

	      delete from t_acctype_descendenttype_map
	      where id_descendent_type in (
		      select id_type from t_account_type
		      where %%%UPPER%%%(name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%'));

        delete from t_acctype_descendenttype_map
        where id_type in (
            select id_type from t_account_type
            where upper(name) = upper('%%ACCOUNT_TYPE_NAME%%'));

	      delete t_account_type where %%%UPPER%%%(name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%');
      end;
			