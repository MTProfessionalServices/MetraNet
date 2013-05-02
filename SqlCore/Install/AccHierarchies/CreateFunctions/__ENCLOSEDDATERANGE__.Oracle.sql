
					create or replace function EnclosedDateRange(temp_dt_start date,
					 temp_dt_end date,
					 temp_dt_checkstart date,
						temp_dt_checkend date) return integer
						 as begin
						 /* check if the range specified by temp_dt_checkstart and*/
						 /* temp_dt_checkend is completely inside the range specified*/
						 /* by temp_dt_start, temp_dt_end*/
						 if temp_dt_checkstart > temp_dt_start AND 
							temp_dt_checkend < temp_dt_end then
							return 1;
						 else
							return 0;
						 end if;
							end;
				