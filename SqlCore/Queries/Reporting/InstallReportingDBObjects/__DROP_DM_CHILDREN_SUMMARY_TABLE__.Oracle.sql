
	  begin
	    if table_exists('dm_t_inv_summ_children') then
        execute immediate 'DROP TABLE dm_t_inv_summ_children';
	    end if;
	  end;
	   