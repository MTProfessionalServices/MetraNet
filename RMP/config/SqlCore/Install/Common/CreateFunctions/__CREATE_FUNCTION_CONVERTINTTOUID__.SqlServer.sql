
	CREATE  function ConvertIntegerToUID(@id_sess integer) returns varbinary(16)
	as
	begin
		declare @uid varbinary(16)
		set @uid = cast(@id_sess % 256 as varbinary(1)) +
			   cast((@id_sess/256) % 256 as varbinary(1)) +
			   cast((@id_sess/65536) % 256 as varbinary(1)) +
			   cast((@id_sess/16777216) % 256 as varbinary(1))
		return @uid

	end
    