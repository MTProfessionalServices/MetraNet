
        BEGIN
          execute immediate 'drop table ' || :tableName;
          delete from t_dbname_hash where upper(name_hash) = upper(:tableName);
        END;
        