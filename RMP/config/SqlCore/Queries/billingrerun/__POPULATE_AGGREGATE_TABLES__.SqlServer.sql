
      	declare @numChildrenSvc int
	      select @numChildrenSvc = count(*)
	            from #t_svc_relations
	            where parent_id_svc = %%ID_SVC%%
	      if (@numChildrenSvc > 0)
	      BEGIN
	
			    -- you could have some parents with no children at all (CR13174) which
			    -- would be missed in the original inner join. Changing the inner join
			    -- to left outer and adding the case statement fixes that.
			    
		        insert into #aggregate
			        select  rr_parent.id_source_sess, sum(case when rr_child.id_source_sess is null then 0 else 1 end) + 1
			        from %%RERUN_TABLE_NAME%% rr_parent
			        left join %%RERUN_TABLE_NAME%% rr_child
			        on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			        where rr_parent.id_parent_source_sess is null
			        and rr_parent.id_svc = %%ID_SVC%% 
			        and rr_parent.tx_state = 'B'
			        group by rr_parent.id_source_sess
			        having count(*) < 1000
	           
			      insert into #aggregate_large
			        select  rr_parent.id_source_sess, count(*) + 1
			        from %%RERUN_TABLE_NAME%% rr_parent
			        inner join %%RERUN_TABLE_NAME%% rr_child
			        on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			        where rr_parent.id_parent_source_sess is null
			        and rr_parent.id_svc = %%ID_SVC%% 
			        and rr_parent.tx_state = 'B'
			        group by rr_parent.id_source_sess
			        having count(*) >= 1000	
			      
	      END
	      ELSE
	      begin
 	            
		        insert into #aggregate
			        select id_source_sess, 1
			                    from %%RERUN_TABLE_NAME%%
			                    where id_svc = %%ID_SVC%%
			                    and tx_state = 'B'
	                    
	      end
	  