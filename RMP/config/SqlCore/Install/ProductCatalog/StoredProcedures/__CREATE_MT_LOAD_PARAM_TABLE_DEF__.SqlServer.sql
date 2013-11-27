
/* initialize the param table column definition array */
CREATE PROCEDURE mt_load_param_table_def(
    @v_id_pt int
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM #tmp_cached_param_defs WHERE id_pt = @v_id_pt)
	BEGIN
		INSERT INTO #tmp_cached_param_defs
		       (id_pt, nm_pt)
		SELECT @v_id_pt, nm_instance_tablename
		FROM   t_rulesetdefinition
		WHERE  id_paramtable = @v_id_pt
    
		EXEC mt_load_param_defs @v_id_pt
	END
END

