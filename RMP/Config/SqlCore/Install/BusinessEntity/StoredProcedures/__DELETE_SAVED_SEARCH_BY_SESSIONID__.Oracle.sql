
/* ===========================================================
=========================================================== */
CREATE OR REPLACE
PROCEDURE DeleteSavedSearchBySessionID
  (
    SessionID VARCHAR2,
    CreatedBy INTEGER)
AS
BEGIN
  DELETE FROM tmp_SavedSearchBySessionID;
  INSERT INTO tmp_SavedSearchBySessionID
    (c_SearchId, c_SearchFilterId, c_id)
  SELECT r.c_SavedSearch_Id,
    r.c_SearchFilter_Id,
    r.c_SavedSearch_SearchFilter_Id
  FROM t_be_cor_ui_r_SavedS_Searc r
  JOIN t_be_cor_ui_SavedSearch s
  ON r.c_SavedSearch_Id = s.c_SavedSearch_Id
  WHERE s.c_Name        = 'autosave'
  AND s.c_Description   = SessionID
  AND s.c_CreatedBy     = CreatedBy;
  DELETE
  FROM t_be_cor_ui_r_SavedS_Searc
  WHERE c_SavedSearch_SearchFilter_Id IN
    ( SELECT c_id FROM tmp_SavedSearchBySessionID
    );
  DELETE
  FROM t_be_cor_ui_SearchFilter
  WHERE c_SearchFilter_Id IN
    ( SELECT c_SearchFilterId FROM tmp_SavedSearchBySessionID
    );
  DELETE
  FROM t_be_cor_ui_SavedSearch
  WHERE c_SavedSearch_Id IN
    ( SELECT c_SearchId FROM tmp_SavedSearchBySessionID
    );
END;
			