
/* Initialize the param table column definition array */
CREATE PROCEDURE mt_load_param_defs(
	@v_id_pt int
)
AS
BEGIN
	/*DECLARE @l_nm_column_name      nvarchar(100)
	DECLARE @l_is_rate_key         int
	DECLARE @l_id_param_table_prop int*/

	INSERT INTO #tmp_param_defs(
	       id_pt,
		   nm_column_name,
		   is_rate_key,
		   id_param_table_prop
		   )
	SELECT @v_id_pt,
	       TPTP.nm_column_name,
		   CASE WHEN (CASE WHEN TPTP.b_columnoperator = 'N' THEN TPTP.nm_operatorval ELSE TPTP.b_columnoperator END) IS NULL THEN 0 ELSE 1 END AS is_rate_key,
		   TPTP.id_param_table_prop
	FROM   t_param_table_prop TPTP
	WHERE  TPTP.id_param_table = @v_id_pt

	/*OPEN l_cursor
	LOOP
	FETCH l_cursor INTO l_nm_column_name, l_is_rate_key, l_id_param_table_prop;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		l_param_def.nm_column_name := l_nm_column_name;
		l_param_def.is_rate_key := l_is_rate_key;
		l_param_def.id_param_table_prop := l_id_param_table_prop;
		v_param_defs (l_id_param_table_prop) := l_param_def;
	END

	CLOSE l_cursor
	DEALLOCATE l_cursor*/
END
