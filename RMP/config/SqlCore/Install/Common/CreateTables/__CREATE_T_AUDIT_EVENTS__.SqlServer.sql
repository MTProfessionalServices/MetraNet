
			CREATE TABLE t_audit_events
			(
			id_auditevent int IDENTITY (1, 1) NOT NULL,
			id_Event int,
			id_desc int NULL,
			constraint pk_t_audit_events PRIMARY KEY(id_event)
			)
		