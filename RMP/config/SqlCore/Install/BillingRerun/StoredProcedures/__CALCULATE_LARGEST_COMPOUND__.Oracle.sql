
create or replace procedure CalculateLargestCompoundSize(
      p_largest_compound OUT int)
as

   cnt_large int;
   cnt int;
begin   
  select NVL(max(NVL(sessions_in_compound,0)), 0) into cnt_large from tmp_aggregate_large;
  select NVL(max(NVL(sessions_in_compound, 0)), 0) into cnt from tmp_aggregate;
  
  if (cnt_large > cnt) then
	p_largest_compound := cnt_large;
  else
    p_largest_compound := cnt;
  end if;  	
end;
            