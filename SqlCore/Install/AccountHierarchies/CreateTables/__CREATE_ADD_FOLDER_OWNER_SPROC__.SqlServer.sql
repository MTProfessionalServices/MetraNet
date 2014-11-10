
create procedure AddOwnedFolder(
@owner  int,
@folder int,
@p_systemdate datetime,
@p_enforce_same_corporation varchar,
@existing_owner int OUTPUT,
@status int OUTPUT)
as
begin
	declare @bFolder char
	select @status = 0 
	if (@owner = @folder) 
		begin
		--MT_FOLDER_CANNOT_OWN_ITSELF
		select @status = -486604761
		return
		end
	begin
	select @existing_owner = id_owner  from t_impersonate where	id_acc = @folder
	if (@existing_owner is null)
		begin
		select @existing_owner = 0
		end
	end
	if (@existing_owner <> 0 and @existing_owner <> @owner)
		begin
		-- the folder is already owned by another account
		-- MT_EXISTING_FOLDER_OWNER
		select @status = -486604779
		RETURN
		END 
	-- simply exit the stored procedure if the current owner is the owner
	if (@existing_owner = @owner) 
		begin
		select @status = 1
		return
		end
	
		-- check that both the payer and Payee are in the same corporate account
		if @p_enforce_same_corporation = '1' AND dbo.IsInSameCorporateAccount(@owner,@folder,@p_systemdate) <> 1 
		begin
			-- MT_CANNOT_OWN_FOLDER_IN_DIFFERENT_CORPORATE_ACCOUNT
			select @status = -486604751
			return
		end
	
	
	if (@existing_owner = 0) 
		begin
		insert into t_impersonate (id_owner,id_acc) values (@owner,@folder)
		select @status = 0
		end
	select @status = 1
end 
			 