
		  CREATE GLOBAL TEMPORARY TABLE t_CanExecuteEventsTempTbl
		  (  
			id_instance number(10) NOT NULL,
			tx_display_name nvarchar2(255),
			tx_reason VARCHAR(80)
		  ) on commit preserve rows
		