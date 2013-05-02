
                update t_ps_payment_instrument set
                    n_payment_method_type = %%N_PAYMENT_METHOD_TYPE%%,
                    nm_account_number = N'%%NM_ACCOUNT_NUMBER%%',
                    nm_first_name = N'%%NM_FIRST_NAME%%',
                    nm_middle_name = N'%%NM_MIDDLE_NAME%%',
                    nm_last_name = N'%%NM_LAST_NAME%%',
                    nm_address1 = N'%%NM_ADDRESS1%%',
                    nm_address2 = N'%%NM_ADDRESS2%%',
                    nm_city = N'%%NM_CITY%%',
                    nm_state = N'%%NM_STATE%%',
                    nm_zip = N'%%NM_ZIP%%',
                    id_country = %%NM_COUNTRY%%
                where 
                  id_payment_instrument  = N'%%PAYMENT_INSTRUMENT_ID%%'
        