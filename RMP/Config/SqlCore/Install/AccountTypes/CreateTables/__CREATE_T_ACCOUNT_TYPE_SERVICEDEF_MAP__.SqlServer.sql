
CREATE TABLE t_account_type_servicedef_map
(
  id_type int NOT NULL,
  operation int NOT NULL,
	id_service_def int NOT NULL,
	CONSTRAINT pk_t_account_type_servicedef_map PRIMARY KEY CLUSTERED (id_type, operation) 
) 
      