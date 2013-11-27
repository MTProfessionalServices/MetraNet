
CREATE OR REPLACE PROCEDURE MTUnclaimMessages (p_id_pipeline t_pipeline.id_pipeline%TYPE, p_RowCount OUT INT)
AS
BEGIN
    UPDATE T_MESSAGE 
        SET DT_ASSIGNED = NULL, 
            ID_PIPELINE = NULL 
    WHERE DT_COMPLETED IS NULL AND ID_PIPELINE = p_id_pipeline;
    p_RowCount := sql%rowcount;
END;
			