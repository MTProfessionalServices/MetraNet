
UPDATE %%%TEMP_TABLE_PREFIX%%%tmp_discount_4 
SET amount = amount +
(
  SELECT
    adjustment    
  FROM
    %%%TEMP_TABLE_PREFIX%%%tmp_discount_5 tmp_5
	WHERE
	  tmp_5.id_group = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_group AND
		tmp_5.id_acc = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_acc AND
		tmp_5.id_pi_instance = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_pi_instance AND
    tmp_5.id_interval = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_interval
)
WHERE EXISTS
(
  SELECT 1 
	FROM 
	  %%%TEMP_TABLE_PREFIX%%%tmp_discount_5 tmp_5
	WHERE 
	  tmp_5.id_acc = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_acc AND
		tmp_5.id_group = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_group AND
		tmp_5.id_pi_instance = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_pi_instance AND
    tmp_5.id_interval = %%%TEMP_TABLE_PREFIX%%%tmp_discount_4.id_interval
)
