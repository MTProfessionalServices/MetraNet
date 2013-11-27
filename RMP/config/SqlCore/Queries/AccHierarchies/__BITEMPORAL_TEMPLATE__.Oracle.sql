
			create or replace procedure %%PROCNAME%% (
			%%PARAMS%%
			p_startdate IN date,
			p_enddate IN date,
			p_systemdate IN date,
			status OUT integer
			)
			as
			realstartdate date;
			realenddate date;
			tempStartDate date;
			tempEndDate date;
			varMaxDateTime date;
			onesecond_systemdate date;
			%%TEMP_VARIABLES%%
			begin

			select p_startdate,p_enddate,dbo.mtmaxdate(),dbo.subtractsecond(p_systemdate)
			   into realstartdate,realenddate,varMaxDateTime,onesecond_systemdate from dual;
			  status := 0;

			 /* Someone changes the start date of an existing record so that it creates gaps in time */
			 /* Existing Record      |---------------------| */
			 /* modified record       	|-----------| */
			 /* modified record      |-----------------| */
			 /* modified record         |------------------| */
				begin
					
					/* find the start and end dates of the original interval */
					select 
				  vt_start,vt_end into tempstartdate,tempenddate
				from
				%%HISTORYTABLE%%
				where dbo.encloseddaterange(vt_start,vt_end,realstartdate,realenddate) = 1 AND
				%%COMPARISIONSTR%% and tt_end = varMaxDateTime ;

					/* the original date range is no longer true */
					update %%HISTORYTABLE%%
				set tt_end = onesecond_systemdate
					where %%COMPARISIONSTR%% AND vt_start = tempstartdate AND
					tempenddate = vt_end AND tt_end = varMaxDateTime;


					/* ---------------------moved from below-------------------------------------------------- */
					/* adjust the two records end dates that are adjacent on the start and */
					/* end dates; these records are no longer true */
					update %%HISTORYTABLE%% 
					set tt_end = onesecond_systemdate where
					%%KEY_COMPARISION%% AND tt_end = varMaxDateTime AND
					(vt_end = dbo.subtractSecond(tempstartdate) OR vt_start = dbo.addsecond(tempenddate));
					/* ----------------------------------------------------------------------- */

					insert into %%HISTORYTABLE%% 
					(%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
					select 
						%%COMMA_PARAMS%%,vt_start,dbo.subtractsecond(realstartdate),p_systemdate,varMaxDateTime
						from %%HISTORYTABLE%% 
						where
						%%KEY_COMPARISION%% AND vt_end = dbo.subtractSecond(tempstartdate)
					UNION ALL
					select
						%%COMMA_PARAMS%%,realenddate,vt_end,p_systemdate,varMaxDateTime
						from %%HISTORYTABLE%%
						where
						%%KEY_COMPARISION%%  AND vt_start = dbo.addsecond(tempenddate);

					/* adjust the two records end dates that are adjacent on the start and */
					/* end dates; these records are no longer true */
					/**************************************************************************************
					update %%HISTORYTABLE%% 
					set tt_end = onesecond_systemdate where
					%%KEY_COMPARISION%% AND tt_end = varMaxDateTime AND
					(vt_end = dbo.subtractSecond(tempstartdate) OR vt_start = dbo.addsecond(tempenddate));
					**************************************************************************************/
				exception when NO_DATA_FOUND then
				  status := 0;
				end;

				/* detect directly adjacent records with a adjacent start and end date.  If the */
				/* key comparison matches successfully, use the start and/or end date of the original record  */
				/* instead. */
	      if %%SUBSCRIPTION%% then 
        begin
          realstartdate := p_startdate;
          realenddate := p_enddate;
        end;
        else
			    begin
				    select vt_start into realstartdate
				    from 
				    %%HISTORYTABLE%%  where %%COMPARISIONSTR%% AND
					    p_startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = varMaxDateTime;
			    exception when NO_DATA_FOUND then
				  select p_startdate into realstartdate from dual;
			    end;

			    begin
				    select vt_end into realenddate
				    from
				    %%HISTORYTABLE%%  where %%COMPARISIONSTR%% AND
				    p_enddate between vt_start AND dbo.addsecond(vt_end) and tt_end = varMaxDateTime;
			    exception when NO_DATA_FOUND then
					  select p_enddate into realenddate from dual;
			    end;
       end if;

			 /* step : delete a range that is entirely in the new date range */
			 /* existing record:      |----| */
			 /* new record:      |----------------| */
			 update  %%HISTORYTABLE%% 
			 set tt_end = onesecond_systemdate
			 where dbo.EnclosedDateRange(realstartdate,realenddate,vt_start,vt_end) =1 AND
			 %%KEY_COMPARISION%%  AND tt_end = varMaxDateTime;


			 /* create two new records that are on around the new interval         */
			 /* existing record:          |-----------------------------------| */
			 /* new record                        |-------| */
			 /*  */
			 /* adjusted old records      |-------|       |--------------------| */
			  begin
				select
				%%COMMA_PARAMS%%,vt_start,vt_end
				into 
				%%COMMA_TEMPVARS%%,tempStartDate,tempEndDate
				from
				%%HISTORYTABLE%%
				where dbo.encloseddaterange(vt_start,vt_end,realstartdate,realenddate) = 1 AND
				%%KEY_COMPARISION%% and tt_end = varMaxDateTime %%NON_KEY_COMPARISION%%;
				update     %%HISTORYTABLE%% 
				set tt_end = onesecond_systemdate where
				dbo.encloseddaterange(vt_start,vt_end,realstartdate,realenddate) = 1 AND
				%%KEY_COMPARISION%% AND tt_end = varMaxDateTime %%NON_KEY_COMPARISION%%;
			   insert into %%HISTORYTABLE%% 
			   (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
			   select 
				%%COMMA_TEMPVARS%%,tempStartDate,dbo.subtractsecond(realstartdate),
				p_systemdate,varMaxDateTime from dual 
				where tempstartdate is not NULL AND tempStartDate <> realstartdate;
			 /* the previous statement may fail */
				if realenddate <> tempendDate AND realenddate <> varMaxDateTime then
						insert into %%HISTORYTABLE%% 
						(%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
						select
						%%COMMA_TEMPVARS%%,realenddate,tempEndDate,p_systemdate,varMaxDateTime
						from dual;
				end if;
			  exception when NO_DATA_FOUND then
				status := 0;
			  end;
			 /* step 5: update existing payment records that are overlapping on the start */
			 /* range */
			 /* Existing Record |--------------| */
			 /* New Record: |---------| */
			 insert into %%HISTORYTABLE%%
			 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
			 select 
			 %%COMMA_PARAMS%%,realenddate,vt_end,p_systemdate,varMaxDateTime
			 from 
			 %%HISTORYTABLE%%  where
			 %%KEY_COMPARISION%% AND 
			 vt_start > realstartdate and vt_start < realenddate 
			 and tt_end = varMaxDateTime;
			 
       if %%SUBSCRIPTION%% then 
       begin
			    update %%HISTORYTABLE%%
			    set tt_end = onesecond_systemdate
			      where
           %%KEY_COMPARISION%%     and tt_end = varMaxDateTime;
      end;
      else begin
        update %%HISTORYTABLE%%
        set tt_end = onesecond_systemdate
        where
			 %%KEY_COMPARISION%% AND 
			 vt_start > realstartdate and vt_start < realenddate 
			 and tt_end = varMaxDateTime;
      end;
      end if;
			 /* step 4: update existing payment records that are overlapping on the end */
			 /* range */
			 /* Existing Record |--------------| */
			 /* New Record:             |-----------| */
			 insert into %%HISTORYTABLE%%
			 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
			 select
			 %%COMMA_PARAMS%%,vt_start,dbo.subtractsecond(realstartdate),p_systemdate,varMaxDateTime
			 from %%HISTORYTABLE%%
			 where
			 %%KEY_COMPARISION%% AND 
			 vt_end > realstartdate AND vt_end < realenddate
			 AND tt_end = varMaxDateTime;
       
       if %%SUBSCRIPTION%% then 
       begin
			  update %%HISTORYTABLE%%
			  set tt_end = onesecond_systemdate
			  where %%KEY_COMPARISION%%
        AND tt_end = varMaxDateTime;
      end;
      else begin
        update %%HISTORYTABLE%%
        set tt_end = onesecond_systemdate
        where
        %%KEY_COMPARISION%%  AND 
			  vt_end > realstartdate AND vt_end < realenddate
			  AND tt_end = varMaxDateTime;
      end;
      end if;
			 /* used to be realenddate */
			 /* step 7: create the new payment redirection record.  If the end date  */
			 /* is not max date, make sure the enddate is subtracted by one second */
			 insert into %%HISTORYTABLE%% 
			 (%%COMMA_PARAMS%%,vt_start,vt_end,tt_start,tt_end)
			 select 
			 %%COMMA_INPUT_PARAMS%%,realstartdate,
			  case when realenddate = dbo.mtmaxdate() then realenddate else 
			  %%ENDDATE_PARAM%% end as realenddate,
			  p_systemdate,varMaxDateTime
			  from dual;
			  
			delete from %%TABLENAME%% where %%KEY_COMPARISION%%;
			insert into %%TABLENAME%% (%%COMMA_PARAMS%%,vt_start,vt_end)
			select %%COMMA_PARAMS%%,vt_start,vt_end
			from %%HISTORYTABLE%%  where %%KEY_COMPARISION%% and tt_end = varMaxDateTime;
			 status := 1;
			 end;
			