
if object_id( '%%TEMPDEBUG%%tmp_subscribe_batch' ) is not null
  BEGIN
  /* DROP TABLE %%DEBUG%%tmp_subscribe_batch */
  TRUNCATE TABLE %%DEBUG%%tmp_subscribe_batch
  END
else  
BEGIN
CREATE TABLE %%DEBUG%%tmp_subscribe_batch
(
      id_acc int NOT NULL,
      id_po int NOT NULL,
      id_group int NOT NULL,
      vt_start datetime NOT NULL,
      vt_end datetime NULL,
      uncorrected_vt_start datetime NOT NULL,
      uncorrected_vt_end datetime NULL,
      tt_now datetime NOT NULL,
      id_gsub_corp_account int NOT NULL,
      status int NOT NULL,

      /* audit info */
      id_audit int NOT NULL,
      id_event int NOT NULL,
      id_userid int NOT NULL,
      id_entitytype int NOT NULL,

      /* Values set by the SQL execution. */
      id_sub int NULL,
      nm_display_name nvarchar(255) NULL
)

CREATE CLUSTERED INDEX idx_acc_group_sub ON %%DEBUG%%tmp_subscribe_batch(id_acc, id_group)
END		