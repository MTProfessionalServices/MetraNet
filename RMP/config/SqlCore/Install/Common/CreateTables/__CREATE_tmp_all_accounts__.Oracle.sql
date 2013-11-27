
         create global temporary table tmp_all_accounts
             (
                id_acc int NOT NULL,
                namespace nvarchar2(40) NOT NULL
             ) on commit preserve rows
        