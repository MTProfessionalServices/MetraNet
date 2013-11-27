
                  INSERT INTO t_pending_ach_trans_details
                  (
                    id_payment_transaction,
					nm_invoice_num,
					n_amount,
					dt_invoice,
					nm_po_number
                  )
                  VALUES
                  (
                    N'%%ID_PAYMENT_TRANSACTION%%',
					N'%%NM_INVOICE_NUM%%',
					%%AMOUNT%%,
					%%DT_INVOICE%%,
					N'%%NM_PO_NUMBER%%'
                  )

        