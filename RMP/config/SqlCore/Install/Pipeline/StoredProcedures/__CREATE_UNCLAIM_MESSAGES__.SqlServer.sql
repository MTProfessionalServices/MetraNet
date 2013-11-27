
CREATE PROCEDURE MTUnclaimMessages (@p_id_pipeline INT, @p_RowCount INT OUTPUT)
AS
BEGIN
    UPDATE T_MESSAGE 
        SET DT_ASSIGNED = NULL, 
            ID_PIPELINE = NULL 
    WHERE DT_COMPLETED IS NULL AND ID_PIPELINE = @p_id_pipeline
	SET @p_RowCount = @@ROWCOUNT
END
			