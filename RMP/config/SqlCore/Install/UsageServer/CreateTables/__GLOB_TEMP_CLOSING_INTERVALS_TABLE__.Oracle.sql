
		 CREATE GLOBAL TEMPORARY TABLE closing_intervals 
		  (
			id_interval number(10) NOT NULL,
			id_usage_cycle number(10) NOT NULL,
			id_cycle_type number(10) NOT NULL,
			dt_start DATE NOT NULL,
			dt_end DATE NOT NULL,
			tx_interval_status VARCHAR2(1) NOT NULL
		  ) ON COMMIT PRESERVE ROWS
		 