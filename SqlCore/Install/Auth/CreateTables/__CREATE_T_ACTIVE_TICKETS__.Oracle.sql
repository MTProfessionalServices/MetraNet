
       CREATE TABLE t_active_tickets (
		id_ticket number(10) NOT NULL,
		nm_salt nvarchar2(2000) NOT NULL,
		id_acc number(25) NOT NULL,
		nm_space nvarchar2(255) NOT NULL,
		nm_login nvarchar2(255) NOT NULL,
		n_lifespanminutes number(10) NOT NULL,
		dt_create date NOT NULL,
		dt_expiration date NOT NULL,
		id_lang_code number(10) NOT NULL DEFAULT 840
       CONSTRAINT PK_t_active_tickets PRIMARY KEY (id_ticket)) 