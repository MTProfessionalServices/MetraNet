
		BEGIN
			declare @%%MV_EXISTS_VAR%% int
			set @%%MV_EXISTS_VAR%% = %%MV_EXISTS_VALUE%%
			if OBJECT_ID('%%MV_TABLE_NAME%%') is null
			BEGIN
				%%CREATE_MV_QUERY%%
			end
			ELSE
			BEGIN
				-- We only need to throw error if MV does not exist, but table is present
				if (@%%MV_EXISTS_VAR%% = 0)
					raiserror('Table [%%MV_TABLE_NAME%%] already exists.',0,1)
			END
		END
		