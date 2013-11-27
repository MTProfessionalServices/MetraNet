
      update t_account_view_log set tx_checksum = '%%AV_CHECKSUM%%',
      id_revision = id_revision + 1 where nm_account_view  = N'%%AV_NAME%%'
			