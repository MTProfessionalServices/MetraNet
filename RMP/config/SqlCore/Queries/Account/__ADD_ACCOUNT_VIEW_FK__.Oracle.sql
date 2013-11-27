
execute immediate '
	alter table %%ACCOUNT_VIEW_NAME%% 
	add constraint %%FK_NAME%% foreign key (%%AV_COLUMN_NAME%%)
	references %%FORIEGN_TABLE%% (%%FORIEGN_COLUMN%%)';
			