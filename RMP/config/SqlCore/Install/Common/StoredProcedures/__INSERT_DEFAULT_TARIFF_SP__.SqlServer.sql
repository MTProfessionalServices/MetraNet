
       create proc InsertDefaultTariff
       as
       declare @id int
       select @id = id_enum_data from t_enum_data where
          nm_enum_data = 'metratech.com/tariffs/TariffID/Default'
       insert into t_tariff (id_enum_tariff, tx_currency) values (@id, N'USD')
			 select @id = id_enum_data from t_enum_data where
					nm_enum_data = 'metratech.com/tariffs/TariffID/ConferenceExpress'
				insert into t_tariff(id_enum_tariff,tx_currency) values (@id, N'USD')
			 