
			INSERT INTO %%%NETMETER_PREFIX%%%%%DST_TABLE_NAME%%(id_sess, id_usage_interval,%%COLUMN_LIST%%)
			SELECT id_sess, id_usage_interval, %%COLUMN_LIST%% FROM %%%NETMETERSTAGE_PREFIX%%%%%SRC_TABLE_NAME%% %%%READCOMMITTED%%%
		