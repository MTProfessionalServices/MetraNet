
        select count(*) as num_children_svcs
	          from tmp_svc_relations
	          where parent_id_svc = %%ID_SVC%%
	  