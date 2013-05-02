
create procedure CalculateAtomicMessages(@message_size int,
      @num_atomic_messages int OUTPUT)
as
begin
   declare @id_max_sess int;
   declare @bucket int;
   
   select @id_max_sess = ISNull(max(id_sess),0) from #aggregate;
   if(@id_max_sess > @message_size)
    begin
      if ((@id_max_sess % @message_size)>0) 
        set @bucket = (@id_max_sess/@message_size) + 1;
      else
        set @bucket = (@id_max_sess/@message_size); 
   
    end;        
   else
  	set @bucket = 1;

    		  	
   set @num_atomic_messages = @bucket;
   end;

    