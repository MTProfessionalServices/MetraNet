
      create or replace PROCEDURE FILTERSORTQUERY_v2
      (
		  p_stagingDBName varchar2,
          p_tableName varchar2,
          p_InnerQuery nclob,
          p_OrderByText varchar2,
          p_StartRow number,
          p_NumRows number,
          p_TotalRows out sys_refcursor,
          p_Rows out sys_refcursor
      )
      AUTHID CURRENT_USER
      AS
       p_Sql varchar2(30000);
      BEGIN

          /* Create a temp table with all the selected records after the filter */
          p_Sql := 'create table ' || p_stagingDBName || '.' ||  p_tableName || ' as ' ||
                '( ' || p_InnerQuery || ')';

          exec_ddl(p_Sql);

          /* Get the total number of records after the filter */
          p_Sql := 'select count(*) as TotalRows from ' || p_stagingDBName || '.' || p_tableName;

          open p_TotalRows for p_Sql;

          /* If the results are to be paged, apply the page filter */
          if p_NumRows > 0 then
              p_Sql := 'select * from ( select rownum row_num, A.* from (select * from ' || p_stagingDBName || '.' || p_tableName ||
                  ' ' || p_OrderByText || ') A where rownum <= ' || (p_StartRow + p_NumRows) || ') where row_num >= ' || p_StartRow;
          else
              p_Sql := 'select * from ' || p_stagingDBName || '.' || p_tableName || ' ' || p_OrderByText;
          end if;

          /* Populate the results set */
          open p_Rows for p_Sql;

          /* Drop the temp table to clean up */
          exec_ddl('drop table ' || p_stagingDBName || '.' || p_tableName);
      END;
      