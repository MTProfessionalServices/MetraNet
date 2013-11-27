
			   	IF EXISTS(SELECT 1 FROM sysobjects WHERE name = '%%TABLE_NAME%%' and xtype = 'U')
					EXEC sys.sp_addextendedproperty
						@name=N'MS_Description', @value='%%COLUMN_DESCRIPTION%%',
						@level0type=N'SCHEMA',@level0name=N'dbo',
						@level1type=N'TABLE',@level1name='%%TABLE_NAME%%',
						@level2type=N'COLUMN',@level2name='%%COLUMN_NAME%%'
				
			