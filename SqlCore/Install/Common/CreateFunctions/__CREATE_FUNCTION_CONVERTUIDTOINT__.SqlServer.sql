
	CREATE  function ConvertUIDToInteger (@UID varbinary(16)) returns int
	as
	begin
	declare @intID int
	set @intID = cast(substring(@UID, 1, 1) as integer) |
		cast(substring(@UID, 2, 1) as integer) * 256 |
		cast(substring(@UID, 3, 1) as integer) * 65536 |
		cast(substring(@UID, 4, 1) as integer) * 16777216
	return @intID
	end

    