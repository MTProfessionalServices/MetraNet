/* Upgrading t_acc_usage if exists */
DECLARE
    obj_count number;
BEGIN
    SELECT COUNT(1)
    INTO   obj_count
    FROM   user_objects
    WHERE object_name = 'T_ACC_USAGE' AND object_type = 'TABLE';

    IF (obj_count > 0) THEN

		UPDATE t_acc_usage
		SET    tax_inclusive = 'N'
		WHERE  tax_inclusive IS NULL;

		UPDATE t_acc_usage
		SET    tax_informational = 'N'
		WHERE  tax_informational IS NULL;

    	EXECUTE IMMEDIATE ' ALTER TABLE t_acc_usage
							ADD(
								   is_implied_tax CHAR NOT NULL,
								   tax_calculated_temp CHAR NOT NULL,
								   tax_informational_temp CHAR NOT NULL
							   )';

		EXECUTE IMMEDIATE ' UPDATE t_acc_usage
							SET    is_implied_tax = tax_inclusive,
								   tax_calculated_temp = tax_calculated,
								   tax_informational_temp = tax_informational';

    	EXECUTE IMMEDIATE 'ALTER TABLE t_acc_usage DROP (tax_inclusive, tax_calculated, tax_informational)';
    	EXECUTE IMMEDIATE 'ALTER TABLE t_acc_usage RENAME COLUMN tax_calculated_temp TO tax_calculated';
    	EXECUTE IMMEDIATE 'ALTER TABLE t_acc_usage RENAME COLUMN tax_informational_temp TO tax_informational';

    END IF;
END;
/
