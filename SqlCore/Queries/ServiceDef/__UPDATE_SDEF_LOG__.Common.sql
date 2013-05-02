
		  update t_service_def_log set tx_checksum = '%%SDEF_CHECKSUM%%',
		  id_revision = id_revision + 1 where %%%UPPER%%%(nm_service_def)  = %%%UPPER%%%(N'%%SDEF_NAME%%')
	  