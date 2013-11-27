
create procedure RemoveSubscription(
	@p_id_sub int,
	@p_systemdate datetime)
	as
	begin
 	declare @groupID int
	declare @maxdate datetime
  declare @icbID int
	declare @status int
	select @groupID = id_group,@maxdate = dbo.mtmaxdate()
	from t_sub where id_sub = @p_id_sub AND @p_systemdate BETWEEN vt_Start and vt_End

  -- Look for an ICB pricelist and delete it if it exists
	select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub

  if (@groupID is not NULL)
		begin
		update t_gsubmember_historical set tt_end = @p_systemdate 
		where tt_end = @maxdate AND id_group = @groupID
		delete from t_gsubmember where id_group = @groupID
    delete from t_gsub_recur_map where id_group = @groupID
		-- note that we do not delete from t_group_sub
		end   
	delete from t_pl_map where id_sub = @p_id_sub
	delete from t_sub where id_sub = @p_id_sub
	update t_recur_value set tt_end = @p_systemdate 
	where id_sub = @p_id_sub and tt_end = @maxdate
	update t_sub_history set tt_end = @p_systemdate
	where tt_end = @maxdate AND id_sub = @p_id_sub

	if (@icbID is not NULL)
  begin
    exec sp_DeletePricelist @icbID, @status output
    if @status <> 0 return
  end

	end
		