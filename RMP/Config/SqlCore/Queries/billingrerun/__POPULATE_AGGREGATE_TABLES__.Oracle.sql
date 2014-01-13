
  begin
         declare numChildrenSvc number(10);
         begin
	      select count(*) into numChildrenSvc
	            from tmp_svc_relations
	            where parent_id_svc = %%ID_SVC%%;
	      if (numChildrenSvc > 0) then

	       begin
			    -- you could have some parents with no children at all (CR13174) which
			    -- would be missed in the original inner join. Changing the inner join
			    -- to left outer and adding the case statement fixes that.
			    
		        insert into tmp_aggregate (id_sess, id_parent_source_sess, sessions_in_compound)
			        select  seq_aggregate_%%RERUN_ID%%.nextval, t.id_parent_source_sess, t.sessions_in_compound
                    from (select rr_parent.id_source_sess as id_parent_source_sess, sum(case when rr_child.id_source_sess is null then 0 else 1 end) + 1 as sessions_in_compound
			        from %%RERUN_TABLE_NAME%% rr_parent
			        left join %%RERUN_TABLE_NAME%% rr_child
			        on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			        where rr_parent.id_parent_source_sess is null
			        and rr_parent.id_svc = %%ID_SVC%%
			        and rr_parent.tx_state = 'B'
			        group by rr_parent.id_source_sess
			        having count(*) < 400) t;
	           
			      insert into tmp_aggregate_large (id_sess, id_parent_source_sess, sessions_in_compound)
			        select  seq_aggregate_large_%%RERUN_ID%%.nextval, t.id_parent_source_sess, t.sessions_in_compound 
			        from (
                        select rr_parent.id_source_sess as id_parent_source_sess, count(*) + 1 as sessions_in_compound
			        from %%RERUN_TABLE_NAME%% rr_parent
			        inner join %%RERUN_TABLE_NAME%% rr_child
			        on rr_parent.id_source_sess = rr_child.id_parent_source_sess
			        where rr_parent.id_parent_source_sess is null
			        and rr_parent.id_svc = %%ID_SVC%% 
			        and rr_parent.tx_state = 'B'
			        group by rr_parent.id_source_sess
			        having count(*) >= 400) t	;
			      
	      END;
	      ELSE
	      begin
 	            
		        insert into tmp_aggregate(id_sess, id_parent_source_sess, sessions_in_compound)
			        select seq_aggregate_%%RERUN_ID%%.Nextval,
                    id_source_sess, 1
			                    from %%RERUN_TABLE_NAME%%
			                    where id_svc = %%ID_SVC%%
			                    and tx_state = 'B';
	                    
	      end;
	      end if;
	      end;
	      end;
	  