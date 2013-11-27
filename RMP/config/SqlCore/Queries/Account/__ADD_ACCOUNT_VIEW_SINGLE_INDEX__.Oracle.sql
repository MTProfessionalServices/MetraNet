
execute immediate '
	create index %%ACCOUNT_VIEW_NAME%%_%%INDEX_SUFFIX%%_ind 
	on %%ACCOUNT_VIEW_NAME%% (%%INDEX_COLUMNS%%)';
			