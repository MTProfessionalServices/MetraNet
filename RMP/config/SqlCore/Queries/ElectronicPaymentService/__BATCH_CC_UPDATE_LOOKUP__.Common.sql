
			  SELECT 
				  id_payment_instrument as PaymentInstrumentID,
				  id_acct as AccountID,
				  n_payment_method_type as PaymentMethodType,
				  nm_truncd_acct_num as AccountNumber,
				  id_creditcard_type as CreditCardType,
				  n_account_type as AccountType,
				  nm_exp_date as ExpirationDate,
				  nm_exp_date_format as ExpirationDateFormat,
				  nm_first_name as FirstName,
				  nm_middle_name as MiddleName,
				  nm_last_name as LastName,
				  nm_address1 as Street,
				  nm_address2 as Street2,
				  nm_city as City,
				  nm_state as State,
				  nm_zip as ZipCode,
				  id_country Country,
				  id_priority as Priority,
				  n_max_charge_per_cycle as MaxChargePerCycle,
				  dt_created
				FROM
					t_payment_instrument
			  