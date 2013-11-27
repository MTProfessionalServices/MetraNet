
            CREATE TABLE [t_ar_bucket_def]
            (
              [id_bucket_def] [int] NOT NULL UNIQUE,
              [n_start_day] [int] NOT NULL UNIQUE,
              [n_end_day] [int] NOT NULL UNIQUE,
              [nm_desc] [varchar](20) NOT NULL
            )
				