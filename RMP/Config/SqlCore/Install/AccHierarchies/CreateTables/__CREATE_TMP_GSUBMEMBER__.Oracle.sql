
CREATE GLOBAL TEMPORARY TABLE tmp_gsubmember (
    id_group number(10) null,
    id_acc number(10) null,
    vt_start date null,
    vt_end date null
)
ON COMMIT DELETE ROWS;
