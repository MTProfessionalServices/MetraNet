
      /*
      	DeleteUniqueKeyMetadata

      	Deletes the metadata for a unique key.  Removes all
      	rows for a given unique key in the tables: t_unqiue_cons &
      	t_unique_cons_columns.

      	@consname - name of unique key

      */
      create proc DeleteUniqueKeyMetadata(
      	@consname varchar(200)
      	) as
      begin

      -- Env set up
      set nocount on
      declare @err int

      declare @localtran int
      set @localtran = 0
      if (@@trancount = 0) begin
      	begin tran
      	set @localtran = 1
      end

      -- Delete key colums first
      --
      delete from t_unique_cons_columns
      where id_unique_cons in (
      	select id_unique_cons from t_unique_cons
      	where lower(constraint_name) = lower(@consname))
      set @err = @@error

      if (@err <> 0) begin
      	raiserror('Cannot delete key [%s].', 16, 1, @consname)
      	if (@localtran = 1) rollback
      	return 1
      end

      -- Delete key name
      --
      delete from t_unique_cons
      where lower(constraint_name) = lower(@consname)
      set @err = @@error

      if (@err <> 0) begin
      	raiserror('Cannot delete key [%s].', 16, 1, @consname)
      	if (@localtran = 1) rollback
      	return 1
      end

      if (@localtran = 1)
      	commit

      end --proc
 	