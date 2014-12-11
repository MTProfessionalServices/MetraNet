
CREATE TABLE t_message_mapping( 
         id_message        NUMBER(10) NOT NULL, 
         id_origin_message NUMBER(10) NOT NULL,
         CONSTRAINT pk_t_message_mapping PRIMARY KEY (id_origin_message))

			