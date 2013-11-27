
          SELECT 
            id_payment_instrument PaymentInstrumentID,
            id_acct AccountID,
            n_payment_method_type PaymentMethodType,
            nm_truncd_acct_num AccountNumber,
			tx_hash AccountNumberHash,
            id_creditcard_type CreditCardType,
            n_account_type AccountType,
            nm_exp_date ExpirationDate,
            nm_exp_date_format ExpirationDateFormat,
            nm_first_name FirstName,
		    nm_middle_name MiddleName,
		    nm_last_name LastName,
		    nm_address1 Street,
            nm_address2 Street2,
            nm_city City,
            nm_state State,
            nm_zip ZipCode,
            id_country Country,
            id_priority Priority,
            n_max_charge_per_cycle MaxChargePerCycle,
            dt_created
          FROM
	          t_payment_instrument
          WHERE
            id_acct = %%ACCOUNT_ID%%
            order by Priority
  
        