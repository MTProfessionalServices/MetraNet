
    begin         
      insert into #t_svc_relations(id_svc, parent_id_svc)
		      select distinct id_svc, null from %%RERUN_TABLE_NAME%%
		      where id_parent_source_sess is null;
  
      insert into #t_svc_relations(id_svc, parent_id_svc)
			      select  distinct child.id_svc, parent.id_svc
			      from %%RERUN_TABLE_NAME%% child
			      inner join %%RERUN_TABLE_NAME%% parent
			      on child.id_parent_source_sess = parent.id_source_sess;
    end;			      

  