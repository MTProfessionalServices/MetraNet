
/* 
  Proc: DupPartitionedTable

  Creates a partitioned version of a table.  Copies column types,
  null constraints, the data, the primary key, and non-unique
  indexes.
  
  Drops the non-partitioned source table.

*/
CREATE OR REPLACE
procedure DupPartitionedTable(
  p_tab varchar2  /* table to convert */
  )
authid current_user
AS
   cnt            INT;
   partn_tab      VARCHAR2 (30); /* temp name for new partitioned table */
   def_partn      VARCHAR2 (30); /* default partition name */
   partn_ddl      VARCHAR2 (4000);
   exchg_ddl      VARCHAR2 (4000);
   partn_clause   VARCHAR2 (100);
   ix             INT;
   idx_ddl        str_tab;
   cons_ddl       str_tab;
   cons_ddl1      str_tab;
   idx_drop       str_tab;
   cons_drop      str_tab;
   cons_drop1     str_tab;
   nl             CHAR (1)        := CHR (10);
   tab            CHAR (2)        := '  ';
   nlt            CHAR (3)        := nl || tab;
BEGIN
   DBMS_OUTPUT.put_line ('DupPartitionedTable: ' || p_tab);
                         /* Abort if system isn't enabled for partitioning */

   IF dbo.issystempartitioned () = 0
   THEN
      raise_application_error (-20000,
                               'System not enabled for partitioning.');
   END IF;

   /* Make sure this table isn't already partitioned */
   SELECT COUNT (1)
     INTO cnt
     FROM DUAL
    WHERE EXISTS (SELECT 1
                    FROM user_part_tables
                   WHERE UPPER (table_name) = UPPER (p_tab));

   IF cnt > 0
   THEN
      DBMS_OUTPUT.put_line (   'DupPartitionedTable: '
                            || p_tab
                            || ' is already partitioned.'
                           );
      RETURN;
   END IF;
/* 1. Gather ddl commands for partition table conversion      2. Execute ddl   */
/* Get the 'create table' ddl         Create DDL:         create table p_acc_usage           partition by range (id_usage_interval) (             partition d_acc_usage values less than (9999999999)             )                  Oracle defines range partitions using:            VALUES LESS THAN (<rangespec>)            The <rangespec> is one more than the value in id_interval_end        in t_partition for that partition and 9999999999 if it's the
default partition.
*/

   /* Temp name for new table, expecting name with form 't_whatever' */
   partn_tab := 'p' || SUBSTR (p_tab, 2);
   def_partn := 'd' || SUBSTR (p_tab, 2);
   /* ddl for partitioned table with default partition only */
   partn_ddl :=
         '  create table '
      || partn_tab
      || nlt
      || 'partition by range (id_usage_interval) ('
      || nlt
      || '    partition '
      || def_partn
      || ' values less than (9999999999))'
      || nlt
      || '  as select * from '
      || p_tab
      || ' where 1=0';
   /* ddl for exchange partition operation. the real convert step. */
   exchg_ddl :=
         'alter table '
      || partn_tab
      || ' exchange partition '
      || def_partn
      || ' with table '
      || p_tab;

   /* Get primary key constraint ddl from source table
   */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' primary key ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ')'
            || ' using index (create index '
            || constraint_name
            || ' on '
            || partn_tab
            || ' ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ') local)',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl,
            cons_drop
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'P'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get unique constraint ddl from source table */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' unique ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ')'
            || ' disable',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl1,
            cons_drop1
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'U'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get ddl for non-unique indexes on source table.
   */
   SELECT      'create index '
            || index_name
            || ' on '
            || partn_tab
            || ' ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ') local ',                  /* todo: logging or nologging ? */
            'drop index ' || index_name
   BULK COLLECT INTO idx_ddl,
            idx_drop
       FROM (SELECT   uic.table_name, uic.index_name, column_name,
                      column_position
                 FROM user_ind_columns uic JOIN user_indexes ui
                      ON uic.index_name = ui.index_name
                    AND ui.uniqueness = 'NONUNIQUE'
                WHERE LOWER (uic.table_name) = LOWER (p_tab)
             ORDER BY uic.table_name, uic.index_name, uic.column_position)
   GROUP BY table_name, index_name;

   /* Collected all the ddl statements we need, time to exec.

       1. Create new partitioned table with default partition only.
       2. Drop constraints from old table.
       3. Add constraints to new table (disabled)
       4. Exchange old table with the default partition
       5. Drop old table, rename new to old

   */

   /* Create new partitioned table with default partition only.
   */
   DBMS_OUTPUT.put_line (   'DupPartitionedTable: Creating partitioned table '
                         || partn_tab
                        );
   DBMS_OUTPUT.put_line (partn_ddl);

   EXECUTE IMMEDIATE partn_ddl;

   /* Drop constraints from old table.
   */
   DBMS_OUTPUT.put_line
               ('DupPartitionedTable: Dropping primary key/unique constraints');

   IF cons_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop.FIRST .. cons_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop (ix));

         EXECUTE IMMEDIATE cons_drop (ix);
      END LOOP;
   END IF;

   IF cons_drop1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop1.FIRST .. cons_drop1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop1 (ix));

         EXECUTE IMMEDIATE cons_drop1 (ix);
      END LOOP;
   END IF;

   DBMS_OUTPUT.put_line ('DupPartitionedTable: Dropping non-unique indexes');

   IF idx_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_drop.FIRST .. idx_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_drop (ix));

         EXECUTE IMMEDIATE idx_drop (ix);
      END LOOP;
   END IF;

   /* Add primary key/unqiue constraints  in disabled mode to avoid
      validation during exchange operation.  No need to build the
      underlying indexes at this moment.
   */
   DBMS_OUTPUT.put_line
      ('DupPartitionedTable: Adding primary key/unique constraints (disabled)');

   IF cons_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl.FIRST .. cons_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl (ix));

         EXECUTE IMMEDIATE cons_ddl (ix);
      END LOOP;
   END IF;

   IF cons_ddl1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl1.FIRST .. cons_ddl1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl1 (ix));

         EXECUTE IMMEDIATE cons_ddl1 (ix);
      END LOOP;
   END IF;

   /* Add non-unique local indexes
   */
   DBMS_OUTPUT.put_line
                     ('DupPartitionedTable: Creating non-unique local indexes');

   IF idx_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_ddl.FIRST .. idx_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_ddl (ix));

         EXECUTE IMMEDIATE idx_ddl (ix);
      END LOOP;
   END IF;

   DBMS_OUTPUT.put_line (   'DupPartitionedTable: Exchanging '
                         || p_tab
                         || ' and default partition'
                        );
   DBMS_OUTPUT.put_line ('  ' || exchg_ddl);

   EXECUTE IMMEDIATE exchg_ddl;

   /* Partiton table is created and loaded. Drop the old and rename new.
   */
   DBMS_OUTPUT.put_line ('DupPartitionedTable: Dropping table ' || p_tab);

   EXECUTE IMMEDIATE 'drop table ' || p_tab || ' cascade constraints purge';

   DBMS_OUTPUT.put_line (   'DupPartitionedTable: Renaming '
                         || partn_tab
                         || ' to '
                         || p_tab
                        );

   EXECUTE IMMEDIATE 'alter table ' || partn_tab || ' rename to ' || p_tab;
END duppartitionedtable;
   