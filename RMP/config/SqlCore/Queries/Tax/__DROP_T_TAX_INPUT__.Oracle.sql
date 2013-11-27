
         begin
           if table_exists('t_tax_input_%%RUN_ID%%') then
            execute immediate 'drop table t_tax_input_%%RUN_ID%%';
           end if;
         end;
      