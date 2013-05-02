
		begin
		   if object_exists ('seq_tmp_fail_txn_bulk_stat_upd') then
				execute immediate 'drop sequence seq_tmp_fail_txn_bulk_stat_upd';
		   end if;
		end;   
        