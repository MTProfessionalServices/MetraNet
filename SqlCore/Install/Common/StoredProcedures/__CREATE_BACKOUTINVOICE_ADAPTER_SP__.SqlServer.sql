
			create procedure mtsp_BackoutInvoices (

			@id_billgroup int,
			@id_run int,
			@num_invoices int OUTPUT,
			@info_string nvarchar(500) OUTPUT,
			@return_code int OUTPUT
			)

                  		as
			begin

				DECLARE @debug_flag bit
				DECLARE @msg nvarchar(256)
				DECLARE @usage_cycle_type int

          				SET @msg = 'Invoice-Backout: Invoice adapter reversed'
				SET @debug_flag = 1
				--SET @debug_flag = 0
				SET @info_string = ''

				set @usage_cycle_type = (select id_usage_cycle from t_usage_interval
							 where id_interval  IN (SELECT id_usage_interval
						                                               FROM t_billgroup
						                                               WHERE id_billgroup = @id_billgroup))/*= @id_interval*/

				select top 1 t_invoice.id_invoice from t_invoice left outer join t_usage_interval
 					on t_invoice.id_interval = t_usage_interval.id_interval
 					where id_usage_cycle = @usage_cycle_type
 					and t_invoice.id_interval > (SELECT id_usage_interval
						                                FROM t_billgroup
						                                WHERE id_billgroup = @id_billgroup)/*@id_interval*/
				if (@@rowcount > 0)
 					SET @info_string = 'Reversing the invoice adapter for this interval has caused the invoices for subsequent intervals to be invalid'

				--truncate the table so that all rows corresponding to this interval are removed

				DELETE FROM t_invoice
				WHERE
                                                            id_acc IN (SELECT bgm.id_acc
						    FROM t_billgroup_member bgm
						    WHERE bgm.id_billgroup = @id_billgroup) AND

	            	id_interval IN (SELECT id_usage_interval
			                                FROM t_billgroup
			                                WHERE id_billgroup = @id_billgroup)

				SET @num_invoices = @@ROWCOUNT

				--update the t_invoice_range table's id_run field

					UPDATE t_invoice_range
					SET id_run = @id_run
                                                            WHERE id_billgroup = @id_billgroup
                                                              AND id_run IS NULL

					IF @debug_flag = 1

					INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
					  VALUES (@id_run, 'Debug', @msg, getutcdate())

    					SET @return_code = 0

			end
		