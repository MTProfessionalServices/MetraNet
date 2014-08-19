create or replace
function AllowInitialArrersCharge(
p_b_advance IN    char,
p_id_acc IN       integer,
p_sub_end IN      date,
p_current_date IN date,
p_isQuote IN      integer default 1) 
RETURN smallint
IS
p_is_allow_create  smallint;
begin
	if p_b_advance = 'Y' then	
		/* allows to create initial for ADVANCE */
		p_is_allow_create := 1;    
	else    
    if p_isQuote > 0 then	
		/* disable to create initial for ARREARS in case of quote  */
      p_is_allow_create := 0;      
    else
		/* Creates Initial charges in case it fits inder current interval*/
		select case when exists(select 1 from t_usage_interval us_int
					join t_acc_usage_cycle acc
					on us_int.id_usage_cycle = acc.id_usage_cycle
					where acc.id_acc = p_id_acc
					AND NVL(p_current_date, metratime(1,'RC')) BETWEEN DT_START AND DT_END
					AND p_sub_end BETWEEN DT_START AND DT_END
					)
				then 1
				else 0
			  end
		into p_is_allow_create
		from dual;
    
    end	if;	  
	end	if;	 
	  
	return p_is_allow_create;
end;
