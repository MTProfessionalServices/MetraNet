
				DECLARE @col VARCHAR(1000),
					@type VARCHAR(100),
					@value NVARCHAR(1000),
					@delimiter VARCHAR(20),
					@delimiter_len INT,
					@nindex INT,
					@dindex INT,
					@cols_with_defaults NVARCHAR(MAX),
					@col_defaults NVARCHAR(MAX),
					@insertsql NVARCHAR(MAX),
					@selectsql NVARCHAR(MAX),
					@fromsql NVARCHAR(MAX)
				DECLARE @defaults TABLE (
					NAME NVARCHAR(100) PRIMARY KEY,
					VALUE NVARCHAR(1000)
				)
				DECLARE @backup_cols TABLE (
					NAME NVARCHAR(100) PRIMARY KEY
				)
				DECLARE bcsr CURSOR FAST_FORWARD FOR
					SELECT c.name col FROM sys.objects o
					INNER JOIN sys.columns c ON o.object_id = c.object_id
					WHERE o.name = '%%BACKUP_TABLE_NAME%%' AND USER_NAME(o.schema_id) = 'dbo'
					AND c.name NOT IN (%%QUOTED_CORE_COLUMN_LIST%%)
				DECLARE ncsr CURSOR FAST_FORWARD FOR
					SELECT c.name col, t.name ctype FROM sys.objects o
					INNER JOIN sys.columns c ON o.object_id = c.object_id
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
					WHERE o.name = '%%TABLE_NAME%%' AND USER_NAME(o.schema_id) = 'dbo'
					AND c.name NOT IN (%%QUOTED_CORE_COLUMN_LIST%%)

				SET @insertsql = 'insert into %%TABLE_NAME%% (%%CORE_COLUMN_LIST%% '
				SET @selectsql = ') select %%CORE_COLUMN_LIST%% '

				SET @cols_with_defaults = '%%COLUMN_DEFAULT_NAMES%%'
				SET @col_defaults = '%%COLUMN_DEFAULT_VALUES%%'

				SET @nindex = -1
				SET @dindex = -1
				SET @delimiter = '%%COLUMN_DEFAULT_DELIMITER%%'
				SET @delimiter_len = LEN(@delimiter)
				WHILE (LEN(@cols_with_defaults) > 0)
				BEGIN
					SET @nindex = CHARINDEX(@delimiter, @cols_with_defaults)
					SET @dindex = CHARINDEX(@delimiter, @col_defaults)
					IF (@nindex = 0) AND (LEN(@cols_with_defaults) > 0)
					BEGIN
						INSERT INTO @defaults (name, value) VALUES (@cols_with_defaults, @col_defaults)
						BREAK 
					END
					IF (@nindex > 1)
					BEGIN
						INSERT INTO @defaults (name, value) VALUES (LEFT(@cols_with_defaults, @nindex - 1), LEFT(@col_defaults, @dindex - 1))
						SET @cols_with_defaults = RIGHT(@cols_with_defaults, (LEN(@cols_with_defaults) - @nindex - @delimiter_len + 1))
						SET @col_defaults = RIGHT(@col_defaults, (LEN(@col_defaults) - @dindex - @delimiter_len + 1))
					END
					ELSE
					BEGIN
						SET @cols_with_defaults = RIGHT(@cols_with_defaults, (LEN(@cols_with_defaults) - @nindex))
						SET @col_defaults = RIGHT(@col_defaults, (LEN(@col_defaults) - @dindex))
					END
				END

				OPEN bcsr
				FETCH NEXT FROM bcsr INTO @col
				WHILE @@fetch_status = 0
				BEGIN
					INSERT INTO @backup_cols (name) VALUES (@col)
					FETCH NEXT FROM bcsr INTO @col
				END
				CLOSE bcsr
				DEALLOCATE bcsr

				OPEN ncsr
				FETCH NEXT FROM ncsr INTO @col, @type
				WHILE @@fetch_status = 0
				BEGIN
					SET @value = (SELECT NAME FROM @backup_cols WHERE NAME = @col)
					IF @value IS NOT NULL
					BEGIN
						SET @insertsql = @insertsql + ',' + @col
						SET @selectsql = @selectsql + ',convert(' + @type + ',' + @col + ')'
					END
					ELSE
					BEGIN
						SET @value = (SELECT VALUE FROM @defaults WHERE NAME = @col)
						IF @value IS NOT NULL
						BEGIN
							SET @insertsql = @insertsql + ',' + @col
							SET @selectsql = @selectsql + ',' + @value
						END
					END
					FETCH NEXT FROM ncsr INTO @col, @type
				END
				CLOSE ncsr
				DEALLOCATE ncsr

				SET @fromsql = ' from %%BACKUP_TABLE_NAME%%'
				--PRINT @insertsql + @selectsql + @fromsql
				EXECUTE(@insertsql + @selectsql + @fromsql)
			