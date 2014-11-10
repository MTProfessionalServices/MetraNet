
CREATE  PROCEDURE
UpdateAccPropsFromTemplate (
	@idAccountTemplate INTEGER,
	@accountId INTEGER = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @values nvarchar(max)
	DECLARE @viewName nvarchar(256)
	DECLARE @tableName nvarchar(256)
	DECLARE @additionalOptionString nvarchar(256)

	--SELECT list of account view by name of tables which start with 't_av'
	DECLARE db_cursor cursor for
		SELECT
			distinct(v.account_view_name)
			,'t_av_' + substring(td.nm_enum_data, charindex('/', td.nm_enum_data) + 1, len(td.nm_enum_data)) as tableName
			,CASE WHEN charindex(']', tp.nm_prop) <> 0
				  THEN substring(tp.nm_prop, charindex('[', tp.nm_prop)+ 1, charindex(']', tp.nm_prop) - charindex('[', tp.nm_prop) - 1)
				  ELSE ''
			 END as additionalOption
		FROM t_enum_data td
		JOIN t_account_type_view_map v on v.id_account_view = td.id_enum_data
		JOIN t_account_view_prop p on v.id_type = p.id_account_view
		JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name + '%' and tp.nm_prop like '%' + p.nm_name
		WHERE tp.id_acc_template = @idAccountTemplate

	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO @viewName, @tableName, @additionalOptionString

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @values = ''
		--"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
		SELECT @values = @values + CASE WHEN ROW_NUMBER() OVER(ORDER BY nm_column_name) = 1 THEN '' ELSE ',' END + nm_column_name + ' '
					+   case when nm_prop_class in(0, 1, 4, 5, 6, 8, 9, 12, 13) then ' = ''' + REPLACE(nm_value,'''','''''') + ''' '
								when nm_prop_class in(2, 3, 10, 11, 14)            then ' = ' + REPLACE(nm_value,'''','''''') + ' '
								when nm_prop_class = 7                             then case when upper(nm_value) = 'TRUE' then ' = 1 ' else ' = 0 ' END
								else ''''' '
						END
			FROM t_account_type_view_map v
			JOIN t_account_view_prop p on v.id_type = p.id_account_view
			JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name + '%' and tp.nm_prop like '%.' + REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
			WHERE tp.id_acc_template = @idAccountTemplate
				and tp.nm_prop like @viewName + '%'
			ORDER BY nm_column_name
		
		DECLARE @condition nvarchar(max)
		SET @condition = ''
		IF(@additionalOptionString <> '')
		BEGIN
			DECLARE @conditionItem nvarchar(max)
			DECLARE conditionCursor cursor for
			SELECT items FROM SplitStringByChar(@additionalOptionString,',')
			OPEN conditionCursor
			fetch next FROM conditionCursor into @conditionItem
			while @@FETCH_STATUS = 0
			BEGIN
				
				DECLARE @enumValue nvarchar(256)
				DECLARE @val1 nvarchar(256)
				DECLARE @val2 nvarchar(256)
				
				SET @val1 = substring(@conditionItem, 0, charindex('=', @conditionItem))
				
				SET @val2 = substring(@conditionItem, charindex('=', @conditionItem) + 1, len(@conditionItem) - charindex('=', @conditionItem) + 1)
				SET @val2 = replace(@val2, '_', '-')
				
				--Select value fot additional condition by namespace and name of enum.
				SELECT @enumValue = id_enum_data FROM t_enum_data
				WHERE nm_enum_data =
					(SELECT nm_space + '/' + nm_enum + '/'
					FROM t_account_type_view_map v JOIN t_account_view_prop p on v.id_type = p.id_account_view
					WHERE upper(account_view_name) = upper(@viewName) AND upper(nm_name) = upper(@val1)) + upper(@val2)
				
				--Creation additional condition for update account view properties for each account view.
				SET @condition = @condition + 'c_' + @val1 + ' = ' + convert(nvarchar, @enumValue) + ' AND '
				fetch next FROM conditionCursor into @conditionItem
			END
			close conditionCursor
			deallocate conditionCursor
		END
				
		DECLARE @dSql nvarchar(max)
		--Completion to creation dynamic sql-string for update account view.
		IF @accountId IS NULL BEGIN
			SET @condition = @condition + 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' + convert(nvarchar, @idAccountTemplate) + ')'
		END 
		ELSE BEGIN
			SET @condition = @condition + 'id_acc = ' + convert(nvarchar, @accountId) + ' '
		END
		SET @dSql = 'UPDATE ' + @tableName + ' SET ' + @values + ' WHERE ' + @condition
		execute(@dSql)
		fetch next FROM db_cursor into @viewName, @tableName, @additionalOptionString
	END

	close db_cursor
	deallocate db_cursor
END