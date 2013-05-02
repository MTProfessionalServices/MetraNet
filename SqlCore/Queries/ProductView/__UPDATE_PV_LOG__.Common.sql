
      update t_product_view_log set tx_checksum = '%%PV_CHECKSUM%%',
      id_revision = id_revision + 1 where nm_product_view = N'%%PV_NAME%%'
			