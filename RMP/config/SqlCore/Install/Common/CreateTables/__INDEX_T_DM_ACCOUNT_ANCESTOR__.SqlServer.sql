
				create clustered index idx_dm_account_ancestor on t_dm_account_ancestor(id_dm_descendent)
				create index idx1_dm_account_ancestor on t_dm_account_ancestor(id_dm_ancestor,num_generations)
			