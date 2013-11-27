
	CREATE  or replace function ConvertIntegerToUID(p_id_sess int) return raw
	as
		v_uid raw(16);
    begin
		v_uid := utl_raw.cast_to_raw(mod(p_id_sess        , 256)) ||
			   utl_raw.cast_to_raw(mod(p_id_sess/256      , 256)) ||
			   utl_raw.cast_to_raw(mod(p_id_sess/65536    , 256)) ||
			   utl_raw.cast_to_raw(mod(p_id_sess/16777216 , 256));
		return v_uid;
	end;
    