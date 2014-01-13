
create or replace procedure CalculateAtomicMessages(p_message_size int,
      p_num_atomic_messages OUT int)
as

   p_id_max_sess int;
   p_bucket int;
begin   
  select max(id_sess) into p_id_max_sess from tmp_aggregate;
   
  if(p_id_max_sess > p_message_size) then
   begin
      if (mod(p_id_max_sess, p_message_size)>0) then
        p_bucket := (p_id_max_sess/p_message_size) + 1;
      else
        p_bucket := (p_id_max_sess/p_message_size); 
      end if;  
   end;        
   else
  	p_bucket := 1;
   end if;	
    		  	
   p_num_atomic_messages := p_bucket;
end;
            