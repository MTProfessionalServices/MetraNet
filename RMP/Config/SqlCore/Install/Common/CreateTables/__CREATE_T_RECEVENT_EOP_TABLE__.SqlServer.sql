
CREATE TABLE t_recevent_eop
(
	id_event integer  NOT NULL,
	id_cycle_type integer  NULL ,
	id_cycle integer  NULL ,
	CONSTRAINT PK_t_recevent_eop PRIMARY KEY  CLUSTERED (id_event ASC),
	CONSTRAINT FK1_t_recevent_eop FOREIGN KEY (id_event) REFERENCES t_recevent(id_event),
)
			 