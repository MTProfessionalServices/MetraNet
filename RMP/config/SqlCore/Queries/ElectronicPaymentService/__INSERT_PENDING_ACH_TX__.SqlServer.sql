
                  INSERT INTO t_pending_ach_trans
                  (
                    id_payment_transaction,
                    n_days,
					id_payment_instrument,
					id_acc,
					n_amount,
					nm_description,
					dt_create,
					nm_ar_request_id
                  )
                  VALUES
                  (
                    N'%%ID_PAYMENT_TRANSACTION%%',
                    %%N_DAYS%%,
					N'%%ID_PAYMENT_INSTRUMENT%%',
					%%ID_ACC%%,
					%%N_AMOUNT%%,
					N'%%NM_DESCRIPTION%%',
					%%DT_CREATE%%,
					N'%%NM_AR_REQUEST_ID%%'
                  )

        