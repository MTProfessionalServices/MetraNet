
          select childtype.name as DescendentAccountTypeName
          from t_account_type atype
          inner join t_acctype_descendenttype_map childmap
          on atype.id_type = childmap.id_type
          inner join t_account_type childtype
          on childtype.id_type = childmap.id_descendent_type
          where %%%UPPER%%%(atype.name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%')
			