
          begin
            if table_exists('%%RERUN_TABLE_NAME%%') then
              declare cnt int;
              begin
                select count(*) into cnt from %%RERUN_TABLE_NAME%%;
                if cnt > 10 then
                    execute immediate 'ANALYZE TABLE %%RERUN_TABLE_NAME%% COMPUTE STATISTICS';  
                    /* EXEC DBMS_STATS.gather_table_stats('anagha', 't_rerun', estimate_percent => 100); */
                end if;    
              end ; 
            end if;
          end;
        