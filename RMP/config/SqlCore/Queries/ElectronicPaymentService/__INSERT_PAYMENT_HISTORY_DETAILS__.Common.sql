
                  INSERT INTO t_payment_history_details
                  (
                    id_payment_transaction,
					id_payment_history_details,
					nm_invoice_num,
					dt_invoice_date,
					nm_po_number,
                    n_amount
                  )
                  VALUES
                  (
                    ?, ?, ?, ?, ?, ?
                  )

        