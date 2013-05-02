
      begin
        if table_exists('%%TMP_TABLE_NAME%%') then
          execute immediate 'DROP TABLE %%TMP_TABLE_NAME%%';
        end if;
      end;
    