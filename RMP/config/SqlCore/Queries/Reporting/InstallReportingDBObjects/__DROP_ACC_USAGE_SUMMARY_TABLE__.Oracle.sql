
	  begin
	    if table_exists('t_acc_usage_summ') then
        execute immediate 'DROP TABLE t_acc_usage_summ';
	    end if;
	  end;
	   