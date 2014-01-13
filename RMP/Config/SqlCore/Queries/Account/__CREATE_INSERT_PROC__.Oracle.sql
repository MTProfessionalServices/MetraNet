
				CREATE OR REPLACE PROCEDURE INSERT_%%ACCOUNT_VIEW_NAME%%(temp_id_acc int, %%INPUTS%%)
				AS 
				BEGIN
					INSERT INTO %%ACCOUNT_VIEW_NAME%% (id_acc, %%COLUMN_NAMES%%)
					VALUES (temp_id_acc, %%COLUMN_VALUES%%);
				END;	
				