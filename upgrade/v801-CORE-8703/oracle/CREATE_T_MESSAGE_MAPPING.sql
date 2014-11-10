
 CREATE TABLE t_message_mapping( 
	 	    id_message int NOT NULL, 
	 	    id_origin_message int NOT NULL,
         CONSTRAINT pk_t_message_mapping PRIMARY KEY  (id_origin_message));
			