
       create procedure InsertDefaultTariff
       as
       v_id t_enum_data.id_enum_data%TYPE;
       begin
           for i in (
                    select id_enum_data from t_enum_data where
                    upper(nm_enum_data) = UPPER('metratech.com/tariffs/TariffID/Default'))
           loop
            v_id := i.id_enum_data;
           end loop;
           insert into t_tariff (id_tariff, id_enum_tariff, tx_currency)
           values (seq_t_tariff.NextVal, v_id, 'USD');

           for i in (
               select id_enum_data from t_enum_data where
                  upper(nm_enum_data) = UPPER('metratech.com/tariffs/TariffID/ConferenceExpress'))
           loop
            v_id := i.id_enum_data;
           end loop;
           insert into t_tariff (id_tariff, id_enum_tariff, tx_currency)
           values (seq_t_tariff.NextVal, v_id, 'USD');
       end;
       