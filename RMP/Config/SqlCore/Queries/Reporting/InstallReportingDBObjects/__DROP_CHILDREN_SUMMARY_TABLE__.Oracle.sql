
	  begin
	    if table_exists('t_inv_summ_Children') then
        execute immediate 'DROP TABLE t_inv_summ_Children';
	    end if;
	  end;
	   