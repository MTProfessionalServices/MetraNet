CREATE OR REPLACE PROCEDURE prtn_get_next_allow_run_date(
	current_datetime DATE DEFAULT SYSDATE,
	next_allow_run_date OUT DATE)
AS
    days_to_add INT;
BEGIN
	
	SELECT tuc.n_proration_length INTO days_to_add
	FROM   t_usage_server tus
	       INNER JOIN t_usage_cycle_type tuc
	            ON  tuc.tx_desc = tus.partition_type; 
	
	next_allow_run_date := current_datetime + days_to_add; 
	
END;
