
			 	CREATE DATABASE
					%%DATABASE_NAME%% ON (
					NAME = '%%DATA_DEVICE_NAME%%',
					FILENAME = '%%DATA_DEVICE_LOCATION%%',
					SIZE = %%DATA_DEVICE_SIZE%%
					)
					LOG ON (
						NAME = '%%LOG_DEVICE_NAME%%',
						FILENAME = '%%LOG_DEVICE_LOCATION%%',
						SIZE = %%LOG_DEVICE_SIZE%%
					)
			
			IF 'NetMeter' = '%%DATABASE_NAME%%'
			BEGIN
				EXEC NetMeter.sys.sp_cdc_enable_db 
			END