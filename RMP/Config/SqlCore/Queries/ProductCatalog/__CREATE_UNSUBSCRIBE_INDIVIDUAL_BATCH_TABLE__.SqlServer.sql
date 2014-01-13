
if object_id( 'tempdb..#tmp_unsubscribe_indiv_batch' ) is not null
  DROP TABLE #tmp_unsubscribe_indiv_batch

CREATE TABLE #tmp_unsubscribe_indiv_batch
(id_acc int, id_po int, id_sub int, vt_start datetime, 
vt_end datetime, uncorrected_vt_start datetime, uncorrected_vt_end datetime, tt_now datetime, status int,

/*  audit info */
id_audit int NOT NULL,
id_event int NOT NULL,
id_userid int NOT NULL,
id_entitytype int NOT NULL,

/*  Values set by the SQL execution. */
nm_display_name nvarchar(255) NULL
)

CREATE CLUSTERED INDEX idx_acc_sub ON #tmp_unsubscribe_indiv_batch(id_acc, id_sub)
		