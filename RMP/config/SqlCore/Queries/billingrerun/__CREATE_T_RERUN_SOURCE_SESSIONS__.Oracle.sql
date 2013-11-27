
		    begin
		      execute immediate 'Create Table %%TABLE_NAME%%
		            (	id_source_sess raw(16) PRIMARY KEY)';
		    end;
		    