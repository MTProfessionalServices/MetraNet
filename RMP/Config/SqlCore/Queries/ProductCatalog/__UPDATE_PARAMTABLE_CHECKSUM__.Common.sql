
        UPDATE t_object_history
        SET tx_checksum = '%%CHECKSUM%%', n_version = 1
        WHERE (id_prop = %%ID_PARAM%%)
      