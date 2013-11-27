
/* ===========================================================

=========================================================== */

create procedure DeleteSavedSearchBySessionID
	@SessionID NVARCHAR(255),
	@CreatedBy integer
as
begin

	declare @temp TABLE (
		c_SearchId uniqueidentifier,
		c_SearchFilterId uniqueidentifier,
		c_id uniqueidentifier
	)
	
	delete from @temp
	
	insert into @temp (c_SearchId, c_SearchFilterId, c_id)
		SELECT r.c_SavedSearch_Id, r.c_SearchFilter_Id, r.c_SavedSearch_SearchFilter_Id
			FROM t_be_cor_ui_r_SavedS_Searc r
			JOIN t_be_cor_ui_SavedSearch s ON r.c_SavedSearch_Id = s.c_SavedSearch_Id
			WHERE s.c_Name = N'autosave' AND s.c_Description = @SessionID AND s.c_CreatedBy = @CreatedBy

	delete from t_be_cor_ui_r_SavedS_Searc
		where c_SavedSearch_SearchFilter_Id in (
			select c_id
				from @temp
		)
	
	delete from t_be_cor_ui_SearchFilter 
		where c_SearchFilter_Id in (
			select c_SearchFilterId
				from @temp
		)

	delete from t_be_cor_ui_SavedSearch
		where c_SavedSearch_Id in (
			select c_SearchId
				from @temp
		)
	
end
		