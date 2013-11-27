
          CREATE OR REPLACE PROCEDURE getmaterializedviewquerytags (
          mv_name                 NVARCHAR2,
          op_type                 VARCHAR2,
          base_table_name         NVARCHAR2,
          updatetag         OUT   NVARCHAR2
          )
          AS
          foo   str_tab := dbo.csvtostrtab (base_table_name);
          BEGIN
          updatetag := NULL;

          delete from tmp_getmviewquerytags;

          INSERT INTO tmp_getmviewquerytags
          SELECT COLUMN_VALUE
          FROM TABLE (foo);

          FOR x IN
          (SELECT update_query_tag
          FROM t_mview_queries
          WHERE id_event =
          (SELECT DISTINCT mbt1.id_event
          FROM t_mview_base_tables mbt1 INNER JOIN t_mview_event c
          ON mbt1.id_event = c.id_event
          INNER JOIN t_mview_catalog d
          ON c.id_mv = d.id_mv
          WHERE NOT EXISTS (
          SELECT 1
          FROM t_mview_base_tables mbt2
          WHERE mbt1.id_event = mbt2.id_event
          AND NOT EXISTS (
          SELECT 1
          FROM tmp_getmviewquerytags f
          WHERE mbt2.base_table_name =
          f.COLUMN_VALUE))
          AND NOT EXISTS (
          SELECT 1
          FROM tmp_getmviewquerytags f
          WHERE NOT EXISTS (
          SELECT 1
          FROM t_mview_base_tables mbt2
          WHERE mbt1.id_event =
          mbt2.id_event
          AND mbt2.base_table_name =
          f.COLUMN_VALUE)
          )
          AND d.NAME = mv_name)
          AND operation_type = op_type)
          LOOP
          updatetag := x.update_query_tag;
          END LOOP;
          END getmaterializedviewquerytags;
        