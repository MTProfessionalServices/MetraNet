
       create or replace procedure SetTariffs (p_id_enum_tariff IN varchar2,
       p_tx_currency IN nvarchar2)
       as
       v_id_enum_tariff char(1);
       begin
       select 'X' into v_id_enum_tariff from t_tariff where
          id_enum_tariff = p_id_enum_tariff and tx_currency = p_tx_currency;
       exception
           when NO_DATA_FOUND
         then
         insert into t_tariff (id_tariff, id_enum_tariff, tx_currency) values
         (seq_t_tariff.NextVal, p_id_enum_tariff, p_tx_currency) ;
      end;
       