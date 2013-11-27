
CREATE TABLE t_account_type_servicedef_map
(
  id_type number(10) NOT NULL,
  operation number(10) NOT NULL,
	id_service_def number(10) NOT NULL,
	CONSTRAINT pk_account_type_servicedef_map PRIMARY KEY (id_type, operation) 
) 
      