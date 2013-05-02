
				CREATE PROC UPDATE_%%ACCOUNT_VIEW_NAME%% @id_acc int, %%INPUTS%%
				AS UPDATE %%ACCOUNT_VIEW_NAME%% set %%COLUMN_NAME_COLUMN_VALUE%%
				where id_acc = @id_acc
				IF ((@@error != 0) OR (@@rowcount <> 1)) BEGIN SELECT 
				-99 id_acc END SELECT @id_acc id_acc 
			