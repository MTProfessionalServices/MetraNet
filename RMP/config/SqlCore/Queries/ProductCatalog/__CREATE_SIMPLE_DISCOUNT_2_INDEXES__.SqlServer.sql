
/*  Temp table 1 no longer needed, drop it to release system resources */
TRUNCATE TABLE %%%TEMP_TABLE_PREFIX%%%tmp_discount_1

/*  Create indexes on temp table 2 */
CREATE INDEX ind_21 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 (id_acc)
CREATE INDEX ind_22 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_2 (dt_effdisc_start, dt_effdisc_end)
