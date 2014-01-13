
        	create or replace procedure InsertIntoEventTable
        		(p_id_mv number, p_description nvarchar2, p_id_event out number)
			as
			begin
				insert into t_mview_event(id_event, id_mv, description)
				values(seq_tmp_t_mview_event.nextval, p_id_mv, p_description);
				select seq_tmp_t_mview_event.currval into p_id_event from dual;
			end;
		