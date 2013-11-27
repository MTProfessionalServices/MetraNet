
			create proc ExecSpProcOnKind @kind as int,@id as int
				as
				declare @sprocname varchar(256)
				select @sprocname = nm_sprocname from t_principals where id_principal = @kind
				exec (@sprocname + ' ' + @id)
	 