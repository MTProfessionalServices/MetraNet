
				CREATE TABLE t_active_tickets (
				[id_ticket] [int] NOT NULL,
				[nm_salt] [nvarchar](255) NOT NULL,
				[id_acc] [int] NOT NULL,
				[nm_space] [nvarchar](255) NOT NULL,
				[nm_login] [nvarchar](255) NOT NULL,
				[n_lifespanminutes] [int] NOT NULL,
				[dt_create] [datetime] NOT NULL,
				[dt_expiration] [datetime] NOT NULL,
				id_lang_code int NOT NULL DEFAULT 840,
				CONSTRAINT [PK_t_active_tickets] PRIMARY KEY(id_ticket ASC))
			