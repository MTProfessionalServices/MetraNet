
          declare @parenttype int
          declare @childtype int

          select @parenttype = id_type from t_account_type where name = '%%PARENT_NAME%%'
          select @childtype = id_type from t_account_type where name = '%%DESC_NAME%%'

          if not exists( select 1 from t_acctype_descendenttype_map where id_type = @parenttype and id_descendent_type = @childtype)
          begin
            insert into t_acctype_descendenttype_map values (@parenttype, @childtype)
          end

			