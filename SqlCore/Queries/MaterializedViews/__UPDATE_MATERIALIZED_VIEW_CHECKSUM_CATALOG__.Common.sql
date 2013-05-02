
			UPDATE t_mview_catalog SET tx_checksum = '%%MV_CHECKSUM%%',
			id_revision = id_revision + %%INCREMENT%% WHERE name = N'%%MV_NAME%%';
		