
CREATE OR REPLACE PACKAGE mt_rate_pkg
AS
    TYPE TP_PARAM_DEF IS RECORD (
        nm_column_name nvarchar2(255),
        is_rate_key number,
        id_param_table_prop number
    );
    TYPE TP_PARAM_DEF_ARRAY IS TABLE OF TP_PARAM_DEF INDEX BY BINARY_INTEGER;
    TYPE TP_PARAM_TABLE_DEF IS RECORD (param_defs TP_PARAM_DEF_ARRAY, nm_pt VARCHAR2 (100), id_pt NUMBER);
    TYPE TP_PARAM_TABLE_DEF_ARRAY IS TABLE OF TP_PARAM_TABLE_DEF INDEX BY BINARY_INTEGER;
    TYPE TP_PARAM_ASSOC IS TABLE OF NVARCHAR2 (100) INDEX BY BINARY_INTEGER;
    TYPE TP_PARAM_ROW IS RECORD (params TP_PARAM_ASSOC, id_sched NUMBER, id_audit NUMBER, n_order NUMBER, updated NUMBER);
    TYPE TP_PARAM_ARRAY IS TABLE OF TP_PARAM_ROW INDEX BY BINARY_INTEGER;
    TYPE TP_SCHEDULE IS RECORD (id_sched NUMBER, tt_start DATE, tt_end DATE, chg_dates NUMBER, chg_rates NUMBER, deleted NUMBER, rates TP_PARAM_ARRAY);
    TYPE TP_SCHEDULE_ARRAY IS TABLE OF TP_SCHEDULE INDEX BY BINARY_INTEGER;
    TYPE TP_PARAM_ASSOC_ARRAY IS TABLE OF TP_PARAM_ASSOC INDEX BY BINARY_INTEGER;
    
    current_id_audit number;
    
    PROCEDURE recursive_inherit_sub(
        v_id_audit NUMBER,
        v_id_acc NUMBER,
        v_id_sub NUMBER,
        v_id_group NUMBER
    );
    PROCEDURE recursive_inherit_sub_to_accs(
        v_id_sub NUMBER
    );
    PROCEDURE get_all_pts_by_sub(
        my_id_sub NUMBER,
        my_id_pt_curs OUT SYS_REFCURSOR
    );
    PROCEDURE get_id_sched(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_sched_curs OUT SYS_REFCURSOR
    );
    PROCEDURE recursive_inherit(
        v_id_audit NUMBER,
        my_id_acc NUMBER,
        v_id_sub NUMBER,
        v_id_po NUMBER,
        v_id_pi_template NUMBER,
        my_id_sched NUMBER,
        my_id_pt NUMBER,
        pass_to_children NUMBER,
        cached_param_defs IN OUT TP_PARAM_TABLE_DEF_ARRAY,
        v_id_csr IN NUMBER := 129
    );
    PROCEDURE get_child_gsubs_private(
        my_id_acc NUMBER,
        my_id_po NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_gsub_curs OUT SYS_REFCURSOR
    );
    PROCEDURE get_id_pl_by_pt(
        my_id_acc NUMBER,
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_id_pricelist OUT NUMBER
    );
    PROCEDURE get_id_pi_template(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template OUT NUMBER
    );
    PROCEDURE mt_resolve_overlaps_by_sched (
        v_id_acc IN NUMBER,
        v_start IN DATE,
        v_end IN DATE,
        v_replace_nulls IN NUMBER,
        v_merge_rates IN NUMBER,
        v_reuse_sched IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_schedules_in IN TP_SCHEDULE_ARRAY,
        v_id_sched IN NUMBER,
        v_schedules_out OUT TP_SCHEDULE_ARRAY
    );
    PROCEDURE get_inherit_id_sub(
        my_id_acc NUMBER,
        my_id_po NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        inherit_id_sub_curs OUT SYS_REFCURSOR
    );
    PROCEDURE get_id_sched_pub(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_sched_curs OUT SYS_REFCURSOR
    );
    PROCEDURE templt_write_schedules(
        my_id_acc NUMBER,
        my_id_sub NUMBER,
        v_id_audit IN NUMBER,
        is_public IN NUMBER,
        v_id_pricelist IN NUMBER,
        v_id_pi_template IN NUMBER,
        v_param_table_def IN TP_PARAM_TABLE_DEF,
        v_schedules IN OUT TP_SCHEDULE_ARRAY,
        v_id_csr IN NUMBER := 129
    );
    PROCEDURE mt_load_schedule(
        v_id_sched IN NUMBER,
        v_start IN DATE,
        v_end IN DATE,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals IN TP_PARAM_ASSOC,
        v_schedule OUT TP_SCHEDULE
    );
    PROCEDURE mt_resolve_overlaps(
        v_id_acc IN NUMBER,
        v_replace_nulls IN NUMBER,
        v_merge_rates IN NUMBER,
        v_reuse_sched IN NUMBER,
        v_update IN NUMBER,
        v_param_defs IN TP_PARAM_DEF_ARRAY,
        v_schedules_in IN TP_SCHEDULE_ARRAY,
        v_schedule_new IN TP_SCHEDULE,
        v_schedules_out OUT TP_SCHEDULE_ARRAY
    );
    PROCEDURE templt_persist_rsched(
        my_id_acc NUMBER,
        my_id_pt NUMBER,
        v_id_sched IN OUT NUMBER,
        my_id_pricelist NUMBER,
        my_id_pi_template NUMBER,
        v_start_dt DATE,
        v_start_type NUMBER,
        v_begin_offset NUMBER,
        v_end_dt DATE,
        v_end_type NUMBER,
        v_end_offset NUMBER,
        is_public NUMBER,
        my_id_sub NUMBER,
        v_id_csr IN NUMBER := 129
    );
    PROCEDURE mt_load_schedule_params(
        v_id_sched IN NUMBER,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals IN TP_PARAM_ASSOC,
        v_rates IN OUT TP_PARAM_ARRAY
    );
    PROCEDURE mt_load_schedule_params_array(
        v_id_sched IN NUMBER,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals_array IN TP_PARAM_ASSOC_ARRAY,
        v_rates IN OUT TP_PARAM_ARRAY
    );
    PROCEDURE mt_replace_nulls(
        v_param_defs IN TP_PARAM_DEF_ARRAY,
        v_rates_low IN TP_PARAM_ARRAY,
        v_rates_high IN TP_PARAM_ARRAY,
        v_rates_out OUT TP_PARAM_ARRAY
    );
    PROCEDURE mt_merge_rates(
        v_update IN NUMBER,
        v_param_defs IN TP_PARAM_DEF_ARRAY,
        v_rates_low IN TP_PARAM_ARRAY,
        v_rates_high IN TP_PARAM_ARRAY,
        v_rates_out OUT TP_PARAM_ARRAY
    );
END mt_rate_pkg;

