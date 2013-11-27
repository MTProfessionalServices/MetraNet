
        SELECT  'alter table '||' '|| table_name||' '|| ' drop constraint '||' '||  constraint_name
  ||' '||'cascade' as statement from user_constraints  where constraint_type in ('U','C','P')
        