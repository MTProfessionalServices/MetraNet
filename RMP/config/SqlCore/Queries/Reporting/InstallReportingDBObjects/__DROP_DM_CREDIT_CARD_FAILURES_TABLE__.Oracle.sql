
	  begin
	    if table_exists('dm_t_cc_failure') then
        execute immediate 'DROP TABLE dm_t_cc_failure';
	    end if;
	  end;
	   