
      begin
          if table_exists('%%TMP_TABLE_NAME%%') then
              execute immediate 'DROP TABLE %%TMP_TABLE_NAME%%';
          end if;
          execute immediate 'CREATE TABLE %%TMP_TABLE_NAME%%
          (
              id_audit        number(10) NOT NULL,
              id_event        number(10) NULL,
              id_userid       number(10) NULL,
              id_entitytype   number(10) NULL,
              id_entity       number(10) NULL,
              tx_details      nvarchar2(2000) NULL,
              dt_crt          date NOT NULL
          )';  
      end;
			