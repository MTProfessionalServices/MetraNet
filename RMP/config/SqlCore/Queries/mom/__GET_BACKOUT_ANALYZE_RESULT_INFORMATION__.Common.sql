 
				select d.tx_desc "View Name", count(*) Count, sum(amount) Amount, currency Currency from
				%%TABLE_NAME%% rr
				inner join t_description d 
				on rr.id_view = d.id_desc and d.id_lang_code = 840
				and %%%UPPER%%%(rr.tx_state) = 'A'
				group by currency, rr.id_view, d.tx_desc
 			