
			create procedure InsertIntoCatalogTable(@name nvarchar(200), @table_name nvarchar(200), @description nvarchar(4000),
					@UpdateMode varchar(1), @QueryPath nvarchar(4000),
					@CreateQueryTag nvarchar(200), @DropQueryTag nvarchar(200), @InitQueryTag nvarchar(200),
					@FullQueryTag nvarchar(200), @ProgId nvarchar(200),
					@IdRevision int, @Checksum varchar(100),
					@id_mv int output)
			as
			insert into t_mview_catalog(
			  name, table_name, description, update_mode, query_path,
			  create_query_tag, drop_query_tag, init_query_tag, full_query_tag,
			  progid, id_revision, tx_checksum)
		  values(
				@name, @table_name, @description, @UpdateMode, @QueryPath,
				@CreateQueryTag, @DropQueryTag, @InitQueryTag, @FullQueryTag,
				@ProgId, @IdRevision, @Checksum)
			set @id_mv = @@identity
		