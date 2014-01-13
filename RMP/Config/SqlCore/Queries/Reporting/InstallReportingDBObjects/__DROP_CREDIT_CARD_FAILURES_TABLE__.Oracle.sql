
	  begin
	    if table_exists('t_cc_failure') then
        execute immediate 'DROP TABLE t_cc_failure';
	    end if;
	  end;
	   