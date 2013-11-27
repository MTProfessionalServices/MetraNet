
        if OBJECT_ID('%%RERUN_TABLE_NAME%%') IS NOT NULL
        begin
          if (select count(*) from %%RERUN_TABLE_NAME%%) > 10
            UPDATE STATISTICS %%RERUN_TABLE_NAME%% with fullscan
        end      
      