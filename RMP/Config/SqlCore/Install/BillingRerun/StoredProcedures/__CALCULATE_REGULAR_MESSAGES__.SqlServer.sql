
create procedure CalculateRegularMessages(@message_size int,
      @num_regular_messages int OUTPUT)
as

   declare @total_sess int;
   declare @total_parents int;
   declare @numParentsInMessage int;
   declare @bucket int;
   declare @average int;
   declare @num_regular_session_sets int;
begin   
   select @total_sess = sum(sessions_in_compound) from #aggregate;

   select @total_parents = max(id_sess) from #aggregate;
       
   if(@total_sess > 0) 
   begin
    if (@total_sess > @message_size) 
        begin
          select @average = AVG(sessions_in_compound) from #aggregate;
   
          set @numParentsInMessage =  @message_size/@average;
          if (@numParentsInMessage = 0) 
            set @bucket = @total_parents;
          else  
            set @bucket = (@total_parents/@numParentsInMessage) + 1;
     	end;
     else
            set @bucket = 1;

     
   end;        
   else
  	set @bucket = 0;
  		  	
   set @num_regular_messages = @bucket;
end;

    