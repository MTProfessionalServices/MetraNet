
CREATE TABLE t_recevent_localize
(
	id_local int NOT NULL, 		 /* Localize identifier. This is foreign key to t_recevent */
	id_lang_code int NOT NULL,  /* Language identifier displayed on the MetraNet Presentation Server */
	tx_name VARCHAR2(255) NULL,  /* The localized DisplayName */
	tx_desc VARCHAR2(2048) NULL, /* The localized Description */
CONSTRAINT PK_t_recevent_localize PRIMARY KEY (id_local, id_lang_code)
)