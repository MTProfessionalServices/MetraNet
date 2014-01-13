
				DECLARE
					pragma autonomous_transaction;

					TYPE defaults_table IS TABLE OF NVARCHAR2(1000) INDEX BY VARCHAR2(1000);
					TYPE backup_cols_table IS TABLE OF INT INDEX BY VARCHAR2(1000);

					defaults defaults_table;
					backup_cols backup_cols_table;

					value NVARCHAR2(1000);
					delimiter VARCHAR2(20);
					delimiter_len INT;
					nindex INT;
					dindex INT;
					cols_with_defaults NVARCHAR2(4000);
					col_defaults NVARCHAR2(4000);
					insertsql VARCHAR2(4000);
					selectsql VARCHAR2(4000);
					fromsql VARCHAR2(4000);

					CURSOR bcsr IS
						SELECT lower(c.column_name) as col FROM USER_TABLES o
						INNER JOIN USER_TAB_COLUMNS c ON o.table_name = c.table_name
						WHERE lower(o.table_name) = lower('%%BACKUP_TABLE_NAME%%')
						AND lower(c.column_name) NOT IN (%%QUOTED_CORE_COLUMN_LIST%%);
					brec bcsr%rowtype;

					CURSOR ncsr IS
						SELECT lower(c.column_name) as col, c.data_type as type FROM USER_TABLES o
						INNER JOIN USER_TAB_COLUMNS c ON o.table_name = c.table_name
						WHERE lower(o.table_name) = lower('%%TABLE_NAME%%')
						AND lower(c.column_name) NOT IN (%%QUOTED_CORE_COLUMN_LIST%%);
					nrec ncsr%rowtype;

				BEGIN
					insertsql := 'insert into %%TABLE_NAME%% (%%CORE_COLUMN_LIST%% ';
					selectsql := ') select %%CORE_COLUMN_LIST%% ';

					cols_with_defaults := '%%COLUMN_DEFAULT_NAMES%%';
					col_defaults := '%%COLUMN_DEFAULT_VALUES%%';

					nindex := -1;
					dindex := -1;
					delimiter := '%%COLUMN_DEFAULT_DELIMITER%%';
					delimiter_len := LENGTH(delimiter);

					WHILE (LENGTH(cols_with_defaults) > 0) LOOP
						nindex := INSTR(cols_with_defaults, delimiter);
						dindex := INSTR(col_defaults, delimiter);
						IF (nindex = 0) AND (LENGTH(cols_with_defaults) > 0) THEN
							defaults(cols_with_defaults) := col_defaults;
							EXIT;
						END IF;
						IF (nindex > 1) THEN
							defaults(SUBSTR(cols_with_defaults, 1, nindex - 1)) := SUBSTR(col_defaults, 1, dindex - 1);
							cols_with_defaults := SUBSTR(cols_with_defaults, -1 * (LENGTH(cols_with_defaults) - nindex - delimiter_len + 1));
							col_defaults := SUBSTR(col_defaults, -1 * (LENGTH(col_defaults) - dindex - delimiter_len + 1));
						ELSE
							cols_with_defaults := SUBSTR(cols_with_defaults, -1 * (LENGTH(cols_with_defaults) - nindex));
							col_defaults := SUBSTR(col_defaults, -1 * (LENGTH(col_defaults) - dindex));
						END IF;
					END LOOP;

					FOR brec IN bcsr LOOP
						backup_cols(brec.col) := 1;
					END LOOP;

					FOR nrec IN ncsr LOOP
						IF backup_cols.exists(nrec.col) THEN
							insertsql := insertsql || ',' || nrec.col;
							selectsql := selectsql || ',' ||
								case
								when upper(nrec.type) like '%CHAR%' then 'to_char(' || nrec.col || ')'
								when upper(nrec.type) like '%NUMBER%' then 'to_number(' || nrec.col || ')'
								when upper(nrec.type) like '%DATE%' then 'to_date(' || nrec.col || ')'
								end;
						ELSIF defaults.exists(nrec.col) THEN
							insertsql := insertsql || ',' || nrec.col;
							selectsql := selectsql || ',' || defaults(nrec.col);
						END IF;
					END LOOP;

					fromsql := ' from %%BACKUP_TABLE_NAME%%';
					EXECUTE IMMEDIATE insertsql || selectsql || fromsql;
					COMMIT;
				END;
			