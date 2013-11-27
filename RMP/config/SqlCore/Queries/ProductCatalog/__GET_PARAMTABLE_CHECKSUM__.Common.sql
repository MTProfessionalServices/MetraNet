
        SELECT tx_checksum, n_version
        FROM t_object_history
        WHERE (id_prop = %%ID_PARAM%%)
      