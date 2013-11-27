/* Upgrading t_acc_usage if exists on Stage Db */
DECLARE
    obj_count number;
BEGIN
    SELECT COUNT(1)
    INTO   obj_count
    FROM   user_objects
    WHERE object_name = 'T_ACC_USAGE' AND object_type = 'TABLE';

	/* [TODO] Remove "AND FALSE" */
    IF (obj_count > 0 AND FALSE) THEN
    	EXECUTE IMMEDIATE 'DROP INDEX idx_acc_ui_view_ind';
		EXECUTE IMMEDIATE 'CREATE INDEX idx_acc_ui_view_ind ON t_acc_usage(id_acc,id_view,id_usage_interval)';
    END IF;
END;
/
