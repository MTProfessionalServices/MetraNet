
        create or replace procedure mtsp_BackoutInvoices (
            p_id_billgroup int,
            p_id_run int,
            p_num_invoices OUT int ,
            p_info_string OUT nvarchar2,
            p_return_code OUT int
        )
        as
            v_count number:=0;
            p_debug_flag number(1) := 1;
            p_msg nvarchar2(256) := 'Invoice-Backout: Invoice adapter reversed';
            p_usage_cycle_type int;

        begin

            /* SET p_debug_flag = 0 */
            p_info_string := NULL;
            for i in (select id_usage_cycle from t_usage_interval
               							 where id_interval  IN (SELECT id_usage_interval
						                                               FROM t_billgroup
						                                               WHERE id_billgroup = p_id_billgroup))
            loop
                p_usage_cycle_type := i.id_usage_cycle ;
            end loop;

            for i in (select t_invoice.id_invoice from t_invoice left outer join t_usage_interval
                on t_invoice.id_interval = t_usage_interval.id_interval
                where id_usage_cycle = p_usage_cycle_type
 					and t_invoice.id_interval > (SELECT id_usage_interval
						                                FROM t_billgroup
						                                WHERE id_billgroup = p_id_billgroup))
            loop
                v_count := v_count + 1;
            end loop;
            if (v_count > 0) then
                p_info_string := 'Reversing the invoice adapter for this interval has caused the invoices for subsequent intervals to be invalid';
            end if;

            /* truncate the table so that all rows corresponding to this interval are removed */
						DELETE FROM t_invoice
						WHERE id_acc IN (SELECT bgm.id_acc
						    FROM t_billgroup_member bgm
						    WHERE bgm.id_billgroup = p_id_billgroup) AND
	            	id_interval IN (SELECT id_usage_interval
			                                FROM t_billgroup
			                                WHERE id_billgroup = p_id_billgroup);
            p_num_invoices := v_count;
            /* update the t_invoice_range table's id_run field */
                UPDATE t_invoice_range
                    SET id_run = p_id_run 
		WHERE id_billgroup = p_id_billgroup
		  AND id_run IS NULL;
                IF p_debug_flag = 1 then
                    INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
                      VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', p_msg, dbo.getutcdate);
                end if;

                p_return_code := 0;

        end;
        