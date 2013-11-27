
			CREATE PROCEDURE GetMetaDataForProps
			@tableName varchar(200),
			@columnName varchar(200) = null
			AS

			declare @sql varchar(1000)

			SET @sql = 'SELECT so.name name, systypes.name type, so.prec length, so.scale decplaces, (case so.isnullable WHEN 0 THEN ''TRUE''  WHEN 1 THEN ''FALSE''  END ) AS required,  '
			SET @sql = @sql + '(SELECT count(si.name) from syscolumns si inner join sysobjects on si.id = sysobjects.id where si.name like (so.name+''' +'_op' +''') AND sysobjects.name = ' +'''' +@tableName  +''') As isRowType,'
			SET @sql = @sql + '(SELECT TOP 1 value FROM sys.fn_listextendedproperty(N''MS_Description'', N''SCHEMA'', N''dbo'', N''TABLE'', sysobjects.name, N''Column'', so.name)) AS Description'
			SET @sql = @sql + '  from syscolumns so inner join sysobjects on so.id = sysobjects.id inner join systypes on systypes.xtype = so.xtype and systypes.xusertype = so.xusertype where '
			SET @sql = @sql + ' sysobjects.name = ' +'''' +@tableName +''''

			IF (@columnName is not null and @columnName <> '')
			BEGIN
				SET @sql = @sql + ' AND so.name = ' +'''' +@columnName +''''
			END

			SET @sql = @sql + ' ORDER BY so.colorder'

			exec (@sql)
		