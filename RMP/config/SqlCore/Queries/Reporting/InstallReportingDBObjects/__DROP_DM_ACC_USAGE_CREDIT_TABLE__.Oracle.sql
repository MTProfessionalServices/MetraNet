
	  begin
	    if table_exists('dm_t_acc_usage_credit') then
        execute immediate 'DROP TABLE dm_t_acc_usage_credit';
	    end if;
	  end;
	   