
				declare pragma autonomous_transaction;
				begin
				if not table_exists('%%TABLE_NAME%%') then 
				execute IMMEDIATE '
				create table %%TABLE_NAME%% (
				id_acc number(10) not null
				%%ADDITIONAL_COLUMNS%%,
				constraint pk_%%TABLE_NAME%% primary key  (
				id_acc
				%%PART_OF_KEY%%),
				constraint fk_%%TABLE_NAME%% foreign key (id_acc) references t_account)
				';

				%%FOREIGN_CONSTRAINS%%
				%%SINGLE_INDEXES%%
				%%COMPOSITE_INDEXES%%
				
				%%CREATE_TABLE_DESCRIPTION%%
				%%CREATE_COLUMNS_DESCRIPTION%%
				end if;
				end;
							