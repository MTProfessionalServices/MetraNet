CREATE OR REPLACE
PROCEDURE arch_q_p_clone_ind_and_cons(
	source_table		VARCHAR2,
	destination_tables	str_tab
)
authid current_user
AS
	pk_ddl				str_tab;
	uc_ddl				str_tab;
	idx_ddl				str_tab;
	random_string		VARCHAR2(10);
	sql_stmt			VARCHAR2(4000);
BEGIN

	/* Get ddl for all indexes from source table. */	
	SELECT	'create '
		|| DECODE(uniqueness, 'NONUNIQUE', ' ', 'UNIQUE')
		|| ' index ' || SUBSTR(index_name, 0, 20) || ':2 ' 
		|| ' on :1 '
		|| ' ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position)
		|| ')'
	BULK COLLECT INTO idx_ddl
		FROM (
                SELECT uic.index_name,
                       column_name,
                       column_position,
					   ui.uniqueness
                FROM   user_ind_columns uic
                       JOIN user_indexes ui
                            ON  uic.index_name = ui.index_name
                WHERE  LOWER(uic.table_name) = LOWER(source_table)
                ORDER BY uic.index_name
		)
	GROUP BY index_name, uniqueness;

	/* Get primary key constraint ddl from source table */
	SELECT	'alter table :1 '
		|| ' add constraint ' || SUBSTR(constraint_name, 0, 20) || ':2 '
		|| ' primary key ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY POSITION)
		|| ')'
	BULK COLLECT INTO pk_ddl
	FROM (
	         SELECT uc.constraint_name,
	                column_name,
					POSITION
	         FROM   user_cons_columns ucc
	                JOIN user_constraints uc
	                     ON  uc.constraint_name = ucc.constraint_name
	         WHERE  constraint_type = 'P'
	                AND LOWER(uc.table_name) = LOWER(source_table)
	     )
	GROUP BY constraint_name;

	/* Get unique constraint ddl from source table */
	SELECT	'alter table :1 '
		|| ' add constraint ' || SUBSTR(constraint_name, 0, 20) || ':2 '
		|| ' unique ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY POSITION)
		|| ')'
	BULK COLLECT INTO uc_ddl
	FROM (
	         SELECT uc.constraint_name,
	                column_name,
					POSITION
	         FROM   user_cons_columns ucc
	                JOIN user_constraints uc
	                     ON  uc.constraint_name = ucc.constraint_name
	         WHERE  constraint_type = 'U'
	                AND LOWER(uc.table_name) = LOWER(source_table)
	     )
	GROUP BY constraint_name;

	FOR i_tab IN destination_tables.FIRST .. destination_tables.LAST
	LOOP
		random_string := DBMS_RANDOM.string('x',10);

		DBMS_OUTPUT.put_line('		Clonning all indexes...');
		IF idx_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN idx_ddl.FIRST .. idx_ddl.LAST
		  LOOP
			 sql_stmt := idx_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

		DBMS_OUTPUT.put_line('		Clonning primary key...');
		IF pk_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN pk_ddl.FIRST .. pk_ddl.LAST
		  LOOP
			 sql_stmt := pk_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

		DBMS_OUTPUT.put_line('		Clonning unique constraints...');
		IF uc_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN uc_ddl.FIRST .. uc_ddl.LAST
		  LOOP
			 sql_stmt := uc_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

	END LOOP;
END;
