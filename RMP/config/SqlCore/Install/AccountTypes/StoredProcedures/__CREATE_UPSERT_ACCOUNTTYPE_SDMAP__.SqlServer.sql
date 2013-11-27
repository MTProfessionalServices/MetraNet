
CREATE PROCEDURE UpsertAccountTypeServiceDefMap @accounttype int, @operation nvarchar(510), 
@servicedefname nvarchar(510)
AS
BEGIN
	declare @serviceid int
	declare @opid int
	set @serviceid = (select id_enum_data from t_enum_data where nm_enum_data = @servicedefname)
	set @opid = (select id_enum_data from t_enum_data where nm_enum_data = @operation)

	update t_account_type_servicedef_map
		set id_service_def = @serviceid
		where id_type = @accounttype
		and operation = @opid
	if (@@rowcount = 0)
		insert into t_account_type_servicedef_map (id_type, operation, id_service_def) 
		values (@accounttype, @opid, @serviceid)
END
			