
	  begin
	    if table_exists('dm_t_acc_usage_summ') then
        execute immediate 'DROP TABLE dm_t_acc_usage_summ';
	    end if;
	  end;
	   