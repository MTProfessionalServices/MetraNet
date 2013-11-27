
	  begin
	    if table_exists('t_inv_summ_Parent') then
        execute immediate 'DROP TABLE t_inv_summ_Parent';
	    end if;
	  end;
	   