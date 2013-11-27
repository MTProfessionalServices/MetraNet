		
			IF EXISTS (SELECT 1 FROM fn_listextendedproperty(N'MS_Description', N'SCHEMA', N'dbo', N'TABLE', '%%TABLE_NAME%%', default, default))
			BEGIN
				EXEC sp_dropextendedproperty
					@name = N'MS_Description',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%'
			END
			
			IF EXISTS(SELECT 1 FROM sysobjects WHERE name = '%%TABLE_NAME%%' and xtype = 'U')
				EXEC sp_addextendedproperty
					@name = N'MS_Description',
					@value = '%%TABLE_DESCRIPTION%%',
					@level0type = N'SCHEMA', @level0name = N'dbo',
					@level1type = N'TABLE', @level1name = '%%TABLE_NAME%%'
				
		