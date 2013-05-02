
        SELECT 'drop table '||' '||object_name as statement from user_objects where
        object_name like 'T_%' and object_type ='TABLE'
        