
			create procedure GetMaterializedViewQueryTags(@mv_name nvarchar(1000),
													      @operation_type varchar(1),
													      @base_table_name nvarchar(4000),
														  @UpdateTag nvarchar(200) output)
			as
			if object_id( 'tempdb..#foo' ) is not null DROP TABLE #foo
			create table #foo(name varchar(128))
			WHILE CHARINDEX(',', @base_table_name) > 0
			BEGIN
				INSERT INTO #foo (name)
                SELECT SUBSTRING(@base_table_name,1,(CHARINDEX(',', @base_table_name)-1))
                SET @base_table_name = SUBSTRING (@base_table_name, (CHARINDEX(',', @base_table_name)+1),
                                                  (LEN(@base_table_name) - (CHARINDEX(',', @base_table_name))))
            END

            declare @id_event int
            INSERT INTO #foo (name) SELECT @base_table_name
			SELECT DISTINCT @id_event = mbt1.id_event from t_mview_base_tables mbt1
				inner join t_mview_event c on mbt1.id_event = c.id_event
				inner join t_mview_catalog d on c.id_mv = d.id_mv
				where not exists
				(select 1
				 from t_mview_base_tables mbt2
                 where mbt1.id_event = mbt2.id_event
				 and not exists (select 1 from #foo where
							     mbt2.base_table_name = #foo.name
                                )
				)
				and not exists
				(select 1 from #foo where not exists (select 1 from t_mview_base_tables mbt2
													  where mbt1.id_event = mbt2.id_event
													  and mbt2.base_table_name = #foo.name
												     )
			    )
				and d.name = @mv_name

				SELECT @UpdateTag = update_query_tag
				FROM t_mview_queries where id_event=@id_event and operation_type = @operation_type
		