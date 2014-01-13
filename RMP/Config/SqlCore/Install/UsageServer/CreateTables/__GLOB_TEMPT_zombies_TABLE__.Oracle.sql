
		  CREATE GLOBAL TEMPORARY TABLE t_zombiesTempTbl
		  (  
			id_instance number(10) NOT NULL,
			id_run number(10) NOT NULL
		  ) on commit preserve rows
		