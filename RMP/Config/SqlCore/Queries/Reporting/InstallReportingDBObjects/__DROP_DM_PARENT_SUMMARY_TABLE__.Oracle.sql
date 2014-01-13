
	  begin
	    if table_exists('dm_t_inv_summ_parent') then
        execute immediate 'DROP TABLE dm_t_inv_summ_parent';
	    end if;
	  end;
	   