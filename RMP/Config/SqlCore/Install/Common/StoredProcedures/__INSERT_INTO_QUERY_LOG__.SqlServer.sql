
			CREATE PROCEDURE InsertIntoQueryLog
			@groupid varchar(50),
			@viewid int,
			@old_schema varchar(8000),
			@query nvarchar(4000)
			AS

			INSERT INTO t_query_log (c_groupid, c_id_view, c_old_schema, c_query) values(@groupid, @viewid, @old_schema, @query)
		