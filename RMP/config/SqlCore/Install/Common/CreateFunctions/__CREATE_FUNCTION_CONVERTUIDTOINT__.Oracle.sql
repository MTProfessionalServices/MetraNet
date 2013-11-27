
	CREATE or replace function ConvertUIDToInteger (p_UID raw) return int
	as
        v_intID int;
    begin

	    v_intID :=
        cast(nvl(substr(p_UID, 1, 1),0) as integer) +
		cast(nvl(substr(p_UID, 2, 1),0) as integer) * 256 +
		cast(nvl(substr(p_UID, 3, 1),0) as integer) * 65536 +
		cast(nvl(substr(p_UID, 4, 1),0) as integer) * 16777216;

	return v_intID;
	end;

    