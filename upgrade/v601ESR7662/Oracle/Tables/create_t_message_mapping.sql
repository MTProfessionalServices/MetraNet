CREATE TABLE t_message_mapping(
	id_message int NOT NULL,
	id_origin_message int NOT NULL
)
/

ALTER TABLE t_message_mapping ADD  CONSTRAINT pk_t_message_mapping PRIMARY KEY (id_origin_message) USING INDEX (CREATE INDEX pk_t_message_mapping ON  t_message_mapping (id_origin_message))
/