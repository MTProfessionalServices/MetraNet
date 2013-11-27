
    INSERT INTO t_reason_code (id_prop, tx_guid)
    VALUES(%%ID_PROP%%, rawtohex(hextoraw(replace('%%GUID%%','0x',''))))
  