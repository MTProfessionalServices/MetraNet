
				if NOT EXISTS (select name 
							   from sysobjects 
							   where name = '%%TABLE_NAME%%' and xtype = 'U') 
				begin
				create table %%TABLE_NAME%% (
				id_acc INTEGER not null
				%%ADDITIONAL_COLUMNS%%,
				constraint pk_%%TABLE_NAME%% primary key clustered (
				id_acc
				%%PART_OF_KEY%%),
				constraint fk_%%TABLE_NAME%% foreign key (id_acc) references t_account)
				%%FOREIGN_CONSTRAINS%%
				%%SINGLE_INDEXES%%
				%%COMPOSITE_INDEXES%%

				%%CREATE_TABLE_DESCRIPTION%%				
				%%CREATE_COLUMNS_DESCRIPTION%%
				END

			   