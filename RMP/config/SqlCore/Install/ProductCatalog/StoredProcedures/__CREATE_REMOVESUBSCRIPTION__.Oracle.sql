
			create or replace procedure RemoveSubscription(
			p_id_sub in INTEGER,
			p_systemdate IN date)
			as
			groupID integer;
			maxdate date;
			icbID integer;
			status integer;
			begin

			  
			  begin
			  select id_group,dbo.mtmaxdate() into groupID,maxdate
			  from t_sub where id_sub = p_id_sub AND p_systemdate BETWEEN vt_Start and vt_End;
			  exception
			  when no_data_found then
			  null;
			  end;

  
			  /* Look for an ICB pricelist and delete it if it exists */
				begin
				select id_pricelist into icbID from t_pl_map where id_sub= p_id_sub	and rownum < 2;
			  exception
			  when no_data_found then
			  null;
			  end;
				
				
			  if groupID is not NULL then
				update t_gsubmember_historical set tt_end = p_systemdate 
					where tt_end = maxdate AND id_group = groupID;
				delete from t_gsubmember where id_group = groupID;
				delete from t_gsub_recur_map where id_group = groupID;
			  end if;
			  
			  delete from t_pl_map where id_sub = p_id_sub;
			  delete from t_sub where id_sub = p_id_sub;

			  update t_recur_value set tt_end = p_systemdate where id_sub = p_id_sub and tt_end = maxdate;
			  update t_sub_history set tt_end = p_systemdate where tt_end = maxdate AND id_sub = p_id_sub;
			  
			  
			  if icbID is not NULL then
				sp_DeletePricelist(icbID, status);
				if (status <> 0) then
				 return;
				end if;
			  END IF;
			 end;
		