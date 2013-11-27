
	   DROP TABLE t_acc_usage_credit 
	  begin
	    if table_exists('t_acc_usage_credit') then
        execute immediate 'DROP TABLE t_acc_usage_credit';
	    end if;
	  end;
	   