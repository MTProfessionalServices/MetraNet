
                INSERT INTO t_ps_payment_instrument
                  (
                    id_payment_instrument,
                    n_payment_method_type,
                    nm_account_number,
                    nm_first_name,
                    nm_middle_name,
                    nm_last_name,
                    nm_address1,
                    nm_address2,
                    nm_city,
                    nm_state,
                    nm_zip,
                    id_country
                  )
                  VALUES
                  (
                    N'%%PAYMENT_INSTRUMENT_ID%%',
                    %%N_PAYMENT_METHOD_TYPE%%,
                    N'%%NM_ACCOUNT_NUMBER%%',
                    N'%%NM_FIRST_NAME%%',
                    N'%%NM_MIDDLE_NAME%%',
                    N'%%NM_LAST_NAME%%',
                    N'%%NM_ADDRESS1%%',
                    N'%%NM_ADDRESS2%%',
                    N'%%NM_CITY%%',
                    N'%%NM_STATE%%',
                    N'%%NM_ZIP%%',
                    %%NM_COUNTRY%%
                  )
        