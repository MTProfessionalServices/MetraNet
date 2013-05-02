
				CREATE OR REPLACE PROCEDURE UPDATE_%%ACCOUNT_VIEW_NAME%%(temp_id_acc int, %%INPUTS%%)
				AS 
				BEGIN
					UPDATE %%ACCOUNT_VIEW_NAME%% set %%COLUMN_NAME_COLUMN_VALUE%%
					where id_acc = temp_id_acc;
				end; 
			