
	  begin
	    if table_exists('t_enterprise') then
        execute immediate 'DROP TABLE t_enterprise';
	    end if;
	  end;
	   