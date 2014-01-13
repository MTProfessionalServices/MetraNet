
				CREATE OR REPLACE PROCEDURE getmetadataforprops(
				p_tablename VARCHAR2,
				p_columnname VARCHAR2 DEFAULT NULL,
				p_cur out sys_refcursor)
				AS
				v_sql VARCHAR2(1000);
				BEGIN
				v_sql := 'select column_name as name,
				data_type as type,

				/* Determine data size */
				case
				when data_type in (''NVARCHAR2'', ''VARCHAR2'', ''NVARCHAR'', ''VARCHAR'', ''NCHAR'', ''CHAR'')
				then
				nvl(char_length,0)
				when data_type in (''RAW'') then
				nvl(data_length,0)
				else
				nvl(data_precision,0)
				end as length,
				nvl(data_scale, 0) as decplaces,
				(case nullable
				WHEN ''N'' THEN ''TRUE''
				WHEN ''Y'' THEN ''FALSE''  END )  as required,
				(select count(*) from user_tab_columns
				where table_name = upper(''' || p_tablename || ''')) as isRowType,
				(SELECT COMMENTS FROM USER_COL_COMMENTS WHERE  USER_COL_COMMENTS.TABLE_NAME = user_tab_columns.table_name AND USER_COL_COMMENTS.COLUMN_NAME = upper(''' || p_columnname || ''')) AS Description
				FROM user_tab_columns where table_name = upper(''' || p_tablename || ''')';

				IF(p_columnname IS NOT NULL and p_columnname != ' ') THEN
				v_sql := v_sql || ' AND column_name = upper(' || '''' || p_columnname || ''')';
				END IF;

				v_sql := v_sql || ' ORDER BY column_id';

				open p_cur for v_sql;
				END;
			