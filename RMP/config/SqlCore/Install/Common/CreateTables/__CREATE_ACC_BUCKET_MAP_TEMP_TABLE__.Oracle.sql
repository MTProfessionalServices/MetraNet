
                CREATE GLOBAL TEMPORARY TABLE tmp_acc_bucket_map
                (
                id_interval number(10) NOT NULL
                ) on commit delete rows;

                CREATE UNIQUE INDEX idx_tmp_acc_bucket_map ON tmp_acc_bucket_map(id_interval);

                CREATE GLOBAL TEMPORARY TABLE tmp1_acc_bucket_map
                (
								id_acc number(10),
								bucket number(10),
								status varchar2(1),
								tt_start date,
								tt_end date) on commit delete rows;

