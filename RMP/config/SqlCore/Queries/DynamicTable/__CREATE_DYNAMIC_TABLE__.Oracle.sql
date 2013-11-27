
				declare pragma autonomous_transaction;
				BEGIN
				execute IMMEDIATE '			
			     CREATE TABLE %%TABLE_NAME%%
                                 (%%DDL_INNARDS%%,
				 CONSTRAINT %%PK_NAME%% PRIMARY KEY (%%PRIMARY_KEYS%%)
                                 %%FOREIGN_KEYS%%%%UNIQUE_KEYS%%)
	                         storage (initial 1024K next 1024K
				 minextents 1 maxextents UNLIMITED pctincrease 0)
				 ';
				 
				%%CREATE_TABLE_DESCRIPTION%%
				%%CREATE_COLUMN_DESCRIPTION%%
				END;

			