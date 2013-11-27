	   
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
		          
        end;

	  