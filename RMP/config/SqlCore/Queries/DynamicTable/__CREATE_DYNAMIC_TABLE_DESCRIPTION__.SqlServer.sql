
				EXEC sys.sp_addextendedproperty 
					@name=N'MS_Description', @value=N'%%TABLE_DESCRIPTION%%' , 
					@level0type=N'SCHEMA',@level0name=N'dbo', 
					@level1type=N'TABLE',@level1name=N'%%TABLE_NAME%%'
				
			