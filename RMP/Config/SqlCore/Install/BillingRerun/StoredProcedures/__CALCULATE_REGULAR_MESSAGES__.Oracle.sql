
create or replace procedure CalculateRegularMessages(p_message_size int,
      p_num_regular_messages OUT int)
as
   p_total_sess int;
   p_total_parents int;
   p_numParentsInMessage int;
   p_bucket int;
   p_average int;
 
begin   
   select sum(sessions_in_compound) into p_total_sess from tmp_aggregate;
   select max(id_sess) into p_total_parents from tmp_aggregate;
   
   if(p_total_sess > 0) then
   begin
    if (p_total_sess > p_message_size) then
        begin
          select AVG(sessions_in_compound) into p_average from tmp_aggregate;
          p_numParentsInMessage :=  p_message_size/p_average;
          if (p_numParentsInMessage = 0) then
            p_bucket := p_total_parents;
          else  
            p_bucket := p_total_parents/p_numParentsInMessage + 1;
          end if;  
        end;
     else
            p_bucket := 1;
     end if;
     
   end;        
   else
  	p_bucket := 0;
   end if;	
  		  	
   p_num_regular_messages := p_bucket;
end;
            