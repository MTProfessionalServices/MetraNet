
CREATE TABLE t_recevent_eop
(
	id_event number(10)  NOT NULL,
	id_cycle_type number(10)  NULL ,
	id_cycle number(10)  NULL ,
	CONSTRAINT PK_t_recevent_eop PRIMARY KEY (id_event),
	CONSTRAINT FK1_t_recevent_eop FOREIGN KEY (id_event) REFERENCES t_recevent(id_event)
)
        