
CREATE TABLE t_billingserver_service
(
	id_billingserver int NOT NULL,
	id_svc int IDENTITY(1,1) NOT NULL,
	tt_start datetime NOT NULL,
	tt_end datetime,
	tt_lastheartbeat datetime,
	tt_nextheartbeatpromised datetime,
  CONSTRAINT PK_t_billingserver_service PRIMARY KEY CLUSTERED 
(
	id_billingserver ASC,
	id_svc ASC,
	tt_start ASC
)
)
			 