create or replace
function AllowInitialArrersCharge(
p_b_advance IN char,
p_id_acc IN integer,
p_id_sub IN integer,
p_sub_end IN DATE) 
RETURN smallint
IS
p_is_allow_create  smallint;
begin
 if p_b_advance = 'Y' then	
	   /* allows to create initial for ADVANCE */
		 p_is_allow_create := 1;
  else
  /* forbidden to create initial for ARREARS 
	  * [TODO] Need implement that if end date of Sub is fit in billing acc interval it should be allowed to create Initila charge 
	  */
    p_is_allow_create := 0;
	end	if;	 
	return p_is_allow_create;
end;