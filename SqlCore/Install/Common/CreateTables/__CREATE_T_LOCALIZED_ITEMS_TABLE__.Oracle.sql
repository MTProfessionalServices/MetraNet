
CREATE TABLE t_localized_items
(
	id_local_type int NOT NULL,     /* Composite key: This is foreign key to t_localized_items_type.*/
	id_item int NOT NULL,			/* Composite key: Localize identifier. This is foreign key to t_recevent and other tables (see constraints) */
	id_lang_code int NOT NULL,      /* Composite key: Language identifier displayed on the MetraNet Presentation Server */
	tx_name VARCHAR2(255) NULL,   	/* The localized DisplayName */
	tx_desc VARCHAR2(2048) NULL,  	/* The localized Description */
CONSTRAINT PK_t_localized_items PRIMARY KEY (id_local_type, id_item, id_lang_code)
)