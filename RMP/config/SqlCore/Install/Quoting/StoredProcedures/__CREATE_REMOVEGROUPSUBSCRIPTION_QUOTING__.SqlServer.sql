CREATE PROCEDURE [dbo].[RemoveGroupSubscription_Quoting](
  @p_id_sub int,
  @p_systemdate datetime,
  @p_status int OUTPUT)

  as
  begin
    
    declare @groupID int
    declare @maxdate datetime
    declare @nmembers int
    declare @icbID int

    set @p_status = 0

    select @groupID = id_group,@maxdate = dbo.mtmaxdate()
    from t_sub where id_sub = @p_id_sub

    select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub
	    
    delete from t_gsub_recur_map where id_group = @groupID
    delete from t_recur_value where id_sub = @p_id_sub

    -- In the t_acc_template_subs, either id_po or id_group have to be null.
    -- If a subscription is added to a template, then id_po points to the subscription
    -- If a group subscription is added to a template, then id_group points to the group subscription.
    delete from t_acc_template_subs where id_group = @groupID and id_po is null

    -- Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables
    delete from t_pl_map where id_sub = @p_id_sub

    update t_recur_value set tt_end = @p_systemdate
      where id_sub = @p_id_sub and tt_end = @maxdate
    update t_sub_history set tt_end = @p_systemdate
      where tt_end = @maxdate and id_sub = @p_id_sub

    delete from t_sub where id_sub = @p_id_sub
    
    delete from t_char_values where id_entity = @p_id_sub
    
      if (@icbID is not NULL)
      begin
        exec sp_DeletePricelist @icbID, @p_status output
        if @p_status <> 0 return
      end
  
    update t_group_sub set tx_name = CAST('[DELETED ' + CAST(GetDate() as nvarchar) + ']' + tx_name as nvarchar(255)) where id_group = @groupID

  end