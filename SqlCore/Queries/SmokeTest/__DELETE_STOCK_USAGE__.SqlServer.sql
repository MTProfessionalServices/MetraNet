
		BEGIN
			delete from %%%NETMETER_PREFIX%%%t_pv_stocks

			-- In case partitioning is enabled.
			declare @pt_enabled as nvarchar(10)
			select @pt_enabled = b_partitioning_enabled from t_usage_server
			if (@pt_enabled = 'Y' OR @pt_enabled = 'y')
			begin
				delete from %%%NETMETER_PREFIX%%%t_uk_stocktransaction
				delete from %%%NETMETER_PREFIX%%%t_uk_stockpo
			end
		END
		