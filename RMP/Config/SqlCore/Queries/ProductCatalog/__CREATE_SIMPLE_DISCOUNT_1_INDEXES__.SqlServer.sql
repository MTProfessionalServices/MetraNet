
/*  Create indexes on the temp table to speed up the next query */
CREATE INDEX ind_11 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_1 (id_usage_cycle)
CREATE INDEX ind_12 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_1 (dt_bill_start, dt_bill_end)
CREATE INDEX ind_13 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_1 (dt_sub_start)
CREATE INDEX ind_14 on %%%TEMP_TABLE_PREFIX%%%tmp_discount_1 (dt_sub_end)
