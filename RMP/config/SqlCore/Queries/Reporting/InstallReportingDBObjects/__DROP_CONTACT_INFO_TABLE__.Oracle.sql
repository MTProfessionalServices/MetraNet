
	  begin
	    if table_exists('t_contact_info') then
        execute immediate 'DROP TABLE t_contact_info';
	    end if;
	  end;
	   