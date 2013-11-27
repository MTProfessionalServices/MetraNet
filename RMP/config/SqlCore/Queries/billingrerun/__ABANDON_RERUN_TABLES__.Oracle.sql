	   
        begin
          
		           if object_exists ('seq_aggregate_large_%%RERUN_ID%%') then
                     exec_ddl ('drop sequence seq_aggregate_large_%%RERUN_ID%%');
               end if;

               if object_exists ('seq_aggregate_%%RERUN_ID%%') then
                     exec_ddl ('drop sequence seq_aggregate_%%RERUN_ID%%');
               end if;
               
               if object_exists ('seq_childss_%%RERUN_ID%%') then
                     exec_ddl ('drop sequence seq_childss_%%RERUN_ID%%');
               end if;
               
               if table_exists ('t_rerun_session_%%RERUN_ID%%') then 
                 exec_ddl ('drop table t_rerun_session_%%RERUN_ID%%'); end if;

               if table_exists ('t_source_rerun_session_%%RERUN_ID%%') then 
                 exec_ddl ('drop table t_source_rerun_session_%%RERUN_ID%%'); end if;
		          
               if table_exists ('t_UIDList_%%RERUN_ID%%') then 
                 exec_ddl ('drop table t_UIDList_%%RERUN_ID%%'); end if;
        end;

	  