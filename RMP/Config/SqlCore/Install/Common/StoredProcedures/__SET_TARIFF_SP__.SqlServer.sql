
			 create procedure SetTariffs (@id_enum_tariff varchar(255),
			 @tx_currency nvarchar (255))
			 as
			 if not exists (select * from t_tariff where id_enum_tariff =
			 @id_enum_tariff and tx_currency = @tx_currency)
			 begin
				 insert into t_tariff (id_enum_tariff, tx_currency) values (
				 @id_enum_tariff, @tx_currency)
			end
			 