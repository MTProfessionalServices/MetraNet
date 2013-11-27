
        UPDATE t_object_history
        set
          tx_checksum='%%CHECKSUM%%',
          n_version=1
        where
          nm_tablename = '%%TABLENAME%%'
      