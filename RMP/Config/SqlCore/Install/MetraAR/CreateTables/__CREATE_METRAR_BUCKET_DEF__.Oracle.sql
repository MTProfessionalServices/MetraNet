
         CREATE TABLE t_ar_bucket_def
          (
            id_bucket_def Number(1) NOT NULL UNIQUE,
            n_start_day NUMBER(3) NOT NULL UNIQUE,
            n_end_day NUMBER(3) NOT NULL UNIQUE,
            nm_desc nvarchar2(20) NOT NULL
          )
            
				