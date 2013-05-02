
				CREATE PROC INSERT_%%ACCOUNT_VIEW_NAME%% @id_acc int, %%INPUTS%%
				AS INSERT INTO %%ACCOUNT_VIEW_NAME%% (id_acc, %%COLUMN_NAMES%%)
				VALUES (@id_acc, %%COLUMN_VALUES%%) IF ((@@error != 0) OR (@@rowcount 
				<> 1)) BEGIN SELECT -99 id_acc END SELECT @id_acc id_acc 
			