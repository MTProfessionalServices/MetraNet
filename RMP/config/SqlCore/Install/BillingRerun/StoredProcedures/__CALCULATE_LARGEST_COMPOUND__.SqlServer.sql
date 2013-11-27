
create procedure CalculateLargestCompoundSize(
      @largest_compound int OUTPUT )
as
begin
   declare @cnt_large int;
   declare @cnt int;
   
  select @cnt_large = ISNull(max(ISNull(sessions_in_compound,0)), 0) from #aggregate_large;
  select @cnt = ISNull(max(ISNULL(sessions_in_compound, 0)), 0) from #aggregate;
  
  if (@cnt_large > @cnt) 
	set @largest_compound = @cnt_large;
  else
    set @largest_compound = @cnt;
	
end;
            