
CREATE GLOBAL TEMPORARY TABLE tmp_sub (
    id_sub number(10) null,
    id_sub_ext raw(16) null,
    id_acc number(10) null,
    id_group number(10) null,
    id_po number(10) not null,
    dt_crt date null,
    vt_start date null,
    vt_end date null
)
ON COMMIT DELETE ROWS;
