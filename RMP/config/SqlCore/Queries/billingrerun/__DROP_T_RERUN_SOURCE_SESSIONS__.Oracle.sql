
         begin
           if table_exists('%%TABLE_NAME%%') then
            execute immediate 'drop table %%TABLE_NAME%%';
           end if;
         end;
        