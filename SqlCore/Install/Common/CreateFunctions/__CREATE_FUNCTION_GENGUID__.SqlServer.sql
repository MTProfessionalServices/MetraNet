CREATE  FUNCTION GenGuid() returns varbinary(16)
	AS
BEGIN
	RETURN (select new_id from vwGetNewID)
END
    