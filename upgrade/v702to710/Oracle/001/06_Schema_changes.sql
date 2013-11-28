CREATE OR REPLACE PACKAGE BODY mt_rate_pkg
AS
    /* initialize the param table column definition array */
    PROCEDURE mt_load_param_defs(
        v_id_pt IN NUMBER,
        v_param_defs OUT TP_PARAM_DEF_ARRAY
    )
    IS
      l_cursor              SYS_REFCURSOR;
      l_param_def           TP_PARAM_DEF;
      l_nm_column_name      VARCHAR2 (100);
      l_is_rate_key         NUMBER;
      l_id_param_table_prop NUMBER;
    BEGIN
      OPEN l_cursor FOR
        SELECT TPTP.nm_column_name,
               DECODE(CASE WHEN TPTP.b_columnoperator = 'N' THEN TPTP.nm_operatorval ELSE TPTP.b_columnoperator END, NULL, 0, 1) AS is_rate_key,
               TPTP.id_param_table_prop
        FROM   t_param_table_prop TPTP
        WHERE  TPTP.id_param_table = v_id_pt;
      LOOP
        FETCH l_cursor INTO l_nm_column_name, l_is_rate_key, l_id_param_table_prop;
        EXIT WHEN l_cursor%NOTFOUND;
        l_param_def.nm_column_name := l_nm_column_name;
        l_param_def.is_rate_key := l_is_rate_key;
        l_param_def.id_param_table_prop := l_id_param_table_prop;
        v_param_defs (l_id_param_table_prop) := l_param_def;
      END LOOP;
      CLOSE l_cursor;
    END mt_load_param_defs;

    /* initialize the param table column definition array */
    PROCEDURE mt_load_param_table_def(
        v_id_pt IN NUMBER,
        v_pts IN OUT TP_PARAM_TABLE_DEF_ARRAY,
        v_pt OUT TP_PARAM_TABLE_DEF
    )
    IS
    BEGIN
      IF (v_pts.exists (v_id_pt)) THEN
        v_pt := v_pts (v_id_pt);
      ELSE
        SELECT nm_instance_tablename
        INTO   v_pt.nm_pt
        FROM   T_RULESETDEFINITION
        WHERE  id_paramtable = v_id_pt;
        
        v_pt.id_pt := v_id_pt;
        mt_load_param_defs (v_id_pt, v_pt.param_defs);
        v_pts (v_id_pt) := v_pt;
      END IF;
    END mt_load_param_table_def;

    PROCEDURE recursive_inherit_sub(
        v_id_audit NUMBER,
        v_id_acc NUMBER,
        v_id_sub NUMBER,
        v_id_group NUMBER
    )
    AS
        my_cached_param_defs MT_RATE_PKG.TP_PARAM_TABLE_DEF_ARRAY;
        my_id_sub NUMBER(10);
        my_id_audit NUMBER;
        my_id_po NUMBER(10);
        my_id_pt NUMBER(10);
        my_id_pt_curs SYS_REFCURSOR;
        my_id_sched_curs SYS_REFCURSOR;
        my_child_id_sched NUMBER(10);
        my_child_sched_start DATE;
        my_child_sched_end DATE;
        my_counter NUMBER;
        my_id_pi_template NUMBER;
    BEGIN
        my_id_sub := v_id_sub;
        IF my_id_sub IS NULL THEN
            select max(id_sub) into my_id_sub from t_sub where id_group = v_id_group;
        END IF;
        
        select min(id_po) into my_id_po from t_sub where id_sub = my_id_sub;
        
        my_id_audit := NVL(v_id_audit, current_id_audit);
        IF my_id_audit IS NULL THEN
			getcurrentid ('id_audit', my_id_audit);
                         
            insertauditevent(
                temp_id_userid      => NULL,
                temp_id_event       => 1451,
                temp_id_entity_type => 2,
                temp_id_entity      => my_id_sub,
                temp_dt_timestamp   => sysdate,
                temp_id_audit       => my_id_audit,
                temp_tx_details     => 'Creating public rate for account ' || v_id_acc || ' subscription ' || my_id_sub,
                tx_logged_in_as     => NULL,
                tx_application_name => NULL);
        END IF;
        
        MT_RATE_PKG.get_all_pts_by_sub(my_id_sub, my_id_pt_curs);
        
        LOOP
            FETCH my_id_pt_curs INTO my_id_pt, my_id_pi_template;
            EXIT WHEN my_id_pt_curs%NOTFOUND;
            my_counter := 0;
            MT_RATE_PKG.get_id_sched(my_id_sub, my_id_pt, my_id_pi_template, mtmindate(), mtmaxdate(), my_id_sched_curs);
            LOOP
                FETCH my_id_sched_curs INTO my_child_id_sched, my_child_sched_start, my_child_sched_end;
                EXIT WHEN my_id_sched_curs%NOTFOUND;
                my_counter := my_counter + 1;
                MT_RATE_PKG.recursive_inherit(my_id_audit, v_id_acc, my_id_sub, my_id_po, my_id_pi_template, my_child_id_sched, my_id_pt, 1, my_cached_param_defs);
            END LOOP;
            if (my_counter = 0) THEN
                MT_RATE_PKG.recursive_inherit(my_id_audit, v_id_acc, my_id_sub, my_id_po, my_id_pi_template, NULL, my_id_pt, 1, my_cached_param_defs);
            END IF;
        END LOOP;
        CLOSE my_id_pt_curs;

    END recursive_inherit_sub;
    
    PROCEDURE recursive_inherit_sub_to_accs(
        v_id_sub NUMBER
    )
    AS
    BEGIN
        FOR rec IN (
            SELECT s.id_acc, s.id_group
            FROM   t_sub s
            WHERE  s.id_sub = v_id_sub AND s.id_group IS NULL
            UNION ALL
            SELECT gm.id_acc, gm.id_group
            FROM   t_sub s
                   INNER JOIN t_gsubmember gm ON gm.id_group = s.id_group
            WHERE  s.id_sub = v_id_sub
        )
        LOOP
             mt_rate_pkg.recursive_inherit_sub(
                v_id_audit => NULL,
                v_id_acc   => rec.id_acc,
                v_id_sub   => NULL,
                v_id_group => rec.id_group
            );
        END LOOP;
    END recursive_inherit_sub_to_accs;
   
    PROCEDURE get_all_pts_by_sub(
        my_id_sub NUMBER,
        my_id_pt_curs OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN my_id_pt_curs FOR
            SELECT pm.id_paramtable, pm.id_pi_template
            FROM   t_sub s, t_pl_map pm, t_rulesetdefinition rd
            WHERE   s.id_sub = my_id_sub
                AND s.id_po = pm.id_po
                AND decode(pm.id_sub,NULL,1,0) = 1
                AND decode(pm.id_acc,NULL,1,0) = 1
                AND pm.id_paramtable = rd.id_paramtable;
    END get_all_pts_by_sub;
    
    /* Get all the rsched rows for a given subscription/param table combo for a given date range and return a cursor of the id_rsched and dates */
    /* Will need 2 versions of this: one to find the private rscheds (ICBs) the GUI looks at and one to find the public rscheds (ICBs + inheritance) the pipeline looks at */
    /* Only difference is which version of t_rsched we go to */
    PROCEDURE get_id_sched(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_sched_curs OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN my_id_sched_curs FOR
            SELECT r.id_sched, e.dt_start, e.dt_end
            FROM   t_pl_map pm
                INNER JOIN t_rsched r on r.id_pricelist = pm.id_pricelist and r.id_pt = my_id_pt and pm.id_pi_template = r.id_pi_template
                INNER JOIN t_effectivedate e on r.id_eff_date = e.id_eff_date and determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) <= my_end_dt and determine_absolute_dates(e.dt_end, e.n_endtype, e.n_endoffset,0,0) >= my_start_dt
            WHERE  pm.id_sub = my_id_sub and pm.id_paramtable = my_id_pt and pm.id_pi_template = my_id_pi_template
            ORDER BY e.n_begintype ASC, determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) DESC;
    END get_id_sched;

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
    )
    AS
        my_rsched_start DATE;
        my_rsched_end DATE;
        my_id_sub_curs SYS_REFCURSOR;
        my_id_sched_curs SYS_REFCURSOR;
        my_id_gsub_curs SYS_REFCURSOR;
        my_parent_sub_start DATE;
        my_parent_sub_end DATE;
        my_parent_id_sub NUMBER;
        my_parent_sched_start DATE;
        my_parent_sched_end DATE;
        my_parent_id_sched NUMBER;
        my_param_def_array TP_PARAM_TABLE_DEF;
        my_schedule_array TP_SCHEDULE_ARRAY;
        my_empty_schedule_array TP_SCHEDULE_ARRAY;
        my_empty_param_assoc_array TP_PARAM_ASSOC;
        my_schedule TP_SCHEDULE;
        my_child_id_acc NUMBER;
        my_child_id_sub NUMBER;
        my_child_sched_start DATE;
        my_child_sched_end DATE;
        my_child_id_sched NUMBER;
        my_id_pricelist NUMBER;
        my_id_pi_template NUMBER;
        my_id_sub NUMBER;
        my_id_po NUMBER;
        l_id_sched     NUMBER;
        l_cnt NUMBER;
    BEGIN
        my_id_sub := v_id_sub;
        my_id_po := v_id_po;

        IF (my_id_sched IS NOT NULL) THEN
            SELECT determine_absolute_dates(ed.dt_start, ed.n_begintype, ed.n_beginoffset, my_id_acc, 1) start_date,
             determine_absolute_dates(ed.dt_end, ed.n_endtype, ed.n_endoffset, my_id_acc, 0) end_date,
             r.id_pricelist, r.id_pi_template
             into my_rsched_start, my_rsched_end, my_id_pricelist, my_id_pi_template
             from t_rsched r, t_effectivedate ed
             where r.id_sched = my_id_sched
             and r.id_eff_date = ed.id_eff_date;
            
            IF (my_id_sub IS NULL or my_id_po IS NULL) THEN
                SELECT MIN(id_sub), MIN(id_po) INTO my_id_sub, my_id_po FROM t_pl_map pm, t_rsched rs
                WHERE  rs.id_sched = my_id_sched
                  AND rs.id_pricelist = pm.id_pricelist
                  AND rs.id_pi_template = pm.id_pi_template
                  AND pm.id_paramtable = my_id_pt
                  AND rs.id_pt = pm.id_paramtable
                  AND id_sub IS NOT NULL;
            END IF;
        ELSE
            /* FIXME: derive id_pricelist and id_pi_template */
            SELECT vt_start, NVL(vt_end,mtmaxdate()) INTO my_rsched_start, my_rsched_end FROM t_sub WHERE id_sub = my_id_sub;
            IF (v_id_pi_template IS NULL) THEN
              get_id_pi_template (my_id_sub, my_param_def_array.id_pt, my_id_pi_template);
            ELSE
              my_id_pi_template := v_id_pi_template;
            END IF;
            get_id_pl_by_pt(my_id_acc, my_id_sub, my_param_def_array.id_pt, my_id_pi_template, my_id_pricelist);
        END IF;
        mt_load_param_table_def(my_id_pt, cached_param_defs, my_param_def_array);
        /* loop over all private scheds ORDER BY n_begin_type ASC, determine_absolute_dates(dt_start) */
        get_id_sched(my_id_sub, my_param_def_array.id_pt, my_id_pi_template, mtmindate(), mtmaxdate(), my_id_sched_curs);
        LOOP
          FETCH my_id_sched_curs INTO l_id_sched, my_rsched_start, my_rsched_end;
          EXIT WHEN my_id_sched_curs%NOTFOUND;
          mt_resolve_overlaps_by_sched (my_id_acc, my_rsched_start, my_rsched_end, 1, -1, 0, my_param_def_array, my_schedule_array, l_id_sched, my_schedule_array);
        END LOOP;
        CLOSE my_id_sched_curs;
        my_rsched_start := mtmindate();
        my_rsched_end := mtmaxdate();

        get_inherit_id_sub(my_id_acc, my_id_po, my_rsched_start, my_rsched_end, my_id_sub_curs);
        LOOP
            FETCH my_id_sub_curs INTO my_parent_id_sub, my_parent_sub_start, my_parent_sub_end;
            EXIT WHEN my_id_sub_curs%NOTFOUND;
            IF (my_parent_sub_start < my_rsched_start) THEN
                my_parent_sub_start := my_rsched_start;
            END IF;
            IF (my_parent_sub_end > my_rsched_end) THEN
                my_parent_sub_end := my_rsched_end;
            END IF;
            get_id_sched_pub(my_parent_id_sub, my_id_pt, my_id_pi_template, my_parent_sub_start, my_parent_sub_end, my_id_sched_curs);
            LOOP
                FETCH my_id_sched_curs INTO my_parent_id_sched, my_parent_sched_start, my_parent_sched_end;
                EXIT WHEN my_id_sched_curs%NOTFOUND;
                IF (my_parent_sched_start < my_parent_sub_start) THEN
                    my_parent_sched_start := my_parent_sub_start;
                END IF;
                IF (my_parent_sched_end < my_parent_sub_end) THEN
                    my_parent_sched_end := my_parent_sub_end;
                END IF;
                mt_resolve_overlaps_by_sched (my_id_acc, my_parent_sched_start, my_parent_sched_end, 1, 1, 0, my_param_def_array, my_schedule_array, my_parent_id_sched, my_schedule_array);
            END LOOP;
        END LOOP;
        CLOSE my_id_sub_curs;
        templt_write_schedules(my_id_acc, my_id_sub, v_id_audit, 1, my_id_pricelist, my_id_pi_template, my_param_def_array, my_schedule_array, v_id_csr);
        IF (pass_to_children = 1) THEN
            get_child_gsubs_private(my_id_acc, my_id_po, my_rsched_start, my_rsched_end, my_id_gsub_curs);
            LOOP
                FETCH my_id_gsub_curs INTO my_child_id_acc, my_child_id_sub;
                EXIT WHEN my_id_gsub_curs%NOTFOUND;
                get_id_sched(my_child_id_sub, my_id_pt, my_id_pi_template, my_rsched_start, my_rsched_end, my_id_sched_curs);
                l_cnt := 0;
                LOOP
                    FETCH my_id_sched_curs INTO my_child_id_sched, my_child_sched_start, my_child_sched_end;
                    EXIT WHEN my_id_sched_curs%NOTFOUND;
                    l_cnt := l_cnt + 1;
                    recursive_inherit(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, my_child_id_sched, my_id_pt, 0, cached_param_defs, v_id_csr);
                END LOOP;
                IF (l_cnt = 0) THEN
                    recursive_inherit(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, NULL, my_id_pt, 0, cached_param_defs, v_id_csr);
                END IF;
          CLOSE my_id_sched_curs;
            END LOOP;
          CLOSE my_id_gsub_curs;
        END IF;
    END recursive_inherit;

    PROCEDURE get_child_gsubs_private(
        my_id_acc NUMBER,
        my_id_po NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_gsub_curs OUT SYS_REFCURSOR
    )
    AS
    BEGIN
    OPEN my_id_gsub_curs FOR
        SELECT /*+ ORDERED USE_NL(AT ats s) */ aa.id_descendent id_acc, s.id_sub
        FROM   t_account_ancestor aa
            INNER JOIN t_acc_template at ON aa.id_descendent = at.id_folder
            INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
            INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = my_id_po
        WHERE   aa.id_ancestor = my_id_acc
            and num_generations > 0
            and s.vt_start < my_end_dt
            and s.vt_end > my_start_dt
        ORDER BY aa.num_generations ASC;
    END get_child_gsubs_private;

    /* Get the id_pi_template for a given id_sub/id_pt */
    PROCEDURE get_id_pi_template(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template OUT NUMBER
    )
    AS
    BEGIN
        SELECT MIN(id_pi_template)
        INTO   my_id_pi_template
        FROM   t_pl_map a, t_sub b
        WHERE  b.id_sub = my_id_sub
            AND nvl2(a.id_sub,NULL,0) = 0
            AND a.id_po = b.id_po
            AND a.id_paramtable = my_id_pt;
    END get_id_pi_template;

    /* Get the id_pricelist for a given id_sub */
    PROCEDURE get_id_pl_by_pt(
        my_id_acc NUMBER,
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_id_pricelist OUT NUMBER
    )
    AS
        my_currency_code VARCHAR2(100);
    BEGIN
        SELECT NVL(MIN(pm.id_pricelist),0)
        INTO   my_id_pricelist
        FROM   t_pl_map pm
            INNER JOIN t_pricelist pl ON pm.id_pricelist = pl.id_pricelist AND pl.n_type = 0
        WHERE id_sub = my_id_sub AND pm.id_paramtable = my_id_pt AND pm.id_pi_template = my_id_pi_template;
        
        IF (my_id_pricelist = 0) THEN
            SELECT c_currency INTO my_currency_code FROM t_av_internal WHERE id_acc = my_id_acc;
            SELECT SEQ_T_BASE_PROPS.NEXTVAL INTO my_id_pricelist FROM dual;
            
            INSERT INTO t_base_props
                        (id_prop, n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name)
                 VALUES (my_id_pricelist, 150, 0, 0, NULL, NULL, 'N', 'N', 0, NULL);
            INSERT INTO t_pricelist
                        (id_pricelist, n_type, nm_currency_code)
                VALUES  (my_id_pricelist, 0, my_currency_code);
        END IF;
    END get_id_pl_by_pt;

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
    )
    IS
      l_schedule TP_SCHEDULE;
      l_empty    TP_PARAM_ASSOC;
    BEGIN
      mt_load_schedule (v_id_sched, v_start, v_end, 0, v_pt, l_empty, l_schedule);
      mt_resolve_overlaps (v_id_acc, v_replace_nulls, v_merge_rates, v_reuse_sched, 0, v_pt.param_defs, v_schedules_in, l_schedule, v_schedules_out);
    END mt_resolve_overlaps_by_sched;

    /* Get the nearest account in the hierarchy with the given id_acc/id_po combination in their template (inheritance ONLY works for the same id_po) */
    /* Return all matches from the template (assuming template subscriptions have active dates, which isn't currently the case, but needs to be fixed) */
    /* NOTE: This proc relies on t_acc_template_subs_pub, which won't exist unless the template inheritance stuff is on the DB already */
    PROCEDURE get_inherit_id_sub(
        my_id_acc NUMBER,
        my_id_po NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        inherit_id_sub_curs OUT SYS_REFCURSOR
    )
    AS
        my_anc_curs SYS_REFCURSOR;
        inherit_id_acc_templt_pub NUMBER(10);
    BEGIN
        OPEN my_anc_curs FOR
        SELECT /*+ ORDERED USE_NL(AT ats s) */ ats.id_acc_template
        FROM   t_account_ancestor aa
            INNER JOIN t_acc_template at ON aa.id_ancestor = at.id_folder
            INNER JOIN t_acc_template_subs ats ON at.id_acc_template = ats.id_acc_template
            INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = my_id_po
        WHERE aa.id_descendent = my_id_acc
            AND aa.id_ancestor != aa.id_descendent
        ORDER BY aa.num_generations ASC, id_acc_template DESC;
        
        FETCH my_anc_curs INTO inherit_id_acc_templt_pub;
        CLOSE my_anc_curs;
        OPEN inherit_id_sub_curs FOR
            SELECT s.id_sub, CASE WHEN ats.vt_start < my_start_dt THEN my_start_dt ELSE ats.vt_start END,
              CASE WHEN ats.vt_end > my_end_dt THEN my_end_dt ELSE ats.vt_end END
            FROM   t_acc_template_subs ats
                INNER JOIN t_sub s ON s.id_group = ats.id_group AND s.id_po = my_id_po
            WHERE  ats.id_acc_template = inherit_id_acc_templt_pub
                AND ats.vt_start < my_end_dt
                AND ats.vt_end > my_start_dt
            ORDER BY ats.vt_start, ats.vt_end;
    END get_inherit_id_sub;

    /* Get all the rsched rows for a given subscription/param table combo for a given date range and return a cursor of the id_rsched and dates */
    /* Will need 2 versions of this: one to find the private rscheds (ICBs) the GUI looks at and one to find the public rscheds (ICBs + inheritance) the pipeline looks at */
    /* Only difference is which version of t_rsched we go to */
    PROCEDURE get_id_sched_pub(
        my_id_sub NUMBER,
        my_id_pt NUMBER,
        my_id_pi_template NUMBER,
        my_start_dt DATE,
        my_end_dt DATE,
        my_id_sched_curs OUT SYS_REFCURSOR
    )
    AS
    BEGIN
        OPEN my_id_sched_curs FOR
            SELECT r.id_sched,
                   case when e.dt_start < my_start_dt then my_start_dt else e.dt_start end start_dt,
                   case when e.dt_end > my_end_dt then my_end_dt else e.dt_end end end_dt
            FROM   t_pl_map pm
                INNER JOIN t_rsched_pub r on r.id_pricelist = pm.id_pricelist and r.id_pt = my_id_pt and pm.id_pi_template = r.id_pi_template
                INNER JOIN t_effectivedate e on r.id_eff_date = e.id_eff_date and determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) <= my_end_dt and determine_absolute_dates(e.dt_end, e.n_endtype, e.n_endoffset,0,0) >= my_start_dt
            WHERE  pm.id_sub = my_id_sub and pm.id_paramtable = my_id_pt and pm.id_pi_template = my_id_pi_template
            ORDER BY e.n_begintype ASC, determine_absolute_dates(e.dt_start,e.n_begintype, e.n_beginoffset,0,1) DESC;
    END get_id_sched_pub;
    
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
    )
    IS
     sched_idx NUMBER;
     rates_idx NUMBER;
     my_schedule TP_SCHEDULE;
     my_rates TP_PARAM_ARRAY;
     l_n_order  NUMBER := 0;
     l_sql      VARCHAR2 (4000);
     l_sql_explicit VARCHAR2 (4000);
     l_i        NUMBER;
     l_rate     TP_PARAM_ROW;
     l_id_prm   NUMBER;
     l_param_id NUMBER;
     l_id_audit NUMBER;
     is_persisted NUMBER;
     my_id_pricelist NUMBER;
     my_id_pi_template NUMBER;
     my_rate TP_PARAM_ROW;
     my_tt_date_cutoff DATE;
     l_vali NUMBER;
     l_val1     NVARCHAR2 (100);
     l_val2     NVARCHAR2 (100);
     l_val3     NVARCHAR2 (100);
     l_val4     NVARCHAR2 (100);
     l_val5     NVARCHAR2 (100);
     l_val6     NVARCHAR2 (100);
     l_val7     NVARCHAR2 (100);
     l_val8     NVARCHAR2 (100);
     l_val9     NVARCHAR2 (100);
     l_val10     NVARCHAR2 (100);
     l_val11     NVARCHAR2 (100);
     l_val12     NVARCHAR2 (100);
     l_val13     NVARCHAR2 (100);
     l_val14     NVARCHAR2 (100);
     l_val15     NVARCHAR2 (100);
    BEGIN
        select getutcdate() into my_tt_date_cutoff from dual;
        my_id_pricelist := v_id_pricelist;
        my_id_pi_template := v_id_pi_template;
        IF (my_id_pi_template = 0 or my_id_pi_template IS NULL) THEN
            get_id_pi_template(my_id_sub, v_param_table_def.id_pt, my_id_pi_template);
        END IF;
        IF (my_id_pricelist = 0 or my_id_pricelist IS NULL) THEN
            get_id_pl_by_pt(my_id_acc, my_id_sub, v_param_table_def.id_pt, my_id_pi_template, my_id_pricelist);
        END IF;
        IF (is_public = 1) THEN
          my_schedule.id_sched := NULL;
          /* do not date bound it, nuke them all */
          l_sql := 'DELETE ' || v_param_table_def.nm_pt || ' WHERE id_sched in(select id_sched from t_rsched_pub a, t_pl_map c where c.id_sub = :v_id_sub and c.id_paramtable = :v_id_paramtable and c.id_pricelist = a.id_pricelist and c.id_paramtable = a.id_pt and c.id_pi_template = a.id_pi_template)';
          EXECUTE IMMEDIATE l_sql USING my_id_sub, v_param_table_def.id_pt;
          DELETE t_rsched_pub WHERE id_sched in(select id_sched from t_rsched_pub a, t_pl_map c where c.id_sub = my_id_sub and c.id_paramtable = v_param_table_def.id_pt and c.id_pricelist = a.id_pricelist and c.id_paramtable = a.id_pt and a.id_pi_template = c.id_pi_template);
        END IF;
        sched_idx := v_schedules.first();
        WHILE (sched_idx IS NOT NULL)
        LOOP
            is_persisted := 0;
            my_schedule := v_schedules(sched_idx);
            IF (is_public = 1) THEN
                my_schedule.id_sched := NULL;
            END IF;
            IF (my_schedule.chg_dates > 0 and my_schedule.id_sched IS NOT NULL and is_public = 0) THEN
            is_persisted := 1;
                templt_persist_rsched(my_id_acc,v_param_table_def.id_pt,my_schedule.id_sched, my_id_pricelist, my_id_pi_template, my_schedule.tt_start, 1, 0, my_schedule.tt_end,1,0,is_public, my_id_sub, v_id_csr);
            END IF;
            IF (is_public = 1 or my_schedule.chg_rates > 0 or my_schedule.id_sched IS NULL) THEN
                IF (v_id_audit = 0 or v_id_audit IS NULL) THEN
                    l_sql := 'SELECT nvl(max(id_audit + 1),1) from ' || v_param_table_def.nm_pt || ' where id_sched = :v_id_sched';
                    EXECUTE IMMEDIATE l_sql into l_id_audit USING my_schedule.id_sched;
                ELSE
                    l_id_audit := v_id_audit;
                END IF;
                IF (is_public = 0) THEN
                    l_sql := 'UPDATE ' || v_param_table_def.nm_pt || ' SET tt_end = :l_tt_end WHERE id_sched = :v_id_sched AND tt_end = mtmaxdate()';
                    EXECUTE IMMEDIATE l_sql USING my_tt_date_cutoff-(1/24/60/60), my_schedule.id_sched;
                END IF;
                l_n_order := 0;
                rates_idx := my_schedule.rates.first();
                WHILE (rates_idx IS NOT NULL)
                LOOP
              IF (is_persisted = 0 and rates_idx = 0 and my_schedule.id_sched IS NULL) THEN
                is_persisted := 1;
                templt_persist_rsched(my_id_acc,v_param_table_def.id_pt,my_schedule.id_sched, my_id_pricelist, my_id_pi_template, my_schedule.tt_start, 1, 0, my_schedule.tt_end,1,0,is_public, my_id_sub, v_id_csr);
              ELSE
                IF (is_persisted = 0 and is_public = 0) THEN
                  is_persisted := 1;
                  /* insert rate schedule rules audit */
                  getcurrentid('id_audit', l_id_audit);
                  InsertAuditEvent (
                    v_id_csr,
                    1402,
                    2,
                    my_schedule.id_sched,
                    getutcdate(),
                    l_id_audit,
                    'MASS RATE: Updating rules for param table: ' || v_param_table_def.nm_pt || ' Rate Schedule Id: ' || my_schedule.id_sched,
                    v_id_csr,
                    NULL
                  );
                END IF;
              END IF;
                    my_rate := my_schedule.rates(rates_idx);
                    l_sql := 'INSERT INTO ' || v_param_table_def.nm_pt || ' (id_sched, id_audit, n_order, tt_start, tt_end';
                    l_vali := 0;
                    l_id_prm := v_param_table_def.param_defs.first ();
                    WHILE (l_id_prm IS NOT NULL)
                    LOOP
                        l_vali := l_vali + 1;
                        l_sql := l_sql || ', ' || v_param_table_def.param_defs (l_id_prm).nm_column_name;
                        l_sql_explicit := l_sql_explicit || ' l_' || l_vali || ' NVARCHAR2(100) := :l_' || l_vali || ';';
                        l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
                    END LOOP;
                    l_sql := l_sql || ') VALUES (:v_id_sched, :v_id_audit, :l_n_order, :v_tt_start, mtmaxdate()';
                    l_sql_explicit := l_sql;
                    l_id_prm := v_param_table_def.param_defs.first ();
                    l_val1 := NULL;
                    l_val2 := NULL;
                    l_val3 := NULL;
                    l_val4 := NULL;
                    l_val5 := NULL;
                    l_val6 := NULL;
                    l_val7 := NULL;
                    l_val8 := NULL;
                    l_val9 := NULL;
                    l_val10 := NULL;
                    l_val11 := NULL;
                    l_val12 := NULL;
                    l_val13 := NULL;
                    l_val14 := NULL;
                    l_val15 := NULL;
                    l_vali := 0;
                    WHILE (l_id_prm IS NOT NULL)
                    LOOP
                        l_param_id := v_param_table_def.param_defs (l_id_prm).id_param_table_prop;
                        l_vali := l_vali + 1;
                        IF (my_rate.params.exists (l_param_id)) THEN
                            l_sql := l_sql || ', ''' || my_rate.params (l_param_id) || '''';
                            IF (l_vali = 1) THEN l_val1 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 2) THEN l_val2 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 3) THEN l_val3 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 4) THEN l_val4 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 5) THEN l_val5 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 6) THEN l_val6 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 7) THEN l_val7 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 8) THEN l_val8 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 9) THEN l_val9 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 10) THEN l_val10 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 11) THEN l_val11 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 12) THEN l_val12 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 13) THEN l_val13 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 14) THEN l_val14 := my_rate.params (l_param_id); END IF;
                            IF (l_vali = 15) THEN l_val15 := my_rate.params (l_param_id); END IF;
                        ELSE
                            l_sql := l_sql || ', NULL';
                            IF (l_vali = 1) THEN l_val1 := NULL; END IF;
                            IF (l_vali = 2) THEN l_val2 := NULL; END IF;
                            IF (l_vali = 3) THEN l_val3 := NULL; END IF;
                            IF (l_vali = 4) THEN l_val4 := NULL; END IF;
                            IF (l_vali = 5) THEN l_val5 := NULL; END IF;
                            IF (l_vali = 6) THEN l_val6 := NULL; END IF;
                            IF (l_vali = 7) THEN l_val7 := NULL; END IF;
                            IF (l_vali = 8) THEN l_val8 := NULL; END IF;
                            IF (l_vali = 9) THEN l_val9 := NULL; END IF;
                            IF (l_vali = 10) THEN l_val10 := NULL; END IF;
                            IF (l_vali = 11) THEN l_val11 := NULL; END IF;
                            IF (l_vali = 12) THEN l_val12 := NULL; END IF;
                            IF (l_vali = 13) THEN l_val13 := NULL; END IF;
                            IF (l_vali = 14) THEN l_val14 := NULL; END IF;
                            IF (l_vali = 15) THEN l_val15 := NULL; END IF;
                        END IF;
                        IF (l_vali = v_param_table_def.param_defs.COUNT) THEN
                            l_sql_explicit := l_sql_explicit || ', DECODE(1,1,:l_' || l_vali;
                            WHILE (l_vali < 15)
                            LOOP
                              l_vali := l_vali + 1;
                              l_sql_explicit := l_sql_explicit || ',' || l_vali || ',:l_' || l_vali;
                            END LOOP;
                            l_sql_explicit := l_sql_explicit || ')';
                        ELSE
                            l_sql_explicit := l_sql_explicit || ', :l_' || l_vali;
                        END IF;
                        l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
                    END LOOP;
                    l_sql := l_sql || ')';
                    l_sql_explicit := l_sql_explicit || ')';
                    IF (v_param_table_def.param_defs.COUNT > 15) THEN
                      EXECUTE IMMEDIATE l_sql USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff;
                    ELSE
                      EXECUTE IMMEDIATE l_sql_explicit USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff,
                                                             l_val1, l_val2, l_val3, l_val4, l_val5, l_val6, l_val7, l_val8,
                                                             l_val9, l_val10, l_val11, l_val12, l_val13, l_val14, l_val15;
                    END IF;
                    l_n_order := l_n_order + 1;
                    rates_idx := my_schedule.rates.next(rates_idx);
                END LOOP;
            END IF;
            v_schedules(sched_idx) := my_schedule;
            sched_idx := v_schedules.next(sched_idx);
        END LOOP;
    END templt_write_schedules;
    
    PROCEDURE mt_load_schedule (
        v_id_sched IN NUMBER,
        v_start IN DATE,
        v_end IN DATE,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals IN TP_PARAM_ASSOC,
        v_schedule OUT TP_SCHEDULE
    )
    IS
    BEGIN
      mt_load_schedule_params (v_id_sched, v_is_wildcard, v_pt, v_filter_vals, v_schedule.rates);
      v_schedule.id_sched := v_id_sched;
      v_schedule.tt_start := v_start;
      v_schedule.tt_end   := v_end;
    END mt_load_schedule;

    PROCEDURE mt_load_schedule_params(
        v_id_sched IN NUMBER,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals IN TP_PARAM_ASSOC,
        v_rates IN OUT TP_PARAM_ARRAY
    )
    IS
      l_sql        VARCHAR2 (2048);
      l_cursor     SYS_REFCURSOR;
      l_first      NUMBER := 1;
      l_value      NVARCHAR2 (100);
      l_row        NUMBER;
      l_id_param   NUMBER;
      l_id_sched   NUMBER;
      l_id_audit   NUMBER;
      l_n_order    NUMBER;
      l_start      DATE;
      l_end        DATE;
      l_current    NUMBER := NULL;
      l_id         NUMBER := NULL;
      l_pd         TP_PARAM_DEF;
      l_param_defs TP_PARAM_DEF_ARRAY := v_pt.param_defs;
    BEGIN
      l_sql := 'SELECT /*+ INDEX(A END_'|| SUBSTR(v_pt.nm_pt, 0, 19) ||'_IDX) */ id_sched, id_audit, n_order, tt_start, tt_end, id_param_table_prop p_id, DECODE (id_param_table_prop';
      l_row := l_param_defs.first ();
      WHILE (l_row IS NOT NULL)
      LOOP
        l_sql := l_sql || ', ' || l_param_defs (l_row).id_param_table_prop || ', TO_CHAR(' || l_param_defs (l_row).nm_column_name || ')';
        l_row := l_param_defs.next (l_row);
      END LOOP;
      l_sql := l_sql || ') p_val FROM ' || v_pt.nm_pt || ' A, T_PARAM_TABLE_PROP B WHERE id_sched = :v_id_sched AND tt_end = :l_max_date AND id_param_table = :id_pt';
      IF (v_filter_vals IS NOT NULL AND v_filter_vals.COUNT > 0) THEN
        /* add in filtering */
        l_id_param := l_param_defs.first ();
        WHILE (l_id_param IS NOT NULL)
        LOOP
          l_pd := l_param_defs (l_id_param);
          IF (l_pd.is_rate_key <> 0) THEN
            l_value := NULL;
            IF (v_filter_vals.exists (l_pd.id_param_table_prop)) THEN
              l_value := v_filter_vals (l_pd.id_param_table_prop);
            END IF;
            IF (l_value IS NULL) THEN
              IF (v_is_wildcard = 0) THEN
                l_sql := l_sql || ' AND ' || l_pd.nm_column_name || ' IS NULL';
              END IF;
            ELSE
              l_sql := l_sql || ' AND ' || l_pd.nm_column_name || ' = ''' || l_value || '''';
            END IF;
          END IF;
          l_id_param := l_param_defs.next (l_id_param);
        END LOOP;
      END IF;
      l_sql := l_sql || ' ORDER BY n_order ASC';
      OPEN l_cursor FOR l_sql USING v_id_sched, mtmaxdate (), v_pt.id_pt;
      LOOP
        FETCH l_cursor INTO l_id_sched, l_id_audit, l_n_order, l_start, l_end, l_id_param, l_value;
        EXIT WHEN l_cursor%NOTFOUND;
        IF (l_id_param IS NOT NULL) THEN
          DECLARE
            l_params TP_PARAM_ROW;
          BEGIN
            IF (l_current IS NULL OR l_current <> l_n_order) THEN
              l_current := l_n_order;
              l_id := v_rates.COUNT;
              l_params.id_sched := l_id_sched;
              l_params.id_audit := l_id_audit;
              l_params.n_order := l_n_order;
              l_params.updated := 0;
            ELSE
              l_params := v_rates (l_id);
            END IF;
            IF (l_value IS NOT NULL) THEN
              l_params.params(l_id_param) := l_value;
            END IF;
            v_rates (l_id) := l_params;
          END;
        END IF;
      END LOOP;
      CLOSE l_cursor;
    END mt_load_schedule_params;

    /* for v_merge_rates (0 means null-replacement only, < 0 means add but no merge, > 0 means full merge */
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
    )
    IS
      l_schedule_i   NUMBER;
      l_schedule     TP_SCHEDULE;
      l_schedule_new TP_SCHEDULE := v_schedule_new;
      l_s_start      DATE;
      l_s_end        DATE;
      l_s_n_start    DATE;
      l_s_n_end      DATE;
      l_start        DATE := NULL;
      l_last_new_i   NUMBER := NULL;
    BEGIN

      IF (l_schedule_new.tt_start IS NULL) THEN
        l_s_n_start := determine_absolute_dates(l_schedule_new.tt_start, 4, 0, v_id_acc, 1);
      ELSE
        l_s_n_start := l_schedule_new.tt_start;
      END IF;
      IF (l_schedule_new.tt_end IS NULL) THEN
        l_s_n_end := determine_absolute_dates(l_schedule_new.tt_end, 4, 0, v_id_acc, 0);
      ELSE
        l_s_n_end := l_schedule_new.tt_end;
      END IF;

      l_schedule_i := v_schedules_in.first ();
      WHILE (l_schedule_i IS NOT NULL)
      LOOP
        DECLARE
          l_schedule_0 TP_SCHEDULE;
          l_schedule_1 TP_SCHEDULE;
          l_schedule_2 TP_SCHEDULE;
          l_schedule_3 TP_SCHEDULE;
          l_tmp_rates  TP_PARAM_ARRAY;
        BEGIN
          l_schedule := v_schedules_in (l_schedule_i);
          IF (l_schedule.tt_start IS NULL) THEN
            l_s_start := determine_absolute_dates(l_schedule.tt_start, 4, 0, v_id_acc, 1);
          ELSE
            l_s_start := l_schedule.tt_start;
          END IF;
          IF (l_schedule.tt_end IS NULL) THEN
            l_s_end := determine_absolute_dates(l_schedule.tt_end, 4, 0, v_id_acc, 0);
          ELSE
            l_s_end := l_schedule.tt_end;
          END IF;
          IF (v_merge_rates <> 0 AND (l_s_start > l_s_n_start AND (l_start IS NULL OR l_start <= l_s_n_start))) THEN
            /* gap in the existing schedules, where l_schedule_new will fit in */
            IF (l_s_n_end < l_s_start) THEN
              /* l_schedule_new fits into the gap cleanly, so we add it */
              /* v.start -> v.end (new) */
              IF (v_reuse_sched <> 0) THEN
                l_schedule_0.id_sched := l_schedule_new.id_sched;
                l_schedule_0.chg_rates := l_schedule_new.chg_rates;
                l_schedule_new.id_sched := NULL;
              ELSE
                l_schedule_0.id_sched := NULL;
                l_schedule_0.chg_rates := 1;
              END IF;
              l_schedule_0.tt_start := l_schedule_new.tt_start;
              l_schedule_0.tt_end := l_schedule_new.tt_end;
              l_schedule_0.rates := l_schedule_new.rates;
              l_schedule_0.chg_dates := l_schedule_new.chg_dates;
              v_schedules_out (v_schedules_out.COUNT) := l_schedule_0;
            ELSE
              /* l_schedule_new overlaps with l_schedule, so we add just the non-overlap to the gap (overlap will be handled by code below) */
              /* v.start -> l.start (new) (v.start := l.start) */
              IF (v_reuse_sched <> 0) THEN
                l_schedule_0.id_sched := l_schedule_new.id_sched;
                l_schedule_0.chg_rates := l_schedule_new.chg_rates;
                l_schedule_new.id_sched := NULL;
              ELSE
                l_schedule_0.id_sched := NULL;
                l_schedule_0.chg_rates := 1;
              END IF;
              l_schedule_0.tt_start := l_schedule_new.tt_start;
              l_schedule_0.tt_end := l_schedule.tt_start;
              l_schedule_0.rates := l_schedule_new.rates;
              l_schedule_0.chg_dates := 1;
              v_schedules_out (v_schedules_out.COUNT) := l_schedule_0;
              l_schedule_new.tt_start := l_schedule.tt_start;
              IF (l_schedule_new.tt_start IS NULL) THEN
                l_s_n_start := determine_absolute_dates(l_schedule_new.tt_start, 4, 0, v_id_acc, 1);
              ELSE
                l_s_n_start := l_schedule_new.tt_start;
              END IF;
              l_schedule_new.chg_dates := 1;
            END IF;
          END IF;
          IF (l_s_n_start < l_s_end AND l_s_n_end > l_s_start) THEN
            /* this means that l_schedule_new overlaps with l_schedule, so we WILL be merging and/or bisecting */
            IF (l_s_start < l_s_n_start) THEN
              /* l_schedule starts before l_schedule_new */
              IF (l_s_end <= l_s_n_end) THEN
                /* l_schedule starts and ends before l_schedule_new, so we bisect then add l_schedule (with new dates) and then portion of l_schedule_new */
                /* l.start -> v.start (orig) , v.start -> l.end (merged) (v.start := l.end) == bisect with possible leftover */
                l_schedule_1.id_sched := l_schedule.id_sched;
                l_schedule_1.tt_start := l_schedule.tt_start;
                l_schedule_1.tt_end := l_schedule_new.tt_start;
                l_schedule_1.rates := l_schedule.rates;
                l_schedule_1.chg_rates := l_schedule.chg_rates;
                l_schedule_1.chg_dates := 1;
                IF (v_reuse_sched <> 0 AND l_schedule_1.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_1;
                /* we can reuse l_schedule_new here */
                IF (l_s_end = l_s_n_end AND v_reuse_sched <> 0) THEN
                  l_schedule_2.id_sched := l_schedule_new.id_sched;
                  l_schedule_new.id_sched := NULL;
                  l_schedule_new.chg_dates := 1;
                ELSE
                  l_schedule_2.id_sched := NULL;
                END IF;
                l_schedule_2.tt_start := l_schedule_new.tt_start;
                l_schedule_2.tt_end := l_schedule.tt_end;
                l_schedule_2.rates := l_schedule.rates;
                l_schedule_2.chg_rates := 1;
                l_schedule_2.chg_dates := 1;
                IF (v_replace_nulls <> 0) THEN
                  mt_replace_nulls (v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates);
                ELSE
                  l_tmp_rates := l_schedule.rates;
                END IF;
                IF (v_merge_rates > 0) THEN
                  mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates);
                ELSE
                  l_schedule_2.rates := l_tmp_rates;
                END IF;
                IF (v_reuse_sched <> 0 AND l_schedule_2.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_2;
                l_schedule_new.tt_start := l_schedule.tt_end;
                IF (l_schedule_new.tt_start IS NULL) THEN
                  l_s_n_start := determine_absolute_dates(l_schedule_new.tt_start, 4, 0, v_id_acc, 1);
                ELSE
                  l_s_n_start := l_schedule_new.tt_start;
                END IF;
                l_schedule_new.chg_dates := 1;
              ELSE
                /* l_schedule starts before l_schedule_new, and ends after it, so we trisect then add l_schedule (with new dates) then l_schedule_new, then remainder of l_schedule */
                /* l.start -> v.start (orig), v.start -> v.end (merged), v.end -> l.end (orig) == trisect */
                l_schedule_1.id_sched := l_schedule.id_sched;
                l_schedule_1.tt_start := l_schedule.tt_start;
                l_schedule_1.tt_end := l_schedule_new.tt_start;
                l_schedule_1.rates := l_schedule.rates;
                l_schedule_1.chg_rates := l_schedule.chg_rates;
                l_schedule_1.chg_dates := 1;
                IF (v_reuse_sched <> 0 AND l_schedule_1.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_1;
                /* we can reuse l_schedule_new here */
                IF (v_reuse_sched <> 0) THEN
                  l_schedule_2.id_sched := l_schedule_new.id_sched;
                  l_schedule_new.id_sched := NULL;
                ELSE
                  l_schedule_2.id_sched := NULL;
                END IF;
                l_schedule_2.tt_start := l_schedule_new.tt_start;
                l_schedule_2.tt_end := l_schedule_new.tt_end;
                l_schedule_2.chg_rates := 1;
                l_schedule_2.chg_dates := l_schedule_new.chg_dates;
                IF (v_replace_nulls <> 0) THEN
                  mt_replace_nulls (v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates);
                ELSE
                  l_tmp_rates := l_schedule.rates;
                END IF;
                IF (v_merge_rates > 0) THEN
                  mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates);
                ELSE
                  l_schedule_2.rates := l_tmp_rates;
                END IF;
                IF (v_reuse_sched <> 0 AND l_schedule_2.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_2;
                l_schedule_3.id_sched := NULL;
                l_schedule_3.tt_start := l_schedule_new.tt_end;
                l_schedule_3.tt_end := l_schedule.tt_end;
                l_schedule_3.rates := l_schedule.rates;
                l_schedule_3.chg_rates := 1;
                l_schedule_3.chg_dates := 1;
                IF (v_reuse_sched <> 0 AND l_schedule_3.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_3;
              END IF;
            ELSE
              /* l_schedule starts after (or same as) l_schedule_new */
              IF (l_s_end <= l_s_n_end) THEN
                /* l_schedule is completely encompassed by l_schedule_new */
                /* l.start -> l.end (merged) (v.start := l.end) == merge with possible leftover */
                l_schedule_1.tt_start := l_schedule.tt_start;
                l_schedule_1.tt_end := l_schedule.tt_end;
                l_schedule_1.id_sched := l_schedule.id_sched;
                IF (l_schedule_1.id_sched IS NULL AND v_reuse_sched <> 0) THEN
                  l_schedule_1.id_sched := l_schedule_new.id_sched;
                  l_schedule_new.id_sched := NULL;
                  IF (l_s_end = l_s_n_end) THEN
                    l_schedule_1.chg_dates := l_schedule_new.chg_dates;
                  ELSE
                    l_schedule_1.chg_dates := 1;
                  END IF;
                ELSE
                  l_schedule_1.chg_dates := l_schedule.chg_dates;
                END IF;
                l_schedule_1.chg_rates := 1;
                IF (v_replace_nulls <> 0) THEN
                  mt_replace_nulls (v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates);
                ELSE
                  l_tmp_rates := l_schedule.rates;
                END IF;
                IF (v_merge_rates > 0) THEN
                  mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates);
                ELSE
                  l_schedule_1.rates := l_tmp_rates;
                END IF;
                IF (v_reuse_sched <> 0 AND l_schedule_1.id_sched IS NULL) THEN
                  l_last_new_i := v_schedules_out.COUNT;
                END IF;
                v_schedules_out (v_schedules_out.COUNT) := l_schedule_1;
                l_schedule_new.tt_start := l_schedule.tt_end;
                IF (l_schedule_new.tt_start IS NULL) THEN
                  l_s_n_start := determine_absolute_dates(l_schedule_new.tt_start, 4, 0, v_id_acc, 1);
                ELSE
                  l_s_n_start := l_schedule_new.tt_start;
                END IF;
                l_schedule_new.chg_dates := 1;
              ELSE
                IF (v_merge_rates > 0) THEN
                  /* l_schedule starts after, and ends after l_schedule_new, we bisect, with first portion merged, second portion original */
                  /* l.start -> v.end (merged), v.end -> l.end (orig) == bisect */
                  l_schedule_1.tt_start := l_schedule.tt_start;
                  l_schedule_1.tt_end := l_schedule_new.tt_end;
                  l_schedule_1.id_sched := l_schedule.id_sched;
                  l_schedule_1.chg_rates := 1;
                  l_schedule_1.chg_dates := l_schedule.chg_dates;
                  IF (v_replace_nulls <> 0) THEN
                    mt_replace_nulls (v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates);
                  ELSE
                    l_tmp_rates := l_schedule.rates;
                  END IF;
                  IF (v_merge_rates > 0) THEN
                    mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates);
                  ELSE
                    l_schedule_1.rates := l_tmp_rates;
                  END IF;
                  IF (v_reuse_sched <> 0 AND l_schedule_1.id_sched IS NULL) THEN
                    l_last_new_i := v_schedules_out.COUNT;
                  END IF;
                  v_schedules_out (v_schedules_out.COUNT) := l_schedule_1;
                  l_schedule_2.tt_start := l_schedule_new.tt_end;
                  l_schedule_2.tt_end := l_schedule.tt_end;
                  l_schedule_2.rates := l_schedule.rates;
                  l_schedule_2.id_sched := NULL;
                  l_schedule_2.chg_rates := 1;
                  l_schedule_2.chg_dates := 1;
                  IF (v_reuse_sched <> 0 AND l_schedule_2.id_sched IS NULL) THEN
                    l_last_new_i := v_schedules_out.COUNT;
                  END IF;
                  v_schedules_out (v_schedules_out.COUNT) := l_schedule_2;
                ELSE
                  /* no merge, or low-profile public merge, which hides the new row */
                  IF (v_reuse_sched <> 0 AND l_schedule.id_sched IS NULL) THEN
                    l_last_new_i := v_schedules_out.COUNT;
                  END IF;
                  v_schedules_out (v_schedules_out.COUNT) := l_schedule;
                END IF;
              END IF;
            END IF;
          ELSE
            /* l_schedule does not overlap with l_schedule_new so we just add l_schedule */
            IF (v_reuse_sched <> 0 AND l_schedule.id_sched IS NULL) THEN
              l_last_new_i := v_schedules_out.COUNT;
            END IF;
            v_schedules_out (v_schedules_out.COUNT) := l_schedule;
          END IF;
          l_start := l_s_end;  /* just marking how far we have traversed */
          l_schedule_i := v_schedules_in.next (l_schedule_i);
        END;
      END LOOP;

      IF (v_merge_rates <> 0) THEN
        IF (v_schedules_in IS NULL OR v_schedules_in.COUNT = 0) THEN
          /* if we didnt use v_schedules_new, then add it (e.g., if v_schedules_in was empty) */
          IF (v_reuse_sched = 0) THEN
            l_schedule_new.id_sched := NULL;
          END IF;
          v_schedules_out (v_schedules_out.COUNT) := l_schedule_new;
          l_schedule_new.id_sched := NULL;
        ELSE
          IF (l_start IS NULL OR (l_start <= l_s_n_start AND l_s_n_end > l_start)) THEN
            DECLARE
              l_schedule_0 TP_SCHEDULE;
            BEGIN
              /* leftover new schedule starts and ends after end of v_schedules and overlaps with v_start/v_end */
              IF (v_reuse_sched <> 0) THEN
                l_schedule_0.id_sched := l_schedule_new.id_sched;
                l_schedule_0.chg_rates := l_schedule_new.chg_rates;
                l_schedule_new.id_sched := NULL;
              ELSE
                l_schedule_0.id_sched := NULL;
                l_schedule_0.chg_rates := 1;
              END IF;
              l_schedule_0.tt_start := l_schedule_new.tt_start;
              l_schedule_0.tt_end := l_schedule_new.tt_end;
              l_schedule_0.chg_dates := l_schedule_new.chg_dates;
              l_schedule_0.rates := l_schedule_new.rates;
              v_schedules_out (v_schedules_out.COUNT) := l_schedule_0;
            END;
          END IF;
        END IF;
      END IF;

      IF (v_reuse_sched <> 0 AND l_schedule_new.id_sched IS NOT NULL AND l_last_new_i IS NOT NULL) THEN
        l_schedule := v_schedules_out (l_last_new_i);
        IF (l_schedule.id_sched IS NULL) THEN
          l_schedule.id_sched := l_schedule_new.id_sched;
          l_schedule.chg_dates := 1;
          l_schedule.chg_rates := 1;
          v_schedules_out (l_last_new_i) := l_schedule;
          l_schedule_new.id_sched := NULL;
        END IF;
      END IF;

      IF (v_reuse_sched <> 0 AND l_schedule_new.id_sched IS NOT NULL) THEN
        l_schedule_new.tt_start := mtmaxdate ();
        l_schedule_new.tt_end := mtmaxdate ();
        l_schedule_new.deleted := 1;
        v_schedules_out (v_schedules_out.COUNT) := l_schedule_new;
      END IF;
    END mt_resolve_overlaps;

    /* Get the id_po for a given id_sub (since we only inherit for a given id_po) */
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
    )
    AS
        my_id_eff_date NUMBER;
        curr_id_cycle_type NUMBER;
        curr_day_of_month NUMBER;
        my_start_dt DATE;
        my_start_type NUMBER;
        my_begin_offset NUMBER;
        my_end_dt DATE;
        my_end_type NUMBER;
        my_end_offset NUMBER;
        my_id_sched NUMBER;
        has_tpl_map NUMBER;
        l_id_audit NUMBER;
    BEGIN
        my_start_type := v_start_type;
        my_start_dt := v_start_dt;
        my_begin_offset := v_begin_offset;
        my_end_type := v_end_type;
        my_end_dt := v_end_dt;
        my_end_offset := v_end_offset;
        my_id_sched := v_id_sched;
        /* Cleanup relative dates. TBD: not handling type 2 (subscription relative) */
        my_start_dt := determine_absolute_dates(my_start_dt, my_start_type, my_begin_offset, my_id_acc, 1);
        my_end_dt := determine_absolute_dates(my_end_dt, my_end_type, my_end_offset, my_id_acc, 0);
        my_start_type := 1;
        my_begin_offset := 0;
        my_end_type := 1;
        my_end_offset := 0;

        IF (my_id_sched IS NULL) THEN
            select SEQ_T_BASE_PROPS.nextval into my_id_sched from dual;
            v_id_sched := my_id_sched;
            IF (is_public = 0) THEN
              /* insert rate schedule create audit */
              getcurrentid('id_audit', l_id_audit);
              InsertAuditEvent(
                v_id_csr,
                1400,
                2,
                my_id_sched,
                getutcdate(),
                l_id_audit,
                'MASS RATE: Adding schedule for pt: ' || my_id_pt || ' Rate Schedule Id: ' || my_id_sched,
                v_id_csr,
                NULL
              );
            END IF;
            insert into t_base_props ( id_prop, n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name
            ) values( my_id_sched, 130, 0, 0, NULL, NULL, 'N', 'N', 0, NULL);
            select SEQ_T_BASE_PROPS.nextval into my_id_eff_date from dual;
            insert into t_base_props ( id_prop, n_kind, n_name, n_desc, nm_name, nm_desc, b_approved, b_archive, n_display_name, nm_display_name
            ) values( my_id_eff_date, 160, 0, 0, NULL, NULL, 'N', 'N', 0, NULL);

            insert into t_effectivedate (id_eff_date, n_begintype, dt_start, n_beginoffset, n_endtype, dt_end, n_endoffset)
            values(my_id_eff_date, my_start_type, my_start_dt, my_begin_offset, my_end_type, my_end_dt, my_end_offset);
            IF (is_public = 1) THEN
                insert into t_rsched_pub (id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
                values(my_id_sched,my_id_pt, my_id_eff_date, my_id_pricelist, getutcdate(), my_id_pi_template);
            ELSE
                insert into t_rsched (id_sched, id_pt, id_eff_date, id_pricelist, dt_mod, id_pi_template)
                values(my_id_sched,my_id_pt, my_id_eff_date, my_id_pricelist, getutcdate(), my_id_pi_template);
            END IF;
            select count(*) into has_tpl_map from t_pl_map where id_sub = my_id_sub and id_paramtable = my_id_pt AND id_pricelist = my_id_pricelist AND id_pi_template = my_id_pi_template;
            IF (has_tpl_map = 0) THEN
              insert into t_pl_map (dt_modified, id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                        id_pi_instance_parent, id_sub, id_acc, id_po, id_pricelist, b_canicb)
                  select getutcdate(), a.id_paramtable, id_pi_type, id_pi_template, id_pi_instance,
                      id_pi_instance_parent, my_id_sub, NULL, a.id_po, my_id_pricelist, 'N'
                   from t_pl_map a, t_sub b
                   where b.id_sub = my_id_sub
                   and b.id_po = a.id_po
                   and nvl2(a.id_sub,NULL,0) = 0
                   and nvl2(a.id_acc,NULL,0) = 0
                   and a.id_pi_template = my_id_pi_template
                   and a.id_paramtable is not null;
            END IF;
        ELSE
            IF (is_public = 1) THEN
                select id_eff_date into my_id_eff_date from t_rsched_pub where id_sched = my_id_sched;
            ELSE
                select id_eff_date into my_id_eff_date from t_rsched where id_sched = my_id_sched;
            END IF;
            IF (is_public = 0) THEN
              /* insert rate schedule rules audit */
              getcurrentid('id_audit', l_id_audit);
              InsertAuditEvent(
                v_id_csr,
                1402,
                2,
                my_id_sched,
                getutcdate(),
                l_id_audit,
                'MASS RATE: Changing schedule for pt: ' || my_id_pt || ' Rate Schedule Id: ' || my_id_sched,
                v_id_csr,
                NULL
              );
              /* support nulls for private scheds */
              IF (v_start_dt IS NULL AND (v_start_type IS NULL OR v_start_type = 4 OR v_start_type = 1)) THEN
                my_start_dt := NULL;
                my_start_type := 4;
              END IF;
              IF (v_end_dt IS NULL AND (v_end_type IS NULL OR v_end_type = 4 OR v_end_type = 1)) THEN
                my_end_dt := NULL;
                my_end_type := 4;
              END IF;
              update t_effectivedate set n_begintype = my_start_type, dt_start = my_start_dt, n_beginoffset = my_begin_offset, n_endtype = my_end_type,
                  dt_end = my_end_dt, n_endoffset = my_end_offset
                  where id_eff_date = my_id_eff_date and (n_begintype != my_start_type or dt_start != my_start_dt or n_beginoffset != my_begin_offset
                                          or n_endtype != my_end_type or dt_end != my_end_dt or n_endoffset != my_end_offset);
            ELSE
              /* do NOT support nulls for public scheds */
              update t_effectivedate set n_begintype = my_start_type, dt_start = my_start_dt, n_beginoffset = my_begin_offset, n_endtype = my_end_type,
                  dt_end = my_end_dt, n_endoffset = my_end_offset
                  where id_eff_date = my_id_eff_date and (n_begintype != my_start_type or dt_start != my_start_dt or n_beginoffset != my_begin_offset
                                          or n_endtype != my_end_type or dt_end != my_end_dt or n_endoffset != my_end_offset);
            END IF;
        END IF;

    END templt_persist_rsched;

    PROCEDURE mt_load_schedule_params_array(
        v_id_sched IN NUMBER,
        v_is_wildcard IN NUMBER,
        v_pt IN TP_PARAM_TABLE_DEF,
        v_filter_vals_array IN TP_PARAM_ASSOC_ARRAY,
        v_rates IN OUT TP_PARAM_ARRAY
    )
    IS
      l_sql        VARCHAR2 (2048);
      l_sql_or     VARCHAR2 (2048);
      l_sql_and    VARCHAR2 (2048);
      l_cursor     SYS_REFCURSOR;
      l_first      NUMBER := 1;
      l_value      NVARCHAR2 (100);
      l_row        NUMBER;
      l_id_param   NUMBER;
      l_id_sched   NUMBER;
      l_id_audit   NUMBER;
      l_n_order    NUMBER;
      l_start      DATE;
      l_end        DATE;
      l_current    NUMBER := NULL;
      l_id         NUMBER := NULL;
      l_pd         TP_PARAM_DEF;
      l_param_defs TP_PARAM_DEF_ARRAY := v_pt.param_defs;
      l_filter_vals TP_PARAM_ASSOC;
      l_filter_i    NUMBER;
    BEGIN
      l_sql := 'SELECT /*+ INDEX(A END_'|| SUBSTR(v_pt.nm_pt, 0, 19) ||'_IDX) */ id_sched, id_audit, n_order, tt_start, tt_end, id_param_table_prop p_id, DECODE (id_param_table_prop';
      l_row := l_param_defs.first ();
      WHILE (l_row IS NOT NULL)
      LOOP
        l_sql := l_sql || ', ' || l_param_defs (l_row).id_param_table_prop || ', ' || l_param_defs (l_row).nm_column_name;
        l_row := l_param_defs.next (l_row);
      END LOOP;
      l_sql := l_sql || ') p_val FROM ' || v_pt.nm_pt || ' A, T_PARAM_TABLE_PROP B WHERE id_sched = :v_id_sched AND tt_end = :l_max_date AND id_param_table = :id_pt';
      IF (v_filter_vals_array IS NOT NULL AND v_filter_vals_array.COUNT > 0) THEN
        l_filter_i := v_filter_vals_array.first ();
        WHILE (l_filter_i IS NOT NULL)
        LOOP
          l_sql_or := '';
          /* add in filtering */
          l_filter_vals := v_filter_vals_array (l_filter_i);
          IF (l_filter_vals IS NOT NULL AND l_filter_vals.COUNT > 0) THEN
            l_id_param := l_param_defs.first ();
            WHILE (l_id_param IS NOT NULL)
            LOOP
              l_pd := l_param_defs (l_id_param);
              IF (l_pd.is_rate_key <> 0) THEN
                l_value := NULL;
                IF (l_filter_vals.exists (l_pd.id_param_table_prop)) THEN
                  l_value := l_filter_vals (l_pd.id_param_table_prop);
                END IF;
                IF (l_value IS NULL) THEN
                  IF (v_is_wildcard = 0) THEN
                    l_sql_or := l_sql_or || ' AND ' || l_pd.nm_column_name || ' IS NULL';
                  END IF;
                ELSE
                  l_sql_or := l_sql_or || ' AND ' || l_pd.nm_column_name || ' = ''' || l_value || '''';
                END IF;
              END IF;
              l_id_param := l_param_defs.next (l_id_param);
            END LOOP;
          END IF;
          IF (LENGTH(l_sql_or) > 0) THEN
            IF (length(l_sql_and) > 0) THEN
              l_sql_and := l_sql_and || ' OR (' || SUBSTR(l_sql_or,6) || ')';
            ELSE
              l_sql_and := '(' || SUBSTR(l_sql_or,6) || ')';
            END IF;
          END IF;
          l_filter_i := v_filter_vals_array.next (l_filter_i);
        END LOOP;
      END IF;
      IF (LENGTH(l_sql_and) > 0) THEN
        l_sql := l_sql || ' AND (' || l_sql_and || ') ORDER BY n_order ASC';
      ELSE
        l_sql := l_sql || ' ORDER BY n_order ASC';
      END IF;
      OPEN l_cursor FOR l_sql USING v_id_sched, mtmaxdate (), v_pt.id_pt;
      LOOP
        FETCH l_cursor INTO l_id_sched, l_id_audit, l_n_order, l_start, l_end, l_id_param, l_value;
        EXIT WHEN l_cursor%NOTFOUND;
        IF (l_id_param IS NOT NULL) THEN
          DECLARE
            l_params TP_PARAM_ROW;
          BEGIN
            IF (l_current IS NULL OR l_current <> l_n_order) THEN
              l_current := l_n_order;
              l_id := v_rates.COUNT;
              l_params.id_sched := l_id_sched;
              l_params.id_audit := l_id_audit;
              l_params.n_order := l_n_order;
              l_params.updated := 0;
            ELSE
              l_params := v_rates (l_id);
            END IF;
            IF (l_value IS NOT NULL) THEN
              l_params.params(l_id_param) := l_value;
            END IF;
            v_rates (l_id) := l_params;
          END;
        END IF;
      END LOOP;
      CLOSE l_cursor;
    END mt_load_schedule_params_array;
    
    /* replaces NULLs in ICB schedules with real values from hierarchy rows... */
    PROCEDURE mt_replace_nulls(
        v_param_defs IN TP_PARAM_DEF_ARRAY,
        v_rates_low IN TP_PARAM_ARRAY,
        v_rates_high IN TP_PARAM_ARRAY,
        v_rates_out OUT TP_PARAM_ARRAY
    )
    IS
      l_src_i  NUMBER;
      l_tgt_i  NUMBER;
      l_prm_i  NUMBER;
      l_src_v  NVARCHAR2 (100);
      l_tgt_v  NVARCHAR2 (100);
      l_src    TP_PARAM_ROW;
      l_tgt    TP_PARAM_ROW;
      l_pd     TP_PARAM_DEF;
      l_p_cnt  NUMBER;
      l_v_cnt  NUMBER;
      l_isnull NUMBER := 1;
    BEGIN
      l_src_i := v_rates_high.first ();
      WHILE (l_src_i IS NOT NULL)
      LOOP
        l_src := v_rates_high (l_src_i);
        l_isnull := 0;
        l_prm_i := v_param_defs.first ();
        WHILE (l_prm_i IS NOT NULL) /* see if we have any nulls first */
        LOOP
          l_pd := v_param_defs (l_prm_i);
          l_src_v := NULL;
          IF (l_src.params.exists (l_pd.id_param_table_prop)) THEN
            l_src_v := l_src.params (l_pd.id_param_table_prop);
          END IF;
          IF (l_pd.is_rate_key = 0) THEN
            IF (l_src_v IS NULL) THEN
              l_isnull := l_isnull + 1;
            END IF;
          END IF;
          l_prm_i := v_param_defs.next (l_prm_i);
        END LOOP;
        IF (l_isnull <> 0) THEN
          l_tgt_i := v_rates_low.first ();
          WHILE (l_isnull <> 0 AND l_tgt_i IS NOT NULL)
          LOOP
            l_tgt := v_rates_low (l_tgt_i);
            l_prm_i := v_param_defs.first ();
            l_p_cnt := 0;
            l_v_cnt := 0;
            WHILE (l_prm_i IS NOT NULL)  /* see if our keys match (always wildcard) */
            LOOP
              l_pd := v_param_defs (l_prm_i);
              l_src_v := NULL;
              l_tgt_v := NULL;
              IF (l_src.params.exists (l_pd.id_param_table_prop)) THEN
                l_src_v := l_src.params (l_pd.id_param_table_prop);
              END IF;
              IF (l_tgt.params.exists (l_pd.id_param_table_prop)) THEN
                l_tgt_v := l_tgt.params (l_pd.id_param_table_prop);
              END IF;
              IF (l_pd.is_rate_key <> 0) THEN
                l_p_cnt := l_p_cnt + 1;
                IF (l_src_v IS NULL) THEN
                  l_v_cnt := l_v_cnt + 1;
                ELSE
                  IF (l_tgt_v IS NOT NULL AND l_src_v = l_tgt_v) THEN
                    l_v_cnt := l_v_cnt + 1;
                  END IF;
                END IF;
              END IF;
              l_prm_i := v_param_defs.next (l_prm_i);
            END LOOP;
            IF (l_p_cnt = l_v_cnt AND l_isnull <> 0) THEN
              l_tgt.updated := 1;
              /* replace nulls */
              l_prm_i := v_param_defs.first ();
              WHILE (l_isnull <> 0 AND l_prm_i IS NOT NULL)
              LOOP
                l_pd := v_param_defs (l_prm_i);
                IF (l_pd.is_rate_key = 0) THEN
                  l_src_v := NULL;
                  l_tgt_v := NULL;
                  IF (l_src.params.exists (l_pd.id_param_table_prop)) THEN
                    l_src_v := l_src.params (l_pd.id_param_table_prop);
                  END IF;
                  IF (l_tgt.params.exists (l_pd.id_param_table_prop)) THEN
                    l_tgt_v := l_tgt.params (l_pd.id_param_table_prop);
                  END IF;
                  IF (l_src_v IS NULL AND l_tgt_v IS NOT NULL) THEN
                    l_src.params (l_pd.id_param_table_prop) := l_tgt_v;
                    l_isnull := l_isnull - 1;
                  END IF;
                END IF;
                l_prm_i := v_param_defs.next (l_prm_i);
              END LOOP;
            END IF;
            l_tgt_i := v_rates_low.next (l_tgt_i);
          END LOOP;
        END IF;
        v_rates_out(v_rates_out.COUNT) := l_src;
        l_src_i := v_rates_high.next (l_src_i);
      END LOOP;
    END mt_replace_nulls;
    
    /* merges low priority rates into high priority rates */
    PROCEDURE mt_merge_rates(
        v_update IN NUMBER,
        v_param_defs IN TP_PARAM_DEF_ARRAY,
        v_rates_low IN TP_PARAM_ARRAY,
        v_rates_high IN TP_PARAM_ARRAY,
        v_rates_out OUT TP_PARAM_ARRAY
    )
    IS
      l_src_i NUMBER;
      l_tgt_i NUMBER;
      l_prm_i NUMBER;
      l_src_v NVARCHAR2 (100);
      l_tgt_v NVARCHAR2 (100);
      l_src   TP_PARAM_ROW;
      l_tgt   TP_PARAM_ROW;
      l_found NUMBER;
      l_pd    TP_PARAM_DEF;
      l_p_cnt NUMBER;
      l_v_cnt NUMBER;
      l_exact NUMBER;
    BEGIN
      v_rates_out := v_rates_high;
      l_src_i := v_rates_low.first ();
      WHILE (l_src_i IS NOT NULL)
      LOOP
        l_src := v_rates_low (l_src_i);
        l_found := 0;
        l_exact := 1;
        l_tgt_i := v_rates_high.first ();
        WHILE (l_found = 0 AND l_tgt_i IS NOT NULL)
        LOOP
          l_tgt := v_rates_high (l_tgt_i);
          l_prm_i := v_param_defs.first ();
          l_p_cnt := 0;
          l_v_cnt := 0;
          WHILE (l_prm_i IS NOT NULL)
          LOOP
            l_pd := v_param_defs (l_prm_i);
            IF (l_pd.is_rate_key <> 0) THEN
              l_p_cnt := l_p_cnt + 1;
              l_src_v := NULL;
              l_tgt_v := NULL;
              IF (l_src.params.exists (l_pd.id_param_table_prop)) THEN
                l_src_v := l_src.params (l_pd.id_param_table_prop);
              END IF;
              IF (l_tgt.params.exists (l_pd.id_param_table_prop)) THEN
                l_tgt_v := l_tgt.params (l_pd.id_param_table_prop);
              END IF;
              IF (l_tgt_v IS NULL) THEN
                l_v_cnt := l_v_cnt + 1;
                IF (l_src_v IS NOT NULL) THEN
                  l_exact := 0;
                END IF;
              ELSE
                IF (l_src_v IS NOT NULL AND l_src_v = l_tgt_v) THEN
                  l_v_cnt := l_v_cnt + 1;
                ELSE
                  l_exact := 0;
                END IF;
              END IF;
            END IF;
            l_prm_i := v_param_defs.next (l_prm_i);
          END LOOP;
          IF (l_p_cnt = l_v_cnt) THEN
            l_found := 1;
            IF (v_update <> 0 AND l_exact = 1) THEN
              /* found an exact non-wildcard match, we update those */
              l_prm_i := v_param_defs.first ();
              WHILE (l_prm_i IS NOT NULL)
              LOOP
                l_pd := v_param_defs (l_prm_i);
                IF (l_pd.is_rate_key = 0) THEN
                  l_src_v := NULL;
                  IF (l_src.params.exists (l_pd.id_param_table_prop)) THEN
                    l_src_v := l_src.params (l_pd.id_param_table_prop);
                  END IF;
                  IF (l_src_v IS NOT NULL) THEN
                    IF (UPPER(l_src_v) = 'NULL') THEN
                      l_tgt.params.DELETE (l_pd.id_param_table_prop);
                    ELSE
                      l_tgt.params (l_pd.id_param_table_prop) := l_src_v;
                    END IF;
                  END IF;
                END IF;
                l_prm_i := v_param_defs.next (l_prm_i);
              END LOOP;
              v_rates_out (l_tgt_i) := l_tgt;
            END IF;
          END IF;
          l_tgt_i := v_rates_high.next (l_tgt_i);
        END LOOP;
        IF (l_found = 0) THEN
          l_src.updated := 1;
          l_src.id_sched := NULL;
          l_src.id_audit := NULL;
          v_rates_out (v_rates_out.COUNT) := l_src;
        END IF;
        l_src_i := v_rates_low.next (l_src_i);
      END LOOP;
    END mt_merge_rates;
END mt_rate_pkg;
/
