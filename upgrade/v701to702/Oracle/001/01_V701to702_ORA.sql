DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT (NVL(MAX(upgrade_id), 0) + 1)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;

    INSERT INTO t_sys_upgrade
      (
        upgrade_id,
        target_db_version,
        dt_start_db_upgrade,
        db_upgrade_status
      )
    VALUES
      (
        last_upgrade_id,
        '7.0.2',
        SYSDATE(),
        'R'
      );
END;
/

CREATE TABLE mvm_scheduled_tasks (
  mvm_logical_cluster VARCHAR2(100 BYTE) NOT NULL,
  mvm_scheduled_dt DATE DEFAULT sysdate NOT NULL,
  mvm_status VARCHAR2(9 BYTE) DEFAULT 'scheduled' NOT NULL,
  mvm_status_dt DATE DEFAULT sysdate NOT NULL,
  mvm_proc VARCHAR2(100 BYTE) NOT NULL,
  mvm_task_guid VARCHAR2(100 BYTE) DEFAULT sys_guid() NOT NULL,
  mvm_poll_guid VARCHAR2(100 BYTE) DEFAULT '0' NOT NULL,
  mvm_scheduler_physical_node_id VARCHAR2(100 BYTE),
  mvm_delta_object VARCHAR2(4000 BYTE),
  workproc VARCHAR2(1000 BYTE),
  id_acc NUMBER,
  target_id_acc NUMBER,
  decision_unique_id VARCHAR2(1000 BYTE),
  target_decision_unique_id VARCHAR2(1000 BYTE),
  id_usage_interval NUMBER,
  rollover_dt DATE,
  precalculated_units NUMBER,
  CONSTRAINT pk_mvm_scheduled_tasks PRIMARY KEY (mvm_logical_cluster,mvm_status,mvm_scheduled_dt,mvm_poll_guid,mvm_task_guid)
);

ALTER TABLE t_av_internal ADD (c_usestdimpliedtaxalg CHAR);

COMMENT ON COLUMN t_av_internal.c_usestdimpliedtaxalg IS 'Tells the calculate tax adapters which algorithm to use when calculating the tax amount for tax inclusive amounts. If set to True, then the standard implied tax algorithm is tax=amount - amount/(1.0+rate). If set to False, the alternate implied tax algorithm is tax=amount*rate.';

CREATE TABLE t_be_cor_qu_udrcforquoting (
  c_udrcforquoting_id RAW(16) NOT NULL,
  c__version NUMBER(10) NOT NULL,
  c_internal_key RAW(16) NOT NULL,
  c_creationdate TIMESTAMP(4),
  c_updatedate TIMESTAMP(4),
  c_uid NUMBER(10),
  c_pi_id NUMBER(10),
  c_pi_name NVARCHAR2(255),
  c_startdate TIMESTAMP(4),
  c_enddate TIMESTAMP(4),
  c_value NUMBER(22,10),
  c_poforquote_id RAW(16),
  PRIMARY KEY (c_udrcforquoting_id),
  UNIQUE (c_internal_key),
  CONSTRAINT fkd99b29231956655e FOREIGN KEY (c_poforquote_id) REFERENCES t_be_cor_qu_poforquote (c_poforquote_id)
);

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c__version IS 'Version of Business Model Entity';

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c_creationdate IS 'Date of creation Business Model Entity';

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c_updatedate IS 'Date of update Business Model Entity';

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c_uid IS 'User Id';

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c_pi_id IS 'Priceable item identity';

COMMENT ON COLUMN t_be_cor_qu_udrcforquoting.c_pi_name IS 'Priceable item name';

ALTER TABLE t_acc_template_session ADD (n_templates NUMBER(10) DEFAULT 0 NOT NULL,n_templates_applied NUMBER(10) DEFAULT 0 NOT NULL);


/* Upgrading tmp_tmp_t_acc_usage */
UPDATE tmp_tmp_t_acc_usage
SET    tax_inclusive = 'N'
WHERE  tax_inclusive IS NULL;

UPDATE tmp_tmp_t_acc_usage
SET    tax_informational = 'N'
WHERE  tax_informational IS NULL;

ALTER TABLE
   tmp_tmp_t_acc_usage
ADD(
       is_implied_tax CHAR NOT NULL,
       tax_calculated_temp CHAR NOT NULL,
       tax_informational_temp CHAR NOT NULL
   );

UPDATE tmp_tmp_t_acc_usage
SET    is_implied_tax = tax_inclusive,
       tax_calculated_temp = tax_calculated,
       tax_informational_temp = tax_informational;
       
ALTER TABLE tmp_tmp_t_acc_usage DROP (tax_inclusive, tax_calculated, tax_informational);

ALTER TABLE tmp_tmp_t_acc_usage RENAME COLUMN tax_calculated_temp TO tax_calculated;

ALTER TABLE tmp_tmp_t_acc_usage RENAME COLUMN tax_informational_temp TO tax_informational;


/* Upgrading t_acc_usage */
UPDATE t_acc_usage
SET    tax_inclusive = 'N'
WHERE  tax_inclusive IS NULL;

UPDATE t_acc_usage
SET    tax_informational = 'N'
WHERE  tax_informational IS NULL;

ALTER TABLE
   t_acc_usage
ADD(
       is_implied_tax CHAR NOT NULL,
       tax_calculated_temp CHAR NOT NULL,
       tax_informational_temp CHAR NOT NULL
   );

UPDATE t_acc_usage
SET    is_implied_tax = tax_inclusive,
       tax_calculated_temp = tax_calculated,
       tax_informational_temp = tax_informational;
       
ALTER TABLE t_acc_usage DROP (tax_inclusive, tax_calculated, tax_informational);

ALTER TABLE t_acc_usage RENAME COLUMN tax_calculated_temp TO tax_calculated;

ALTER TABLE t_acc_usage RENAME COLUMN tax_informational_temp TO tax_informational;


CREATE TABLE t_rsched_pub (
  id_sched NUMBER(10) NOT NULL,
  id_pt NUMBER(10) NOT NULL,
  id_eff_date NUMBER(10) NOT NULL,
  id_pricelist NUMBER(10) NOT NULL,
  dt_mod DATE,
  id_pi_template NUMBER(10) NOT NULL,
  CONSTRAINT t_rsched_pub_pk PRIMARY KEY (id_sched),
  CONSTRAINT fk1_t_rsched_pub FOREIGN KEY (id_sched) REFERENCES t_base_props (id_prop) ON DELETE SET NULL,
  CONSTRAINT fk2_t_rsched_pub FOREIGN KEY (id_eff_date) REFERENCES t_effectivedate (id_eff_date) ON DELETE SET NULL,
  CONSTRAINT fk4_t_rsched_pub FOREIGN KEY (id_pricelist) REFERENCES t_pricelist (id_pricelist) ON DELETE SET NULL,
  CONSTRAINT fk5_t_rsched_pub FOREIGN KEY (id_pt) REFERENCES t_rulesetdefinition (id_paramtable) ON DELETE SET NULL
);

CREATE GLOBAL TEMPORARY TABLE tmp_rc_accounts_for_run (
  id_acc NUMBER(10)
)
ON COMMIT PRESERVE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_sub (
  id_sub NUMBER(10),
  id_sub_ext RAW(16),
  id_acc NUMBER(10),
  id_group NUMBER(10),
  id_po NUMBER(10) NOT NULL,
  dt_crt DATE,
  vt_start DATE,
  vt_end DATE
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE t_acc_template_valid_subs (
  id_acc_template_session NUMBER(10) NOT NULL,
  id_po NUMBER(10),
  id_group NUMBER(10),
  sub_start DATE,
  sub_end DATE,
  po_start DATE,
  po_end DATE
)
ON COMMIT DELETE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_nrc_accounts_for_run (
  id_acc NUMBER(10)
)
ON COMMIT PRESERVE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_nrc (
  c_nrceventtype NVARCHAR2(255),
  c_nrcintervalstart DATE NOT NULL,
  c_nrcintervalend DATE NOT NULL,
  c_nrcintervalsubscriptionstart DATE NOT NULL,
  c_nrcintervalsubscriptionend DATE NOT NULL,
  c__accountid NUMBER(10) NOT NULL,
  c__resubmit NUMBER(10) NOT NULL,
  c__priceableiteminstanceid NUMBER(10) NOT NULL,
  c__priceableitemtemplateid NUMBER(10) NOT NULL,
  c__productofferingid NUMBER(10) NOT NULL,
  c__collectionid BLOB,
  c__subscriptionid NUMBER(10) NOT NULL,
  c__intervalid NUMBER(10),
  id_source_sess RAW(16)
)
ON COMMIT PRESERVE ROWS;

CREATE GLOBAL TEMPORARY TABLE tmp_gsubmember (
  id_group NUMBER(10),
  id_acc NUMBER(10),
  vt_start DATE,
  vt_end DATE
)
ON COMMIT DELETE ROWS;

CREATE INDEX acc_template_valid_subs_idx1 ON t_acc_template_valid_subs(id_acc_template_session,id_po);

CREATE INDEX acc_template_valid_subs_idx2 ON t_acc_template_valid_subs(id_acc_template_session,id_group);

CREATE INDEX fk2idx_t_rsched_pub ON t_rsched_pub(id_eff_date);

CREATE INDEX fk3idx_t_rsched_pub ON t_rsched_pub(id_pi_template);

CREATE INDEX fk4idx_t_rsched_pub ON t_rsched_pub(id_pricelist);

CREATE INDEX fk5idx_t_rsched_pub ON t_rsched_pub(id_pt);


CREATE function determine_absolute_dates(v_date DATE, my_date_type NUMBER, my_date_offset NUMBER, my_id_acc NUMBER, is_start NUMBER) return DATE
as
my_date DATE;
my_acc_start DATE;
curr_id_cycle_type NUMBER;
curr_day_of_month NUMBER;
my_cycle_cutoff DATE;
begin
    my_date := v_date;
    IF (my_date_type = 1 AND my_date IS NOT NULL) THEN
        return my_date;
    END IF;
    IF (my_date_type = 4 or (my_date_type = 1 and my_date IS NULL)) THEN
        IF (is_start = 1) THEN
            IF (my_id_acc IS NOT NULL AND my_id_acc > 0) THEN
                select dt_crt into my_date from t_account where id_acc = my_id_acc;
            ELSE
                select mtmindate() into my_date from dual;
            END IF;
        ELSE
            select mtmaxdate() into my_date from dual;
        END IF;
        return my_date;
    END IF;
    IF (my_date_type = 3) THEN
        select dt_crt into my_acc_start from t_account where id_acc = my_id_acc;
        IF (my_acc_start > my_date or my_date IS NULL) THEN
            my_date := my_acc_start;
        END IF;
        select id_cycle_type, day_of_month into curr_id_cycle_type, curr_day_of_month
            from t_acc_usage_cycle a, t_usage_cycle b
            where a.id_usage_cycle = b.id_usage_cycle and a.id_acc = my_id_acc;
        IF (curr_id_cycle_type = 1) THEN
            select trunc(my_date,'MM') + decode(curr_day_of_month,31,0,curr_day_of_month) into my_cycle_cutoff from dual;
            IF (my_date > my_cycle_cutoff) THEN
                select add_months(my_date, 1) into my_cycle_cutoff from dual;
            END IF;
            my_date := my_cycle_cutoff;
            select my_date + my_date_offset into my_date from dual;
        END IF;
        return my_date;
    END IF;
    return my_date;
end determine_absolute_dates;
/


/* BEGIN of "mt_acc_template" and "mt_rate_pkg" Packages declaration and definition*/

CREATE PACKAGE mt_acc_template
AS
    PROCEDURE apply_subscriptions (
       template_id                INT,
       sub_start                  DATE,
       sub_end                    DATE,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       id_event_failure           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    );
    
    PROCEDURE apply_subscriptions_to_acc (
       id_acc                     INT,
       id_acc_template            INT,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT
    );

    PROCEDURE UpdateAccPropsFromTemplate (
        idAccountTemplate INT,
        systemDate DATE
    );

    PROCEDURE UpdateUsageCycleFromTemplate (
        IdAcc INT
        ,UsageCycleId INT
        ,OldUsageCycle INT
        ,systemDate DATE
    );

    PROCEDURE UpdatePayerFromTemplate (
        IdAcc INT
        ,PayerId INT
        ,systemDate DATE
        ,p_account_currency VARCHAR2
        ,sessionId INT
        ,DetailTypeSubscription INT
        ,DetailResultInformation INT
        ,nRetryCount INT
    );

END mt_acc_template;
/

CREATE PACKAGE mt_rate_pkg
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
/

CREATE OR REPLACE 
PACKAGE BODY mt_acc_template
AS
    detailtypesubs      INT;
    detailresultfailure INT;
       
    PROCEDURE subscribe_account(
       id_acc              INT,
       id_po               INT,
       id_group            INT,
       sub_start           DATE,
       sub_end             DATE,
       systemdate          DATE
    )
    AS
        v_guid                RAW(16);
        curr_id_sub           INT;
    BEGIN
    
        IF (id_po IS NULL) THEN
            INSERT INTO tmp_gsubmember (id_group, id_acc, vt_start, vt_end)
                VALUES (id_group, id_acc, sub_start, sub_end);
        ELSE
            getcurrentid('id_subscription', curr_id_sub);
            SELECT SYS_GUID() INTO v_guid FROM dual;
            INSERT INTO tmp_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
                VALUES (curr_id_sub, v_guid, id_acc, NULL, id_po, systemdate, sub_start, sub_end);
        END IF;

    END;
    
    PROCEDURE apply_subscriptions (
       template_id                INT,
       sub_start                  DATE,
       sub_end                    DATE,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       id_event_failure           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT,
       doCommit                   CHAR DEFAULT 'Y'
    )
    AS
       my_id_audit           INT;
       my_error              VARCHAR2(1024);
       my_id_acc             INT;
       maxdate               DATE;
       audit_msg             VARCHAR2(256);
    BEGIN
        IF (my_id_audit IS NULL)
        THEN
           IF (apply_subscriptions.id_audit IS NOT NULL)
           THEN
              my_id_audit := apply_subscriptions.id_audit;
           ELSE
              getcurrentid ('id_audit', my_id_audit);

              INSERT INTO t_audit (
                    id_audit,
                    id_event,
                    id_userid,
                    id_entitytype,
                    id_entity,
                    dt_crt
                 )
              VALUES (
                    my_id_audit,
                    apply_subscriptions.id_event_failure,
                    apply_subscriptions.user_id,
                    1,
                    my_id_acc,
                    getutcdate ()
                 );
           END IF;
        END IF;

        IF detailtypesubs IS NULL THEN
            SELECT id_enum_data
            INTO   detailtypesubs
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';
             
            SELECT id_enum_data
            INTO   detailresultfailure
            FROM   t_enum_data
            WHERE  nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure';
         END IF;
      
      DELETE FROM t_acc_template_valid_subs WHERE id_acc_template_session = apply_subscriptions.id_template_session;
      
      /* Detect conflicting subscriptions in the template and choice first available of them and without conflicts */
      INSERT INTO t_acc_template_valid_subs (id_acc_template_session, id_po, id_group, sub_start, sub_end, po_start, po_end)
      SELECT DISTINCT
           apply_subscriptions.id_template_session,
           subs.id_po,
           subs.id_group,
           GREATEST(apply_subscriptions.sub_start, subs.sub_start),
           LEAST(apply_subscriptions.sub_end, subs.sub_end),
           subs.sub_start,
           subs.sub_end
      FROM
        (
            SELECT MAX(ts.id_po) AS id_po, NULL AS id_group, MAX(ed.dt_start) AS sub_start, NVL(MAX(ed.dt_end), mtmaxdate()) AS sub_end
            FROM   t_acc_template_subs ts
                   JOIN t_pl_map pm ON pm.id_po = ts.id_po
                   JOIN t_po po ON ts.id_po = po.id_po
                   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
            WHERE  ts.id_acc_template = apply_subscriptions.template_id
            GROUP BY pm.id_pi_template
            UNION ALL
            SELECT NULL AS id_po, MAX(ts.id_group) AS id_group, MAX(ed.dt_start) AS sub_start, NVL(MAX(ed.dt_end), mtmaxdate()) AS sub_end
            FROM   t_acc_template_subs ts
                   JOIN t_sub s ON s.id_group = ts.id_group
                   JOIN t_pl_map pm ON pm.id_po = s.id_po
                   JOIN t_po po ON po.id_po = s.id_po
                   JOIN t_effectivedate ed ON po.id_eff_date = ed.id_eff_date
            WHERE  ts.id_acc_template = apply_subscriptions.template_id
            GROUP BY pm.id_pi_template
        ) subs;

       /* Applying subscriptions to accounts */
      FOR rec IN (
         SELECT id_descendent AS id_acc
         FROM   t_vw_get_accounts_by_tmpl_id v
         WHERE  v.id_template = apply_subscriptions.template_id)
      LOOP
           my_id_acc := rec.id_acc;
           apply_subscriptions_to_acc (
               id_acc                     => rec.id_acc,
               id_acc_template            => apply_subscriptions.template_id,
               next_cycle_after_startdate => apply_subscriptions.next_cycle_after_startdate,
               next_cycle_after_enddate   => apply_subscriptions.next_cycle_after_enddate,
               user_id                    => apply_subscriptions.user_id,
               id_audit                   => my_id_audit,
               id_event_success           => apply_subscriptions.id_event_success,
               systemdate                 => apply_subscriptions.systemdate,
               id_template_session        => apply_subscriptions.id_template_session,
               retrycount                 => apply_subscriptions.retrycount
           );
      END LOOP;
          
      maxdate := mtmaxdate();

      BEGIN
          /* Persist the data in transaction */
          mt_rate_pkg.current_id_audit := apply_subscriptions.id_audit;
          
          INSERT INTO t_gsubmember (id_group, id_acc, vt_start, vt_end)
          SELECT id_group, id_acc, vt_start, vt_end
          FROM   tmp_gsubmember;

          INSERT INTO t_gsubmember_historical (id_group, id_acc, vt_start, vt_end, tt_start, tt_end)
          SELECT id_group, id_acc, vt_start, vt_end, apply_subscriptions.systemdate, maxdate
          FROM   tmp_gsubmember;

          INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end)
          SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end
          FROM   tmp_sub;
          
          INSERT INTO t_sub_history (id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, tt_start, tt_end)
          SELECT id_sub, id_sub_ext, id_acc, id_group, id_po, dt_crt, vt_start, vt_end, apply_subscriptions.systemdate, maxdate
          FROM   tmp_sub;
          
          INSERT INTO t_audit_details (id_auditdetails, id_audit, tx_details)
          SELECT seq_t_audit_details.nextval, tmp.my_id_audit, tmp.tx_details
          FROM   (
                  SELECT my_id_audit AS my_id_audit,
                         'Added subscription to id_groupsub ' || id_group ||
                         ' for account ' || id_acc ||
                         ' from ' || vt_start ||
                         ' to ' || vt_end ||
                         ' on ' || systemdate AS tx_details
                  FROM   tmp_gsubmember
                  UNION ALL
                  SELECT my_id_audit AS my_id_audit,
                         'Added subscription to product offering ' || id_po ||
                         ' for account ' || id_acc ||
                         ' from ' || vt_start ||
                         ' to ' || vt_end ||
                         ' on ' || apply_subscriptions.systemdate AS tx_details
                  FROM   tmp_sub
                 ) tmp;
                    
          IF (doCommit = 'Y')
          THEN
          COMMIT;
          END IF;
          
          mt_rate_pkg.current_id_audit := NULL;
      EXCEPTION
          -- we should log this.
          WHEN OTHERS
          THEN
              IF (doCommit = 'Y')
              THEN
             ROLLBACK;
              END IF;
          
             mt_rate_pkg.current_id_audit := NULL;
             
             my_error := substr(SQLERRM,1,1024);

             IF (my_id_audit IS NULL)
             THEN
                IF (apply_subscriptions.id_audit IS NOT NULL)
                THEN
                   my_id_audit := apply_subscriptions.id_audit;
                ELSE
                   getcurrentid ('id_audit', my_id_audit);

                   INSERT INTO t_audit (
                        id_audit,
                        id_event,
                        id_userid,
                        id_entitytype,
                        id_entity,
                        dt_crt
                      )
                   VALUES (
                        my_id_audit,
                        apply_subscriptions.id_event_failure,
                        apply_subscriptions.user_id,
                        1,
                        my_id_acc,
                        getutcdate ()
                      );
                END IF;
             END IF;

            INSERT INTO t_audit_details (
                id_auditdetails,
                id_audit,
                tx_details
             )
            VALUES (
                seq_t_audit_details.NEXTVAL,
                my_id_audit,
                'Error applying template to id_acc: '
                || my_id_acc
                || ': '
                || my_error
             );
          
        END;
    END;
    
    PROCEDURE apply_subscriptions_to_acc (
       id_acc                     INT,
       id_acc_template            INT,
       next_cycle_after_startdate CHAR, /* Y or N */
       next_cycle_after_enddate   CHAR, /* Y or N */
       user_id                    INT,
       id_audit                   INT,
       id_event_success           INT,
       systemdate                 DATE,
       id_template_session        INT,
       retrycount                 INT
    )
    AS
       v_acc_start       DATE;
       v_vt_start        DATE;
       v_vt_end          DATE;
       v_sub_start       DATE;
       v_sub_end         DATE;
       curr_id_sub       INT;
       my_id_audit       INT;
       my_user_id        INT;
       id_acc_type       INT;

    BEGIN
       my_user_id := apply_subscriptions_to_acc.user_id;

       IF (my_user_id IS NULL)
       THEN
          my_user_id := 1;
       END IF;

       my_id_audit := apply_subscriptions_to_acc.id_audit;

       IF (my_id_audit IS NULL)
       THEN
          getcurrentid ('id_audit', my_id_audit);

          INSERT INTO t_audit
                      (id_audit, id_event, id_userid, id_entitytype, id_entity,
                       dt_crt
                      )
               VALUES (my_id_audit, apply_subscriptions_to_acc.id_event_success, apply_subscriptions_to_acc.user_id, 1, apply_subscriptions_to_acc.id_acc,
                       getutcdate ()
                      );
       END IF;

       SELECT vt_start
       INTO   v_acc_start
       FROM   t_account_state
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;
       
       SELECT id_type
       INTO   id_acc_type
       FROM   t_account
       WHERE  id_acc = apply_subscriptions_to_acc.id_acc;
    
       /* Create new subscriptions */
       FOR sub in (
          SELECT ts.id_po,
                 ts.id_group,
                 CASE
                     WHEN MIN(s.vt_start) IS NULL THEN MIN(gm.vt_start)
                     WHEN MIN(gm.vt_start) IS NULL THEN MIN(s.vt_start)
                     ELSE LEAST(MIN(s.vt_start), MIN(gm.vt_start))
                 END AS vt_start,
                 CASE
                     WHEN MAX(s.vt_end) IS NULL THEN MAX(gm.vt_end)
                     WHEN MAX(gm.vt_end) IS NULL THEN MAX(s.vt_end)
                     ELSE GREATEST(MAX(s.vt_end), MAX(gm.vt_end))
                 END AS vt_end,
                 SUM(CASE WHEN s.id_sub IS NULL THEN 0 ELSE 1 END) + SUM(CASE WHEN gm.id_group IS NULL THEN 0 ELSE 1 END) conflicts,
                 vs.v_sub_start AS my_sub_start,
                 vs.v_sub_end AS my_sub_end
          FROM   t_acc_template_subs ts
                 JOIN (
                       SELECT id_acc_template_session,
                              id_po,
                              id_group,
                               CASE
                                  WHEN apply_subscriptions_to_acc.next_cycle_after_startdate = 'Y'
                                  THEN
                                      (
                                        SELECT GREATEST(tpc.dt_end + numtodsinterval(1, 'second'), tvs.po_start)
                                        FROM   t_pc_interval tpc
                                               INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                                        WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                                           AND tvs.sub_start BETWEEN tpc.dt_start AND tpc.dt_end
                                      )
                                  ELSE tvs.sub_start
                              END AS v_sub_start,
                              CASE
                                  WHEN apply_subscriptions_to_acc.next_cycle_after_enddate = 'Y'
                                  THEN
                                      (
                                        SELECT LEAST(LEAST(tpc.dt_end + numtodsinterval(1, 'second'), mtmaxdate()), tvs.po_end)
                                        FROM   t_pc_interval tpc
                                               INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
                                        WHERE  tauc.id_acc = apply_subscriptions_to_acc.id_acc
                                           AND tvs.sub_end BETWEEN tpc.dt_start AND tpc.dt_end
                                      )
                                  ELSE tvs.sub_end
                              END AS v_sub_end

                       FROM   t_acc_template_valid_subs tvs
                 ) vs  ON    vs.id_acc_template_session = apply_subscriptions_to_acc.id_template_session
                         AND (vs.id_po = ts.id_po OR vs.id_group = ts.id_group)
                 LEFT JOIN t_sub gs ON gs.id_group = ts.id_group
                 LEFT JOIN t_sub s
                  ON     s.id_acc = apply_subscriptions_to_acc.id_acc
                     AND s.vt_start <= vs.v_sub_end
                     AND s.vt_end >= vs.v_sub_start
                     AND EXISTS (SELECT 1
                                 FROM   t_pl_map mpo
                                        JOIN t_pl_map ms ON mpo.id_pi_template = ms.id_pi_template
                                 WHERE  mpo.id_po = NVL(ts.id_po, gs.id_po) AND ms.id_po = s.id_po)
                 LEFT JOIN t_gsubmember gm
                  ON     gm.id_acc = apply_subscriptions_to_acc.id_acc
                     AND gm.vt_start <= vs.v_sub_end
                     AND gm.vt_end >= vs.v_sub_start
                     AND EXISTS (SELECT 1
                                 FROM   t_sub ags
                                        JOIN t_pl_map ms ON ms.id_po = ags.id_po
                                        JOIN t_pl_map mpo ON mpo.id_pi_template = ms.id_pi_template
                                 WHERE  ags.id_group = gm.id_group AND mpo.id_po = NVL(ts.id_po, gs.id_po))
          WHERE  ts.id_acc_template = apply_subscriptions_to_acc.id_acc_template
             /* Check if the PO is available for the account's type */
             AND (  (ts.id_po IS NOT NULL AND
                      (  EXISTS
                         (
                            SELECT 1
                            FROM   t_po_account_type_map atm
                            WHERE  atm.id_po = ts.id_po AND atm.id_account_type = id_acc_type
                         )
                      OR NOT EXISTS
                         (
                             SELECT 1 FROM t_po_account_type_map atm WHERE atm.id_po = ts.id_po
                         )
                     )
                    )
                 OR (ts.id_group IS NOT NULL AND
                      (  EXISTS
                         (
                            SELECT 1
                            FROM   t_po_account_type_map atm
                                   JOIN t_sub tgs ON tgs.id_po = atm.id_po
                            WHERE  tgs.id_group = ts.id_group AND atm.id_account_type = id_acc_type
                         )
                     OR NOT EXISTS
                         (
                            SELECT 1
                            FROM   t_po_account_type_map atm
                                   JOIN t_sub tgs ON tgs.id_po = atm.id_po
                            WHERE  tgs.id_group = ts.id_group
                         )
                      )
                    )
                 )
          GROUP BY ts.id_po, ts.id_group, vs.v_sub_start, vs.v_sub_end
       )
       LOOP
            /* 1.  There is no conflicting subscription */
            IF sub.conflicts = 0 THEN
                v_vt_start := sub.my_sub_start;
                v_vt_end := sub.my_sub_end;
                
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate);
                
            /* 2.  There is a conflicting subscription for the same or greatest interval */
            ELSIF sub.my_sub_start >= sub.vt_start AND sub.my_sub_end <= sub.vt_end THEN
                InsertTmplSessionDetail
                (
                    apply_subscriptions_to_acc.id_template_session,
                    detailtypesubs,
                    detailresultfailure,
                    'Subscription for account ' || apply_subscriptions_to_acc.id_acc || ' not created due to ' || sub.conflicts || 'conflict' || CASE WHEN sub.conflicts > 1 THEN 's' ELSE '' END,
                    apply_subscriptions_to_acc.retrycount,
                    'N'
                );
                
            /* 3.  There is a conflicting subscription for an early period */
            ELSIF sub.my_sub_start >= sub.vt_start AND sub.my_sub_end > sub.vt_end THEN
                v_vt_start := sub.vt_end + 1;
                v_vt_end := sub.my_sub_end;
                
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate);
                
            /* 4.  There is a conflicting subscription for a late period */
            ELSIF sub.my_sub_start < sub.vt_start AND sub.my_sub_end <= sub.vt_end THEN
                v_vt_start := sub.my_sub_start;
                v_vt_end := sub.vt_start - 1;
                
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate);
                
            /* 5.  There is a conflicting subscription for the period inside the indicated one */
            ELSE
                v_vt_start := sub.vt_end + 1;
                v_vt_end := sub.my_sub_end;
                
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate);

                v_vt_start := sub.my_sub_start;
                v_vt_end := sub.vt_start - 1;
                
                subscribe_account(apply_subscriptions_to_acc.id_acc, sub.id_po, sub.id_group, v_vt_start, v_vt_end, apply_subscriptions_to_acc.systemdate);
            END IF;
       END LOOP;
    END;

    PROCEDURE UpdateAccPropsFromTemplate (
      idAccountTemplate INT,
      systemDate DATE
    )
    AS
        vals VARCHAR2(32767);
        dSql VARCHAR2(32767);
        conditionStatement VARCHAR2(32767);
        enumValue varchar2(256);
        val1 varchar2(256);
        val2 varchar2(256);
    BEGIN
        FOR rec in (
            SELECT
                DISTINCT(v.account_view_name) AS viewName,
                't_av_'|| SUBSTR(td.nm_enum_data, INSTR (td.nm_enum_data, '/') + 1, LENGTH(td.nm_enum_data)) AS tableName,
                CASE WHEN INSTR(tp.nm_prop, ']') <> 0
                THEN SUBSTR(tp.nm_prop, INSTR(tp.nm_prop, '[') + 1, INSTR(tp.nm_prop, ']') - INSTR(tp.nm_prop, '[') - 1)
                ELSE NULL
                END AS additionalOptionString
            FROM t_enum_data td JOIN t_account_type_view_map v on v.id_account_view = td.id_enum_data
            JOIN t_account_view_prop p on v.id_type = p.id_account_view
            JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name || '%' and tp.nm_prop like '%' || p.nm_name
            WHERE tp.id_acc_template = idAccountTemplate)
        LOOP
            vals := NULL;
            FOR val in (
                SELECT
                    --"Magic numbers" were took FROM MetraTech.Interop.MTYAAC.PropValType enumeration.
                    CASE WHEN ROWNUM = 1 THEN NULL ELSE ',' END ||
                    nm_column_name || ' ' ||
                        CASE
                            WHEN nm_prop_class in(0, 1, 4, 5, 6, 8, 9, 12, 13)
                            THEN ' = ''' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ''' '
                            WHEN nm_prop_class in(2, 3, 10, 11, 14)
                            THEN ' = ' || REPLACE(TO_CHAR(nm_value), '''', '''''') || ' '
                            WHEN nm_prop_class = 7
                            THEN
                                CASE
                                    WHEN UPPER(nm_value) = 'TRUE'
                                    THEN ' = 1 '
                                    ELSE ' = 0 '
                                END
                            ELSE ''''' '
                        END AS colVal

                FROM t_account_type_view_map v
                JOIN t_account_view_prop p on v.id_type = p.id_account_view
                JOIN t_acc_template_props tp on tp.nm_prop like v.account_view_name || '%' and tp.nm_prop like '%.' || REPLACE(REPLACE(REPLACE(p.nm_name, N'\', N'\\'), N'_', N'\_'), N'%', N'\%') ESCAPE N'\'
                WHERE tp.id_acc_template = idAccountTemplate and tp.nm_prop like rec.viewName || '%')
            LOOP
                vals := vals || val.colVal;
            END LOOP;

            conditionStatement := NULL;
            IF(rec.additionalOptionString IS NOT NULL) THEN
                -- Processing enum values
                FOR item in (SELECT items AS conditionItem FROM TABLE(SplitStringByChar(rec.additionalOptionString,',')))
                LOOP

                    val1 := SUBSTR(item.conditionItem, 0, INSTR(item.conditionItem, '=') - 1);

                    val2 := SUBSTR(item.conditionItem, INSTR(item.conditionItem, '=') + 1, LENGTH(item.conditionItem) - INSTR(item.conditionItem, '=') + 1);
                    val2 := REPLACE(val2, '_', '-');

                    --Select value fot additional condition by namespace and name of enum.
                    SELECT id_enum_data
                      INTO enumValue
                      FROM t_enum_data
                     WHERE UPPER(nm_enum_data) =
                        (SELECT UPPER(nm_space || '/' || nm_enum || '/' || val2)
                        FROM t_account_type_view_map v JOIN t_account_view_prop p on v.id_type = p.id_account_view
                        WHERE UPPER(account_view_name) = UPPER(rec.viewName) AND UPPER(nm_name) = UPPER(val1));

                    --Creation additional condition for update account view properties for each account view.
                    conditionStatement := conditionStatement || 'c_' || val1 || ' = ' || TO_CHAR(enumValue) || ' AND ';
                END LOOP;
            END IF;

            --Completion to creation dynamic sql-string for update account view.
            conditionStatement := conditionStatement || 'id_acc in (SELECT id_descendent FROM t_vw_get_accounts_by_tmpl_id WHERE id_template = ' || TO_CHAR(idAccountTemplate) || '  AND CAST(''' || TO_CHAR(systemDate) || ''' AS DATE) BETWEEN COALESCE(vt_start, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)) AND COALESCE(vt_end, CAST(''' || TO_CHAR(systemDate) || ''' AS DATE)))';
            dSql := 'UPDATE ' || rec.tableName || ' SET ' || vals || ' WHERE ' || conditionStatement;

            EXECUTE IMMEDIATE dSql;
        END LOOP;
    END;

    PROCEDURE UpdateUsageCycleFromTemplate (
        IdAcc INT
        ,UsageCycleId INT
        ,OldUsageCycle INT
        ,systemDate DATE
    )
    AS
        p_status INT;
        intervalenddate DATE;
        intervalID INT;
        pc_start DATE;
        pc_end DATE;
    BEGIN
        IF OldUsageCycle <> UsageCycleId AND UsageCycleId <> -1 THEN
            p_status := dbo.ISBILLINGCYCLEUPDPROHIBITEDBYG(systemDate, IdAcc);
            IF p_status = 1 THEN
                p_status := 0;
                UPDATE t_acc_usage_cycle
                   SET id_usage_cycle = UsageCycleId
                 WHERE id_acc = IdAcc;

                  -- post-operation business rule check (relies on rollback of work done up until this point)
                  -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's
                  -- group subscription BCR constraints
                SELECT NVL(MIN(dbo.CHECKGROUPMEMBERSHIPCYCLECONST(systemDate, "groups".id_group)), 1)
                  INTO p_status
                  FROM (
                        -- gets all of the payer's payee's and/or the payee's group subscriptions
                        SELECT DISTINCT gsm.id_group id_group
                            FROM t_gsubmember gsm
                            INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc
                            WHERE pay.id_payer = IdAcc OR pay.id_payee = IdAcc
                      ) "groups";

                IF p_status = 1 THEN
                    p_status := 0;
                    -- deletes any mappings to intervals in the future from the old cycle
                    DELETE FROM t_acc_usage_interval
                        WHERE t_acc_usage_interval.id_acc = IdAcc
                        AND id_usage_interval IN (
                            SELECT id_interval
                                FROM t_usage_interval ui
                                INNER JOIN t_acc_usage_interval aui ON aui.id_acc = IdAcc AND aui.id_usage_interval = ui.id_interval
                                WHERE dt_start > systemDate
                        );

                    -- only one pending update is allowed at a time
                    -- deletes any previous update mappings which have not yet
                    -- transitioned (dt_effective is still in the future)
                    DELETE FROM t_acc_usage_interval
                        WHERE dt_effective IS NOT NULL
                            AND id_acc = IdAcc
                            AND dt_effective >= systemDate;

                    -- gets the current interval's end date
                    SELECT MAX(ui.dt_end)
                      INTO intervalenddate
                      FROM t_acc_usage_interval aui
                      INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval AND systemDate BETWEEN ui.dt_start AND ui.dt_end
                    WHERE aui.id_acc = IdAcc;

                    -- future dated accounts may not yet be associated with an interval (CR11047)
                    IF intervalenddate IS NOT NULL THEN
                        -- figures out the new interval ID based on the end date of the current interval
                        SELECT id_interval, dt_start, dt_end
                          INTO intervalID, pc_start, pc_end
                          FROM t_pc_interval
                        WHERE id_cycle = UsageCycleId
                          AND addsecond(intervalenddate) BETWEEN dt_start AND dt_end;

                        -- inserts the new usage interval if it doesn't already exist
                        -- (needed for foreign key relationship in t_acc_usage_interval)
                        INSERT INTO t_usage_interval
                            SELECT intervalID
                                    ,UsageCycleId
                                    ,pc_start
                                    ,pc_end
                                    ,'O'
                              FROM DUAL
                             WHERE NOT EXISTS (SELECT 1 FROM t_usage_interval WHERE id_interval = intervalID);

                        -- creates the special t_acc_usage_interval mapping to the interval of
                        -- new cycle. dt_effective is set to the end of the old interval.
                        INSERT INTO t_acc_usage_interval
                            SELECT IdAcc
                                    ,intervalID
                                    ,NVL(tx_interval_status, 'O')
                                    ,intervalenddate
                                FROM t_usage_interval
                                WHERE id_interval = intervalID
                                    AND tx_interval_status <> 'B';
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

    PROCEDURE UpdatePayerFromTemplate (
        IdAcc INT
        ,PayerId INT
        ,systemDate DATE
        ,p_account_currency VARCHAR2
        ,sessionId INT
        ,DetailTypeSubscription INT
        ,DetailResultInformation INT
        ,nRetryCount INT
    )
    AS
        p_status INT;
        oldpayerstart DATE;
        oldpayerend DATE;
        oldpayer INT;
        payerenddate DATE;

        payerbillable VARCHAR2(1);
        accExists INT;
    BEGIN
        SELECT COUNT(1) INTO accExists FROM t_account where id_acc = PayerID;
        IF accExists > 0 THEN
            payerenddate := dbo.MTMaxDate();
            -- find the old payment information
            SELECT MAX(vt_start), MAX(vt_end), MAX(id_payer)
              INTO oldpayerstart, oldpayerend, oldpayer
              FROM t_payment_redirection
             WHERE id_payee = IdAcc
               AND dbo.OverlappingDateRange(vt_start, vt_end, systemDate, dbo.mtmaxdate()) = 1;

            -- if the new record is in range of the old record and the payer is the same as the older payer,
            -- update the record
            IF (PayerID <> -1) THEN
                IF (PayerID = oldpayer) THEN
                    UpdatePaymentRecord (payerID, IdAcc, oldpayerstart, oldpayerend, systemDate, payerenddate, systemDate, 1, p_account_currency, p_status);

                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record changed. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                ELSE
                    payerbillable := dbo.IsAccountBillable(PayerID);
                    CreatePaymentRecord(payerID, IdAcc, systemDate, payerenddate, payerbillable, systemDate, 'N', 1, p_account_currency, p_status);
                    IF (p_status <> 1) THEN
                        InsertTmplSessionDetail
                        (
                            sessionId,
                            DetailTypeSubscription,
                            DetailResultInformation,
                            'No payment record created. Return code is ' || TO_CHAR(p_status),
                            nRetryCount,
                            'N'
                        );
                        p_status := 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END;

END mt_acc_template;
/

CREATE PACKAGE BODY mt_rate_pkg
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
            getcurrentid('id_audit', my_id_audit);
            
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

/* END of "mt_acc_template" and "mt_rate_pkg" Packages declaration and definition*/
create table t_day_of_week (num NUMBER(10) not null,name VARCHAR2(50) not null,constraint pk_t_day_of_week PRIMARY KEY(name));


DELETE FROM T_DAY_OF_WEEK;
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(1,'SUNDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(2,'MONDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(3,'TUESDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(4,'WEDNESDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(5,'THURSDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) VALUES(6,'FRIDAY');
INSERT INTO T_DAY_OF_WEEK(NUM, NAME) SELECT 7 as num, 'SATURDAY' as name FROM dual WHERE (SELECT count(*) from t_day_of_week WHERE name = 'SATURDAY') = 0;

/

CREATE OR REPLACE 
PROCEDURE ApplyTemplateToAccounts(
    idAccountTemplate          INT,
    sessionId                  INT,
    nRetryCount                INT,
    systemDate                 DATE,
    sub_start                  DATE,
    sub_end                    DATE,
    next_cycle_after_startdate CHAR,
    next_cycle_after_enddate   CHAR,
    user_id                    INT,
    id_event_success           INT,
    id_event_failure           INT,
    account_id                 INT DEFAULT NULL,
    doCommit                   CHAR DEFAULT 'Y'
)
AS
    DetailTypeUpdate NUMBER(10);
    DetailResultSuccess NUMBER(10);
    DetailResultFailure NUMBER(10);

    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    tableName varchar2(256);
    additionalOptionString varchar2(256);

    UsageCycleId NUMBER(10);
    PayerId NUMBER(10);

BEGIN
    SELECT id_enum_data
      INTO DetailTypeUpdate
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Update';

    SELECT id_enum_data
      INTO DetailResultFailure
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Failure';

    SELECT id_enum_data
      INTO DetailResultSuccess
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';


    SELECT id_enum_data
      INTO DetailTypeGeneral
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';

    SELECT id_enum_data
      INTO DetailResultInformation
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information';

    SELECT id_enum_data
      INTO DetailTypeSubscription
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';

    BEGIN
        mt_acc_template.UpdateAccPropsFromTemplate (
            idAccountTemplate => idAccountTemplate,
            systemDate        => systemDate
        );
        -- Apply billing cycles and payment redirection settings
        SELECT NVL(MAX(tuc.id_usage_cycle), -1), NVL(MAX(ttp.PayerID), -1)
          INTO UsageCycleId, PayerId
          FROM t_usage_cycle tuc
            RIGHT OUTER JOIN (
                SELECT  tp.DayOfMonth
                        ,tp.StartDay
                        ,tp.StartMonth
                        ,NVL(m.num,-1) as MonthNum
                        ,NVL(dw.num,-1) as DayOfWeekNum
                        ,tuct.id_cycle_type
                        ,tp.DayOfWeek
                        ,tp.StartYear
                        ,tp.FirstDayOfMonth
                        ,tp.SecondDayOfMonth
                        ,tp.UsageCycleType
                        ,tp.PayerID
                    FROM (
                        SELECT   MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.DayOfWeek' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS DayOfWeek
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartDay' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartDay
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.StartYear' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS StartYear
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.FirstDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS FirstDayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.SecondDayOfMonth' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS SecondDayOfMonth
                                ,MAX(CASE WHEN tatp.nm_prop = N'Internal.UsageCycleType' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS UsageCycleType
                                ,MAX(CASE WHEN tatp.nm_prop = N'Account.PayerID' THEN CAST(tatp.nm_value AS INTEGER) ELSE CAST(-1 AS INTEGER) END) AS PayerID
                            FROM t_acc_template_props tatp
                            WHERE tatp.id_acc_template = idAccountTemplate
                            GROUP BY tatp.id_acc_template
                    ) tp
                    LEFT JOIN t_enum_data tedm ON tedm.id_enum_data = tp.StartMonth
                    LEFT JOIN t_enum_data tedc ON tedc.id_enum_data = tp.UsageCycleType
                    LEFT JOIN t_enum_data tedw ON tedw.id_enum_data = tp.DayOfWeek
                    LEFT JOIN t_months m ON UPPER(m.name) = UPPER(SUBSTR(tedm.nm_enum_data, INSTR(tedm.nm_enum_data, '/', -1) + 1))
                    LEFT JOIN t_day_of_week dw ON dw.name = UPPER(SUBSTR(tedw.nm_enum_data, INSTR(tedw.nm_enum_data, '/', -1) + 1))
                    LEFT JOIN t_usage_cycle_type tuct ON UPPER(tuct.tx_desc) = UPPER(SUBSTR(tedc.nm_enum_data, INSTR(tedc.nm_enum_data, '/', -1) + 1))

            ) ttp ON
                  tuc.id_cycle_type = ttp.id_cycle_type
              AND ttp.DayOfMonth = NVL(tuc.day_of_month, ttp.DayOfMonth)
              AND ttp.StartDay = NVL(tuc.start_day, ttp.StartDay)
              AND ttp.MonthNum = NVL(tuc.start_month, ttp.MonthNum)
              AND ttp.DayOfWeekNum = NVL(tuc.day_of_week, ttp.DayOfWeekNum)
              AND ttp.StartYear = NVL(tuc.start_year, ttp.StartYear)
              AND ttp.FirstDayOfMonth = NVL(tuc.first_day_of_month, ttp.FirstDayOfMonth)
              AND ttp.SecondDayOfMonth = NVL(tuc.second_day_of_month, ttp.SecondDayOfMonth);
        FOR acc IN (
            SELECT   ta.id_acc AS IdAcc
                ,tauc.id_usage_cycle AS OldUsageCycle
                ,tpr.id_payee
                ,tpr.id_payer
                ,tpr.vt_start
                ,tpr.vt_end
                ,tavi.c_Currency AS p_account_currency
            FROM T_VW_GET_ACCOUNTS_BY_TMPL_ID va
            JOIN t_account ta ON ta.id_acc = va.id_descendent
            JOIN t_acc_usage_cycle tauc ON tauc.id_acc = ta.id_acc
            LEFT JOIN t_payment_redirection tpr ON tpr.id_payee = ta.id_acc
            LEFT JOIN t_av_Internal tavi ON tavi.id_acc = ta.id_acc
            WHERE va.id_template = idAccountTemplate  AND systemDate BETWEEN COALESCE(va.vt_start, systemDate) AND COALESCE(va.vt_end, systemDate)
                AND (
                    (UsageCycleId <> -1 AND tauc.id_usage_cycle <> UsageCycleId)
                    OR (PayerId <> -1 AND tpr.id_payee <> PayerId)
                )
                AND ta.id_acc = COALESCE(account_id, ta.id_acc)
        )

        LOOP
            mt_acc_template.UpdateUsageCycleFromTemplate(
                IdAcc => acc.IdAcc,
                UsageCycleId => UsageCycleId,
                OldUsageCycle => acc.OldUsageCycle,
                systemDate => systemDate
            );

            mt_acc_template.UpdatePayerFromTemplate(
                IdAcc => acc.IdAcc
                ,PayerId => PayerId
                ,systemDate => systemDate
                ,p_account_currency => acc.p_account_currency
                ,sessionId => sessionId
                ,DetailTypeSubscription => DetailTypeSubscription
                ,DetailResultInformation => DetailResultInformation
                ,nRetryCount => nRetryCount
            );
        END LOOP;

        IF (doCommit = 'Y')
        THEN
        COMMIT;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF (doCommit = 'Y')
            THEN
            ROLLBACK;
            END IF;
            InsertTmplSessionDetail
            (
                sessionId,
                DetailTypeSubscription,
                DetailResultFailure,
                'Applying template failed with error message: ' || SQLERRM,
                nRetryCount,
                doCommit
            );
    END;

    mt_acc_template.apply_subscriptions(
        template_id                => idAccountTemplate,
        sub_start                  => sub_start,
        sub_end                    => sub_end,
        next_cycle_after_startdate => next_cycle_after_startdate,
        next_cycle_after_enddate   => next_cycle_after_enddate,
        user_id                    => user_id,
        id_audit                   => null,
        id_event_success           => id_event_success,
        id_event_failure           => id_event_failure,
        systemdate                 => systemDate,
        id_template_session        => sessionId,
        retrycount                 => nRetryCount,
        doCommit                   => 'N'
    );

END;
/


CREATE OR REPLACE 
PROCEDURE ApplyAccountTemplate
(
    accountTemplateId          NUMBER,
    sessionId                  NUMBER,
    systemDate                 DATE,
    sub_start                  DATE,
    sub_end                    DATE,
    next_cycle_after_startdate CHAR,
    next_cycle_after_enddate   CHAR,
    id_event_success           INT,
    id_event_failure           INT,
    account_id                 INT DEFAULT NULL,
    doCommit                   CHAR DEFAULT 'Y'
)
AS
    nRetryCount NUMBER := 0;
    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    id_acc_type NUMBER(10);
    id_acc NUMBER(10);
    user_id NUMBER(10);
BEGIN

    SELECT id_acc_type, id_folder
      INTO id_acc_type, id_acc
      FROM t_acc_template
     WHERE id_acc_template = accountTemplateId;


    SELECT id_enum_data
      INTO DetailTypeGeneral
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';

    SELECT id_enum_data
      INTO DetailResultInformation
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information';

    SELECT id_enum_data
      INTO DetailTypeSubscription
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';

    SELECT NVL(MAX(id_submitter),0)
    INTO   user_id
    FROM   t_acc_template_session ts
    WHERE  id_session = sessionId;

    --!!!Starting application of template
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Starting application of template',
        nRetryCount,
        doCommit
    );

    /* Updating session details with a number of themplates to be applied in the session */
    UPDATE t_acc_template_session
    SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = id_acc AND aa.id_descendent = at.id_folder)
    WHERE  id_session = sessionId;

    IF (doCommit = 'Y')
    THEN
    COMMIT;
    END IF;

    --Select account hierarchy for current template and for each child template.
    FOR tmpl in (
        SELECT tat.id_acc_template
          FROM t_account_ancestor taa
          JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = id_acc_type
         WHERE taa.id_ancestor = id_acc)
    LOOP

        --Apply account template to appropriate account list.
        ApplyTemplateToAccounts
        (
            idAccountTemplate          => tmpl.id_acc_template,
            sessionId                  => sessionId,
            nRetryCount                => nRetryCount,
            systemDate                 => systemDate,
            sub_start                  => sub_start,
            sub_end                    => sub_end,
            next_cycle_after_startdate => next_cycle_after_startdate,
            next_cycle_after_enddate   => next_cycle_after_enddate,
            user_id                    => user_id,
            id_event_success           => id_event_success,
            id_event_failure           => id_event_failure,
            account_id                 => account_id,
            doCommit                   => doCommit
        );

        UPDATE t_acc_template_session
        SET    n_templates_applied = n_templates_applied + 1
        WHERE  id_session = sessionId;

        IF (doCommit = 'Y')
        THEN
        COMMIT;
        END IF;

    END LOOP;

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = accountTemplateId
       AND aa.num_generations > 0
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role);

    /* Finalize session state */
    UPDATE t_acc_template_session
    SET    n_templates = n_templates_applied
    WHERE  id_session = sessionId;

    --!!!Template application complete
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Template application complete',
        nRetryCount,
        doCommit
    );
END;
/

CREATE PROCEDURE MTSP_GENERATE_ST_NRCS_QUOTING
(
  v_dt_start    DATE,
  v_dt_end      DATE,
  v_id_accounts VARCHAR2,
  v_id_interval INT,
  v_id_batch    VARCHAR2,
  v_n_batch_size INT,
  v_run_date    DATE,
  v_is_group_sub INT,
  v_p_count OUT INT
)
AS
   v_id_nonrec  INT;
   v_n_batches  INT;
   v_total_nrcs INT;
   v_id_message INT;
   v_id_ss      INT;
   v_tx_batch   VARCHAR2(256);
BEGIN

   DELETE FROM TMP_NRC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_NRC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));

   DELETE FROM TMP_NRC;

    v_tx_batch := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw (v_id_batch)));

   IF v_is_group_sub > 0 THEN
   BEGIN
   INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit,
            c__CollectionID
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              mem.vt_start AS c_NRCIntervalSubscriptionStart,
              mem.vt_end AS c_NRCIntervalSubscriptionEnd,
              mem.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit,
              v_tx_batch AS c__CollectionID
            FROM t_sub sub
                  JOIN t_gsubmember mem
                   ON mem.id_group = sub.id_group
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc
                   ON acc.id_acc = sub.id_acc
                  JOIN t_po
                   ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm
                   ON sub.id_po = plm.id_po
                  AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp
                   ON bp.id_prop = plm.id_pi_instance
                  AND bp.n_kind = 30
                  JOIN t_nonrecur nrc
                   ON nrc.id_prop = bp.id_prop
                  AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;

   END;
   ELSE
   BEGIN

       INSERT INTO TMP_NRC
       (
            id_source_sess,
            c_NRCEventType,
            c_NRCIntervalStart,
            c_NRCIntervalEnd,
            c_NRCIntervalSubscriptionStart,
            c_NRCIntervalSubscriptionEnd,
            c__AccountID,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c__SubscriptionID,
            c__IntervalID,
            c__Resubmit,
            c__CollectionID
       )
            SELECT SYS_GUID() AS id_source_sess,
              nrc.n_event_type AS c_NRCEventType,
              v_dt_start AS c_NRCIntervalStart,
              v_dt_end AS c_NRCIntervalEnd,
              sub.vt_start AS c_NRCIntervalSubscriptionStart,
              sub.vt_end AS c_NRCIntervalSubscriptionEnd,
              sub.id_acc AS c__AccountID,
              plm.id_pi_instance AS c__PriceableItemInstanceID,
              plm.id_pi_template AS c__PriceableItemTemplateID,
              sub.id_po AS c__ProductOfferingID,
              sub.id_sub AS c__SubscriptionID,
              v_id_interval AS c__IntervalID,
              '0' AS c__Resubmit,
              v_tx_batch AS c__CollectionID
            FROM t_sub sub
                  JOIN TMP_NRC_ACCOUNTS_FOR_RUN acc
                   ON acc.id_acc = sub.id_acc
                  JOIN t_po
                   ON sub.id_po = t_po.id_po
                  JOIN t_pl_map plm
                   ON sub.id_po = plm.id_po
                  AND plm.id_paramtable IS NULL
                  JOIN t_base_props bp
                   ON bp.id_prop = plm.id_pi_instance
                  AND bp.n_kind = 30
                  JOIN t_nonrecur nrc
                   ON nrc.id_prop = bp.id_prop
                  AND nrc.n_event_type = 1
            WHERE sub.vt_start >= v_dt_start
                  AND sub.vt_start < v_dt_end
        ;
  END;
  END IF;

   SELECT COUNT(*)
     INTO v_total_nrcs
     FROM tmp_nrc ;

   SELECT id_enum_data
     INTO v_id_nonrec
     FROM t_enum_data ted
      WHERE ted.nm_enum_data = 'metratech.com/nonrecurringcharge';

   v_n_batches := (v_total_nrcs / v_n_batch_size) + 1;

   GetIdBlock(v_n_batches,
              'id_dbqueuesch',
              v_id_message);

   GetIdBlock(v_n_batches,
              'id_dbqueuess',
              v_id_ss);

   INSERT INTO t_message
     ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
     SELECT id_message,
            NULL,
            v_run_date,
            v_run_date,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            '127.0.0.1'
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message
              FROM tmp_nrc  ) a
       GROUP BY id_message;

   INSERT INTO t_session
     ( id_ss, id_source_sess )
     SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
            id_source_sess
       FROM tmp_nrc ;

   INSERT INTO t_session_set
     ( id_message, id_ss, id_svc, b_root, session_count )
     SELECT id_message,
            id_ss,
            v_id_nonrec,
            b_root,
            COUNT(1) session_count
       FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_message,
                     v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY id_source_sess  ), v_n_batches)) id_ss,
                     1 b_root
              FROM tmp_nrc  ) a
       GROUP BY id_message,id_ss,b_root;

   INSERT INTO t_svc_nonrecurringcharge
     (  id_source_sess,
        id_parent_source_sess,
        id_external,
        c_NRCEventType,
        c_NRCIntervalStart,
        c_NRCIntervalEnd,
        c_NRCIntervalSubscriptionStart,
        c_NRCIntervalSubscriptionEnd,
        c__AccountID,
        c__PriceableItemInstanceID,
        c__PriceableItemTemplateID,
        c__ProductOfferingID,
        c__SubscriptionID,
        c__IntervalID,
        c__Resubmit,
        c__TransactionCookie,
        c__CollectionID )
     ( SELECT
          id_source_sess,
          NULL id_parent_source_sess,
          NULL id_external,
          c_NRCEventType,
          c_NRCIntervalStart,
          c_NRCIntervalEnd,
          c_NRCIntervalSubscriptionStart,
          c_NRCIntervalSubscriptionEnd,
          c__AccountID,
          c__PriceableItemInstanceID,
          c__PriceableItemTemplateID,
          c__ProductOfferingID,
          c__SubscriptionID,
          c__IntervalID,
          c__Resubmit,
          NULL as c__TransactionCookie,
          c__CollectionID
       FROM tmp_nrc  );

    DELETE FROM TMP_NRC;

   v_p_count := v_total_nrcs;

END;
/

CREATE PROCEDURE RemoveGroupSub_Quoting (
   p_id_sub             INT,
   p_systemdate         DATE,
   p_status       OUT   INT
)
AS
   v_groupid    INT;
   v_maxdate    DATE;
   v_nmembers   INT;
   v_icbid      INT;
BEGIN
   p_status := 0;

   FOR i IN (SELECT id_group, dbo.mtmaxdate () mtmaxdate
               FROM t_sub
              WHERE id_sub = p_id_sub)
   LOOP
      v_groupid := i.id_group;
      v_maxdate := i.mtmaxdate;
   END LOOP;

   FOR i IN (SELECT DISTINCT id_pricelist
                        FROM t_pl_map
                       WHERE id_sub = p_id_sub)
   LOOP
      v_icbid := i.id_pricelist;
   END LOOP;

   DELETE FROM t_gsub_recur_map
         WHERE id_group = v_groupid;

   DELETE FROM t_recur_value
         WHERE id_sub = p_id_sub;

   /* id_po is overloaded.  If b_group == Y then id_po is */
   /* the group id otherwise id_po is the product offering id. */
   DELETE FROM t_acc_template_subs
         WHERE id_group = v_groupid AND id_po IS NULL;

   /* Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables */
   DELETE FROM t_pl_map
         WHERE id_sub = p_id_sub;

   UPDATE t_recur_value
      SET tt_end = p_systemdate
    WHERE id_sub = p_id_sub AND tt_end = v_maxdate;

   UPDATE t_sub_history
      SET tt_end = p_systemdate
    WHERE tt_end = v_maxdate AND id_sub = p_id_sub;

   DELETE FROM t_sub
         WHERE id_sub = p_id_sub;
         
   DELETE FROM t_char_values
         WHERE id_entity = p_id_sub;

   IF (v_icbid IS NOT NULL)
   THEN
      sp_deletepricelist (v_icbid, p_status);

      IF p_status <> 0
      THEN
         RETURN;
      END IF;
   END IF;

   UPDATE t_group_sub
      SET tx_name =
             CAST ('[DELETED ' || CAST (SYSDATE AS NVARCHAR2 (22)) || ']'
                   || tx_name AS NVARCHAR2 (255)
                  )
    WHERE id_group = v_groupid;
END;
/

CREATE PROCEDURE MTSP_GENERATE_ST_RCS_QUOTING
(   v_id_interval  INT ,
    v_id_billgroup INT ,
    v_id_run       INT ,
    v_id_accounts VARCHAR2,
    v_id_batch NVARCHAR2 ,
    v_n_batch_size INT ,
    v_run_date DATE ,
    v_p_count OUT INT)
AS
  v_total_rcs  INT;
  v_total_flat INT;
  v_total_udrc INT;
  v_n_batches  INT;
  v_id_flat    INT;
  v_id_udrc    INT;
  v_id_message NUMBER;
  v_id_ss      INT;
  v_tx_batch   VARCHAR2(256);
  
BEGIN
  
   DELETE FROM TMP_RC_ACCOUNTS_FOR_RUN;
   INSERT INTO TMP_RC_ACCOUNTS_FOR_RUN ( ID_ACC )
        SELECT * FROM table(cast(dbo.CSVToInt(v_id_accounts) as  tab_id_instance));

   DELETE FROM TMP_RCS;
   INSERT INTO TMP_RCS
   (
      idSourceSess,
      c_RCActionType,
      c_RCIntervalStart,
      c_RCIntervalEnd,
      c_BillingIntervalStart,
      c_BillingIntervalEnd,
      c_RCIntervalSubscriptionStart,
      c_RCIntervalSubscriptionEnd,
      c_SubscriptionStart,
      c_SubscriptionEnd,
      c_Advance,
      c_ProrateOnSubscription,
      c_ProrateInstantly,
      c_ProrateOnUnsubscription,
      c_ProrationCycleLength,
      c__AccountID,
      c__PayingAccount,
      c__PriceableItemInstanceID,
      c__PriceableItemTemplateID,
      c__ProductOfferingID,
      c_BilledRateDate,
      c__SubscriptionID,
      c_payerstart,
      c_payerend,
      c_unitvaluestart,
      c_unitvalueend,
      c_unitvalue,
      c_RatingType
    )
      SELECT
        ID_SOURCE_SESS AS idSourceSess,
        c_RCActionType,
        c_RCIntervalStart,
        c_RCIntervalEnd,
        c_BillingIntervalStart,
        c_BillingIntervalEnd,
        c_RCIntervalSubscriptionStart,
        c_RCIntervalSubscriptionEnd,
        c_SubscriptionStart,
        c_SubscriptionEnd,
        c_Advance,
        c_ProrateOnSubscription,
        c_ProrateInstantly,
        c_ProrateOnUnsubscription,
        c_ProrationCycleLength,
        c_AccountID,
        c_PayingAccount,
        c_PriceableItemInstanceID,
        c_PriceableItemTemplateID,
        c_ProductOfferingID,
        c_BilledRateDate,
        c_SubscriptionID,
        c_payerstart,
        c_payerend,
        c_unitvaluestart,
        c_unitvalueend,
        c_unitvalue,
        c_ratingtype
        FROM
        ( SELECT SYS_GUID() AS ID_SOURCE_SESS,
          'Arrears' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          dbo.mtmaxoftwodates(pci.dt_start, rw.c_SubscriptionStart) AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          rw.c_advance AS c_Advance,
          rcr.b_prorate_on_activate AS c_ProrateOnSubscription,
          rcr.b_prorate_instantly AS c_ProrateInstantly,
          rcr.b_prorate_on_deactivate AS c_ProrateOnUnsubscription,
          CASE
               WHEN rcr.b_fixed_proration_length = 'Y'
               THEN fxd.n_proration_length
               ELSE 0
          END AS c_ProrationCycleLength,
          rw.c__accountid AS c_AccountID,
          rw.C__PAYINGACCOUNT AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_end AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
        /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* interval overlaps with UDRC */
   /* rc overlaps with this subscription */
        FROM t_usage_interval ui
          LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm
          ON 1 = 1
          JOIN t_recur_window rw
          ON bgm.id_acc = rw.C__PAYINGACCOUNT
          AND rw.c_payerstart < ui.dt_end
          AND rw.c_payerend > ui.dt_start
          /* interval overlaps with payer */
          AND rw.c_cycleeffectivestart < ui.dt_end
          AND rw.c_cycleeffectiveend > ui.dt_start
          /* interval overlaps with cycle */
          AND rw.c_membershipstart < ui.dt_end
          AND rw.c_membershipend > ui.dt_start
          /* interval overlaps with membership */
          AND rw.c_subscriptionstart < ui.dt_end
          AND rw.c_subscriptionend > ui.dt_start
          /* interval overlaps with subscription */
          AND rw.c_unitvaluestart < ui.dt_end
          AND rw.c_unitvalueend > ui.dt_start
          JOIN t_recur rcr
          ON rw.c__priceableiteminstanceid = rcr.id_prop
          JOIN t_usage_cycle ccl
          ON ccl.id_usage_cycle =
            CASE
                WHEN rcr.tx_cycle_mode = 'Fixed'
                    THEN rcr.id_usage_cycle
                WHEN rcr.tx_cycle_mode LIKE 'BCR%'
                    THEN ui.id_usage_cycle
                WHEN rcr.tx_cycle_mode = 'EBCR'
                    THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                ELSE NULL
            END
                      /* NOTE: we do not join RC interval by id_interval.  It is different (not sure what the reasoning is) */
          JOIN t_pc_interval pci
          ON pci.id_cycle = ccl.id_usage_cycle
          AND pci.dt_end BETWEEN ui.dt_start AND ui.dt_end
          /* rc end falls in this interval */
          AND pci.dt_end BETWEEN rw.c_payerstart AND rw.c_payerend
          /* rc end goes to this payer */
          AND rw.c_unitvaluestart < pci.dt_end
          AND rw.c_unitvalueend > pci.dt_start
          /* rc overlaps with this UDRC */
          AND rw.c_membershipstart < pci.dt_end
          AND rw.c_membershipend > pci.dt_start
          /* rc overlaps with this membership */
          AND rw.c_cycleeffectivestart < pci.dt_end
          AND rw.c_cycleeffectiveend > pci.dt_start
          /* rc overlaps with this cycle */
          AND rw.c_SubscriptionStart < pci.dt_end
          AND rw.c_subscriptionend > pci.dt_start
          JOIN t_usage_cycle_type fxd
           ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
          AND ui.id_interval = v_id_interval
          /*and bg.id_billgroup = @v_id_billgroup*/
          AND rcr.b_advance <> 'Y'
        UNION ALL
               
        SELECT
          SYS_GUID() AS ID_SOURCE_SESS,
          'Advance' AS c_RCActionType,
          pci.dt_start AS c_RCIntervalStart,
          pci.dt_end AS c_RCIntervalEnd,
          ui.dt_start AS c_BillingIntervalStart,
          ui.dt_end AS c_BillingIntervalEnd,
          CASE
              WHEN rcr.tx_cycle_mode <> 'Fixed'
              AND nui.dt_start <> c_cycleEffectiveDate
              THEN dbo.MTMaxOfTwoDates(AddSecond(c_cycleEffectiveDate), pci.dt_start)
              ELSE pci.dt_start
          END AS c_RCIntervalSubscriptionStart,
          dbo.mtminoftwodates(pci.dt_end, rw.c_SubscriptionEnd) AS c_RCIntervalSubscriptionEnd,
          rw.c_SubscriptionStart AS c_SubscriptionStart,
          rw.c_SubscriptionEnd AS c_SubscriptionEnd,
          rw.c_advance AS c_Advance,
          rcr.b_prorate_on_activate AS c_ProrateOnSubscription,
          rcr.b_prorate_instantly AS c_ProrateInstantly,
          rcr.b_prorate_on_deactivate AS c_ProrateOnUnsubscription,
          CASE
              WHEN rcr.b_fixed_proration_length = 'Y'
              THEN fxd.n_proration_length
              ELSE 0
          END AS c_ProrationCycleLength,
          rw.c__accountid AS c_AccountID,
          rw.c__payingaccount AS c_PayingAccount,
          rw.c__priceableiteminstanceid AS c_PriceableItemInstanceID,
          rw.c__priceableitemtemplateid AS c_PriceableItemTemplateID,
          rw.c__productofferingid AS c_ProductOfferingID,
          pci.dt_start AS c_BilledRateDate,
          rw.c__subscriptionid AS c_SubscriptionID,
          rw.c_payerstart,
          rw.c_payerend,
          CASE
            WHEN rw.c_unitvaluestart < TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            THEN TO_DATE('19700101000000', 'YYYYMMDDHH24MISS')
            ELSE rw.c_unitvaluestart
          END AS c_unitvaluestart,
          rw.c_unitvalueend,
          rw.c_unitvalue,
          rcr.n_rating_type AS c_RatingType
   /*INNER LOOP JOIN t_billgroup bg ON bg.id_usage_interval = ui.id_interval
         INNER LOOP JOIN t_billgroup_member bgm ON bg.id_billgroup = bgm.id_billgroup*/
   /* next interval overlaps with UDRC */
   /* rc overlaps with this subscription */
          FROM t_usage_interval ui
              JOIN t_usage_interval nui
               ON ui.id_usage_cycle = nui.id_usage_cycle
              AND dbo.AddSecond(ui.dt_end) = nui.dt_start
              LEFT JOIN TMP_RC_ACCOUNTS_FOR_RUN bgm
               ON 1 = 1
              JOIN t_recur_window rw
               ON bgm.id_acc = rw.c__payingaccount
              AND rw.c_payerstart < nui.dt_end
              AND rw.c_payerend > nui.dt_start
              /* next interval overlaps with payer */
              AND rw.c_cycleeffectivestart < nui.dt_end
              AND rw.c_cycleeffectiveend > nui.dt_start
              /* next interval overlaps with cycle */
              AND rw.c_membershipstart < nui.dt_end
              AND rw.c_membershipend > nui.dt_start
              /* next interval overlaps with membership */
              AND rw.c_subscriptionstart < nui.dt_end
              AND rw.c_subscriptionend > nui.dt_start
              /* next interval overlaps with subscription */
              AND rw.c_unitvaluestart < nui.dt_end
              AND rw.c_unitvalueend > nui.dt_start
              JOIN t_recur rcr
               ON rw.c__priceableiteminstanceid = rcr.id_prop
              JOIN t_usage_cycle ccl
               ON ccl.id_usage_cycle = CASE
                                            WHEN rcr.tx_cycle_mode = 'Fixed' THEN rcr.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode LIKE 'BCR%' THEN ui.id_usage_cycle
                                            WHEN rcr.tx_cycle_mode = 'EBCR' THEN dbo.DeriveEBCRCycle(ui.id_usage_cycle, rw.c_SubscriptionStart, rcr.id_cycle_type)
                                            ELSE NULL
               END
              JOIN t_pc_interval pci
               ON pci.id_cycle = ccl.id_usage_cycle
              AND pci.dt_start BETWEEN nui.dt_start AND nui.dt_end
              /* rc start falls in this interval */
              AND pci.dt_start BETWEEN rw.c_payerstart AND rw.c_payerend
              /* rc start goes to this payer */
              AND rw.c_unitvaluestart < pci.dt_end
              AND rw.c_unitvalueend > pci.dt_start
              /* rc overlaps with this UDRC */
              AND rw.c_membershipstart < pci.dt_end
              AND rw.c_membershipend > pci.dt_start
              /* rc overlaps with this membership */
              AND rw.c_cycleeffectivestart < pci.dt_end
              AND rw.c_cycleeffectiveend > pci.dt_start
              /* rc overlaps with this cycle */
              AND rw.c_SubscriptionStart < pci.dt_end
              AND rw.c_subscriptionend > pci.dt_start
              JOIN t_usage_cycle_type fxd
               ON fxd.id_cycle_type = ccl.id_cycle_type
          WHERE 1 = 1
              AND ui.id_interval = v_id_interval
              /*and bg.id_billgroup = @v_id_billgroup*/
              AND rcr.b_advance = 'Y'
        )  A;

   SELECT COUNT(1) INTO v_total_rcs FROM TMP_RC ;

   IF v_total_rcs > 0 THEN
   BEGIN
      SELECT COUNT(1) INTO v_total_flat FROM TMP_RC WHERE c_unitvalue IS NULL;

      SELECT COUNT(1) INTO v_total_udrc FROM TMP_RC WHERE c_unitvalue IS NOT NULL;

      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Flat RC Candidate Count: ' + CAST(@total_flat AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'UDRC RC Candidate Count: ' + CAST(@total_udrc AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Session Set Count: ' + CAST(@v_n_batch_size AS VARCHAR));
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch: ' + @v_id_batch);
      --INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Batch ID: ' + CAST(@tx_batch AS varchar));
      v_tx_batch := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw (v_id_batch)));

      IF v_total_flat > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_flat
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/flatrecurringcharge';

         v_n_batches := (v_total_flat / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches,
                    'id_dbqueuesch',
                    v_id_message);

         GetIdBlock(v_n_batches,
                    'id_dbqueuess',
                    v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess
             FROM TMP_RCS
              WHERE c_unitvalue IS NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_flat id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_FlatRecurringCharge
            (
              id_source_sess ,
              id_parent_source_sess ,
              id_external ,
              c_RCActionType ,
              c_RCIntervalStart ,
              c_RCIntervalEnd ,
              c_BillingIntervalStart ,
              c_BillingIntervalEnd ,
              c_RCIntervalSubscriptionStart ,
              c_RCIntervalSubscriptionEnd ,
              c_SubscriptionStart ,
              c_SubscriptionEnd ,
              c_Advance ,
              c_ProrateOnSubscription ,
              c_ProrateInstantly ,
              c_ProrateOnUnsubscription ,
              c_ProrationCycleLength ,
              c__AccountID ,
              c__PayingAccount ,
              c__PriceableItemInstanceID ,
              c__PriceableItemTemplateID ,
              c__ProductOfferingID ,
              c_BilledRateDate ,
              c__SubscriptionID ,
              c__IntervalID ,
              c__Resubmit ,
              c__TransactionCookie ,
              c__CollectionID
            )
            SELECT  idSourceSess,
                    NULL AS id_parent_source_sess,
                    NULL AS id_external,
                    c_RCActionType,
                    c_RCIntervalStart,
                    c_RCIntervalEnd,
                    c_BillingIntervalStart,
                    c_BillingIntervalEnd,
                    c_RCIntervalSubscriptionStart,
                    c_RCIntervalSubscriptionEnd,
                    c_SubscriptionStart,
                    c_SubscriptionEnd,
                    c_Advance,
                    c_ProrateOnSubscription,
                    c_ProrateInstantly,
                    c_ProrateOnUnsubscription,
                    c_ProrationCycleLength,
                    c__AccountID,
                    c__PayingAccount,
                    c__PriceableItemInstanceID,
                    c__PriceableItemTemplateID,
                    c__ProductOfferingID,
                    c_BilledRateDate,
                    c__SubscriptionID,
                    v_id_interval AS c__IntervalID,
                    '0' AS c__Resubmit,
                    NULL AS c__TransactionCookie,
                    v_tx_batch AS c__CollectionID
             FROM TMP_RCS
                WHERE c_unitvalue IS NULL ;

         INSERT INTO t_message
           ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
           SELECT id_message,
                  NULL,
                  v_run_date,
                  v_run_date,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  '127.0.0.1'
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NULL ) a
             GROUP BY a.id_message;

      END;
      END IF;

      /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting Flat RCs');*/
      IF v_total_udrc > 0 THEN
      BEGIN
         SELECT id_enum_data
           INTO v_id_udrc
           FROM t_enum_data ted
            WHERE ted.nm_enum_data = 'metratech.com/udrecurringcharge';

         v_n_batches := (v_total_udrc / v_n_batch_size) + 1;

         GetIdBlock(v_n_batches,
                    'id_dbqueuesch',
                    v_id_message);

         GetIdBlock(v_n_batches,
                    'id_dbqueuess',
                    v_id_ss);

         INSERT INTO t_session
           ( id_ss, id_source_sess )
           SELECT v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                  idSourceSess id_source_sess
             FROM TMP_RCS
              WHERE c_unitvalue IS NOT NULL;

         INSERT INTO t_session_set
           ( id_message, id_ss, id_svc, b_root, session_count )
           SELECT id_message,
                  id_ss,
                  id_svc,
                  b_root,
                  COUNT(1) session_count
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message,
                           v_id_ss + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_ss,
                           v_id_udrc id_svc,
                           1 b_root
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message,id_ss,id_svc,b_root;

         INSERT INTO t_svc_UDRecurringCharge
           (
          id_source_sess,
          id_parent_source_sess,
          id_external,
          c_RCActionType,
          c_RCIntervalStart,
          c_RCIntervalEnd,
          c_BillingIntervalStart,
          c_BillingIntervalEnd ,
          c_RCIntervalSubscriptionStart ,
          c_RCIntervalSubscriptionEnd ,
          c_SubscriptionStart ,
          c_SubscriptionEnd ,
          c_Advance ,
          c_ProrateOnSubscription ,
          /*    c_ProrateInstantly , */
          c_ProrateOnUnsubscription ,
          c_ProrationCycleLength ,
          c__AccountID ,
          c__PayingAccount ,
          c__PriceableItemInstanceID ,
          c__PriceableItemTemplateID ,
          c__ProductOfferingID ,
          c_BilledRateDate ,
          c__SubscriptionID ,
          c__IntervalID ,
          c__Resubmit ,
          c__TransactionCookie ,
          c__CollectionID ,
          c_unitvaluestart ,
          c_unitvalueend ,
          c_unitvalue ,
          c_ratingtype
        )
         SELECT
            idSourceSess,
            NULL AS id_parent_source_sess,
            NULL AS id_external,
            c_RCActionType,
            c_RCIntervalStart,
            c_RCIntervalEnd,
            c_BillingIntervalStart,
            c_BillingIntervalEnd,
            c_RCIntervalSubscriptionStart,
            c_RCIntervalSubscriptionEnd,
            c_SubscriptionStart,
            c_SubscriptionEnd,
            c_Advance,
            c_ProrateOnSubscription,
            /*    ,c_ProrateInstantly */
            c_ProrateOnUnsubscription,
            c_ProrationCycleLength,
            c__AccountID,
            c__PayingAccount,
            c__PriceableItemInstanceID,
            c__PriceableItemTemplateID,
            c__ProductOfferingID,
            c_BilledRateDate,
            c__SubscriptionID,
            v_id_interval AS c__IntervalID,
            '0' AS c__Resubmit,
            NULL AS c__TransactionCookie,
            v_tx_batch c__CollectionID,
            c_unitvaluestart,
            c_unitvalueend,
            c_unitvalue,
            c_ratingtype
        FROM TMP_RCS
        WHERE c_unitvalue IS NOT NULL ;

        INSERT INTO t_message
           ( id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_TransactionID, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address )
           SELECT id_message,
                  NULL,
                  v_run_date,
                  v_run_date,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  '127.0.0.1'
             FROM ( SELECT v_id_message + (MOD(ROW_NUMBER() OVER ( ORDER BY idSourceSess  ), v_n_batches)) id_message
                    FROM TMP_RCS
                       WHERE c_unitvalue IS NOT NULL ) a
             GROUP BY id_message;

      END;
      END IF;

   END;
   END IF;

   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Debug', 'Done inserting UDRC RCs');*/
   v_p_count := v_total_rcs;
   /*INSERT INTO [dbo].[t_recevent_run_details] ([id_run], [dt_crt], [tx_type], [tx_detail]) VALUES (@v_id_run, GETUTCDATE(), 'Info', 'Finished submitting RCs, count: ' + CAST(@total_rcs AS VARCHAR));*/
END;
/


CREATE OR REPLACE 
PROCEDURE inserttemplatesession
(
    id_template_owner INT,
    nm_acc_type VARCHAR2,
    id_submitter INT,
    nm_host VARCHAR2,
    n_status INT,
    n_accts INT,
    n_subs INT,
    session_id OUT INT,
    doCommit CHAR DEFAULT 'Y'
)
AS
BEGIN
    IF (doCommit = 'Y') THEN
        getcurrentid(
            p_nm_current => 'id_template_session',
            p_id_current => session_id
        );
    ELSE
        SELECT id_current INTO session_id FROM t_current_id WHERE nm_current = 'id_template_session' FOR UPDATE OF id_current;
        UPDATE t_current_id SET id_current=id_current+1 where nm_current='id_template_session';
    END IF;
    insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
    values (session_id, id_template_owner, nm_acc_type, CURRENT_DATE, id_submitter, nm_host, n_status, n_accts, n_subs);
    IF (doCommit = 'Y') THEN
        COMMIT;
    END IF;
END;
/


create  or replace 
procedure MoveAccount
    (p_new_parent int,
     p_account_being_moved int,
   p_vt_move_start date,
   p_enforce_same_corporation varchar2,
   p_system_time date,
   p_status out int ,
   p_id_ancestor_out out int,
   p_ancestor_type out varchar2,
   p_acc_type out varchar2
)
as
vt_move_end date;
varMaxDateTime  date;
v_AccCreateDate  date;
v_AccMaxCreateDate  date;
v_dt_start date;
v_realstartdate  date;
v_id_ancestor  int;
v_id_descendent  int;
v_ancestor_acc_type  varchar(5);
v_descendent_acc_type  varchar(5);
originalAncestor int;
syntheticroot varchar2(1);
dummy_type int;
p_vt_move_start_trunc date;
allTypesSupported int;
templateId int;
templateOwner int;
templateCount int;
sessionId int;
begin
    vt_move_end := dbo.MTMaxDate();
    
    p_vt_move_start_trunc := dbo.MTStartofDay(p_vt_move_start);

    /* plug business rules back in*/

    v_dt_start      := p_vt_move_start_trunc;
    v_id_ancestor   := p_new_parent;
    v_id_descendent := p_account_being_moved;

    v_realstartdate := dbo.mtstartofday(v_dt_start) ;
        select max(vt_end) into varMaxDateTime from t_account_ancestor where id_descendent = v_id_descendent
        and id_ancestor = 1;

    begin

        select
        dbo.mtminoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt)),
        ancestor.id_type, descendent.id_type
        into v_AccCreateDate,v_ancestor_acc_type,v_descendent_acc_type
        from t_account ancestor
        inner join t_account descendent ON
        ancestor.id_acc = v_id_ancestor and
        descendent.id_acc = v_id_descendent;
    exception
    when no_data_found then
        null;
    end;

select name into p_ancestor_type
from t_account_type
where id_type = v_ancestor_acc_type;


select name into p_acc_type
from t_account_type
where id_type = v_descendent_acc_type;

    begin
        select
        dbo.mtmaxoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt))
        into v_AccMaxCreateDate
        from t_account ancestor,t_account descendent where ancestor.id_acc = v_id_ancestor and
        descendent.id_acc = v_id_descendent;
    exception
            when no_data_found then
            null;
    end;

    if dbo.mtstartofday(v_dt_start) < dbo.mtstartofday(v_AccMaxCreateDate)  then
        /* MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE*/
        p_status := -486604750;
        return;
    end if;


    /* step : make sure that the new ancestor is not actually a child*/
    select count(*) into p_status
    from t_account_ancestor
    where id_ancestor = v_id_descendent
    and id_descendent = v_id_ancestor AND
    v_realstartdate between vt_start AND vt_end;

    if p_status > 0 then
        /* MT_NEW_PARENT_IS_A_CHILD*/
        p_status := -486604797;
        return;
    end if;

    select count(*) into p_status
    from t_account_ancestor
    where id_ancestor = v_id_ancestor
    and id_descendent = v_id_descendent
    and num_generations = 1
    and v_realstartdate >= vt_start
    and vt_end = varMaxDateTime;

    if p_status > 0 then
        /* MT_NEW_ANCESTOR_IS_ALREADY_ A_ANCESTOR*/
        p_status := 1;
        return;
    end if;

      /* step : make sure that the account is not archived or closed*/
    select count(*)  into p_status from t_account_state
    where id_acc = v_id_descendent
    and (dbo.IsClosed(p_status) = 1 OR dbo.isArchived(p_status) = 1)
    and v_realstartdate between vt_start AND vt_end;
    if (p_status > 0 ) then
        /* OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED*/
        p_status := -469368827;
        return;
    end if;

    /* step : make sure that the account is not a corporate account*/
    /*only check next 2 business rules if p_enforce_same_corporation rule is turned on*/
    if p_enforce_same_corporation = 1 then
        if (dbo.iscorporateaccount(v_id_descendent,v_dt_start) = 1)
        then
            /* MT_CANNOT_MOVE_CORPORATE_ACCOUNT*/
            p_status := -486604770;
            return;
    end if;
        /* do this check if the original ancestor of the account being moved is not -1
         or the new ancestor is not -1 */
        select id_ancestor into originalAncestor from t_account_ancestor
            where id_descendent =  v_id_descendent
            and num_generations = 1
            and p_vt_move_start_trunc >= vt_start and p_vt_move_start_trunc <= vt_end;

        if (originalAncestor <> -1 AND v_id_ancestor <> -1 AND
        dbo.IsInSameCorporateAccount(v_id_ancestor,v_id_descendent,v_realstartdate) <> 1)
        then
            /* MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES*/
            p_status := -486604759;
            return;
        end if;
    end if;

    /*check that both ancestor and descendent are subscriber accounts.  This check has to be recast.. you can
     only move if the new ancestor allows children of type @descendent_acc_type */

    select count(*) into dummy_type from dual
    where exists (select 1 from t_acctype_descendenttype_map
    where id_type = v_ancestor_acc_type
    and id_descendent_type = v_descendent_acc_type);
    if (dummy_type = 0)
    then
        /* MT_ANCESTOR_OF_INCORRECT_TYPE */
        p_status := -486604714;
        return;
    END if;
    
    /* check that only accounts whose type says b_canHaveSyntheticRoot is true can have -1 as an ancestor.*/
    if (v_id_ancestor = -1)
    then
    select b_CanhaveSyntheticRoot into syntheticroot from t_account_type where id_type = v_descendent_acc_type;
    if (syntheticroot <> '1')
    then
    /* MT_ANCESTOR_INVALID_SYNTHETIC_ROOT */
        p_status := -486604713;
        return;
    END if;
    END if;

    /* end business rules*/

/*METRAVIEW DATAMART */

insert into tmp_t_dm_account  select * from t_dm_account where id_acc in
(
select distinct id_descendent from t_account_ancestor where id_ancestor = p_account_being_moved
);
/* Deleting all the entries from ancestor table */
delete from t_dm_account_ancestor where id_dm_descendent in (select id_dm_acc from tmp_t_dm_account);
delete from t_dm_account where id_dm_acc in (select id_dm_acc from tmp_t_dm_account);

    insert into tmp_deletethese
    select
    aa2.id_ancestor,
    aa2.id_descendent,
    aa2.num_generations,
    aa2.b_children,
    dbo.MTMaxOfTwoDates(p_vt_move_start_trunc, dbo.MTMaxOfTwoDates(dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start), aa3.vt_start)) as vt_start,
    dbo.MTMinOfTwoDates(vt_move_end, dbo.MTMinOfTwoDates(dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end), aa3.vt_end)) as vt_end,
    aa2.tx_path
    from
    t_account_ancestor aa1
    inner join t_account_ancestor aa2 on aa1.id_ancestor=aa2.id_ancestor and aa1.vt_start <= aa2.vt_end and aa2.vt_start <= aa1.vt_end and aa2.vt_start <= vt_move_end and p_vt_move_start_trunc <= aa2.vt_end
    inner join t_account_ancestor aa3 on aa2.id_descendent=aa3.id_descendent and aa3.vt_start <= aa2.vt_end and aa2.vt_start <= aa3.vt_end and aa3.vt_start <= vt_move_end and p_vt_move_start_trunc <= aa3.vt_end
    where
    aa1.id_descendent=p_account_being_moved
    and
    aa1.num_generations > 0
    and
    aa1.vt_start <= vt_move_end
    and
    p_vt_move_start_trunc <= aa1.vt_end
    and
    aa3.id_ancestor=p_account_being_moved;

    /* select old direct ancestor id*/
    begin
        select id_ancestor into p_id_ancestor_out from tmp_deletethese
        where num_generations = 1 and p_vt_move_start_trunc between vt_start and vt_end;
    exception
        when no_data_found then
        null;
    end;

    /*select * from #deletethese
     The four statements of the sequenced delete follow.  Watch carefully :-)

     Create a new interval for the case in which the applicability interval of the update
     is contained inside the period of validity of the existing interval
     [------------------] (existing)
        [-----------] (update)*/

    insert into t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
    select aa.id_ancestor, aa.id_descendent, aa.num_generations, d.b_children,d.vt_start, d.vt_end,
    case when aa.id_descendent = 1 then
        aa.tx_path || d.tx_path
        else
        d.tx_path || '/' || aa.tx_path
        end
    from
    t_account_ancestor aa
    inner join tmp_deletethese d on aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
        aa.num_generations=d.num_generations and aa.vt_start < d.vt_start and aa.vt_end > d.vt_end;

    /* Update end date of existing records for which the applicability interval of the update
     starts strictly inside the existing record:
     [---------] (existing)
        [-----------] (update)
     or
     [---------------] (existing)
        [-----------] (update)*/
    update t_account_ancestor aa
    set
    vt_end = (select dbo.subtractsecond(d.vt_start) from
                            tmp_deletethese d where aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
                            aa.num_generations=d.num_generations and aa.vt_start < d.vt_start and aa.vt_end > d.vt_start)
        where exists
        (select 1 from
                            tmp_deletethese d where aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
                            aa.num_generations=d.num_generations and aa.vt_start < d.vt_start and aa.vt_end > d.vt_start);

    /* Update start date of existing records for which the effectivity interval of the update
     ends strictly inside the existing record:
                  [---------] (existing)
        [-----------] (update)*/
    update t_account_ancestor aa
    set
    vt_start = (select dbo.addsecond(d.vt_end)
    from tmp_deletethese d where aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
        aa.num_generations=d.num_generations and aa.vt_start <= d.vt_end and aa.vt_end > d.vt_end)
    where exists
    (select 1
    from tmp_deletethese d where aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
        aa.num_generations=d.num_generations and aa.vt_start <= d.vt_end and aa.vt_end > d.vt_end);

    /* Delete existing records for which the effectivity interval of the update
     contains the existing record:
           [---------] (existing)
         [---------------] (update)*/
    delete t_account_ancestor aa
    where exists
    (select 1
    from tmp_deletethese d where aa.id_ancestor=d.id_ancestor and aa.id_descendent=d.id_descendent and
        aa.num_generations=d.num_generations and aa.vt_start >= d.vt_start and aa.vt_end <= d.vt_end);

    /* SEQUENCED INSERT JOIN*/
    /* Now do the sequenced insert into select from with the sequenced*/
    /* cross join as the source of the data.*/

    insert into t_account_ancestor(id_ancestor, id_descendent, num_generations,b_children, vt_start, vt_end,tx_path)
    select aa1.id_ancestor,
    aa2.id_descendent,
    aa1.num_generations+aa2.num_generations+1 as num_generations,
    aa2.b_children,
    dbo.MTMaxOfTwoDates(p_vt_move_start_trunc, dbo.MTMaxOfTwoDates(aa1.vt_start, aa2.vt_start)) as vt_start,
    dbo.MTMinOfTwoDates(vt_move_end, dbo.MTMinOfTwoDates(aa1.vt_end, aa2.vt_end)) as vt_end,
    case when aa2.id_descendent = 1 then
        aa1.tx_path || aa2.tx_path
        else
        aa1.tx_path || '/' || aa2.tx_path
        end
    from
    t_account_ancestor aa1
    inner join t_account_ancestor aa2 on aa1.vt_start < aa2.vt_end and aa2.vt_start < aa1.vt_end and aa2.vt_start < vt_move_end and p_vt_move_start_trunc < aa2.vt_end
    where
    aa1.id_descendent = p_new_parent
    and
    aa1.vt_start < vt_move_end
    and
    p_vt_move_start_trunc < aa1.vt_end
    and
    aa2.id_ancestor = p_account_being_moved;

    /* Implement the coalescing step.*/
    /* TODO: Improve efficiency by restricting the updates to the rows that*/
    /* might need coalesing.*/
    update t_account_ancestor aa
    set vt_end = (
        select max(aa2.vt_end)
        from
        t_account_ancestor aa2
        where
        aa.id_ancestor=aa2.id_ancestor
        and
        aa.id_descendent=aa2.id_descendent
        and
        aa.num_generations=aa2.num_generations
        and
        aa.vt_start < aa2.vt_start
        and
        dbo.addsecond(aa.vt_end) >= aa2.vt_start
        and
        aa.vt_end < aa2.vt_end
        and
        aa.tx_path=aa2.tx_path
    )
    where
    exists (
        select *
        from
        t_account_ancestor aa2
        where
        aa.id_ancestor=aa2.id_ancestor
        and
        aa.id_descendent=aa2.id_descendent
        and
        aa.num_generations=aa2.num_generations
        and
        aa.vt_start < aa2.vt_start
        and
        dbo.addsecond(aa.vt_end) >= aa2.vt_start
        and
        aa.vt_end < aa2.vt_end
        and
        aa.tx_path=aa2.tx_path
    )
    and aa.id_descendent in (select id_descendent from tmp_deletethese);

    delete from t_account_ancestor AA
    where
    exists (
        select *
        from t_account_ancestor aa2
        where
        AA.id_ancestor=aa2.id_ancestor
        and
        AA.id_descendent=aa2.id_descendent
        and
        AA.num_generations=aa2.num_generations
        and
        AA.tx_path=aa2.tx_path
        and
        (
        (aa2.vt_start < AA.vt_start and AA.vt_end <= aa2.vt_end)
        or
        (aa2.vt_start <= AA.vt_start and AA.vt_end < aa2.vt_end)
        )
    )
    and id_descendent in (select id_descendent from TMP_deletethese);

    
   update t_path_capability
    set param_value = (
        select distinct aa.tx_path || '/'
        from
        t_account_ancestor aa
        inner join TMP_deletethese d on aa.id_descendent=d.id_descendent and aa.id_ancestor = 1
        inner join t_principal_policy p on p.id_acc = aa.id_descendent
        inner join t_capability_instance ci on ci.id_policy = p.id_policy
        where ci.id_cap_instance = t_path_capability.id_cap_instance
        and p_system_time between aa.vt_start and aa.vt_end
    )
    where exists (
        select 1
        from
        t_account_ancestor aa
        inner join TMP_deletethese d on aa.id_descendent=d.id_descendent and aa.id_ancestor = 1
        inner join t_principal_policy p on p.id_acc = aa.id_descendent
        inner join t_capability_instance ci on ci.id_policy = p.id_policy
        where ci.id_cap_instance = t_path_capability.id_cap_instance
        and p_system_time between aa.vt_start and aa.vt_end
   );

    update t_account_ancestor set b_Children = 'Y' where
    id_descendent = p_new_parent
    and b_children ='N';

    update t_account_ancestor old set b_Children = 'N' where
    id_descendent = p_id_ancestor_out and
    not exists (select 1 from t_account_ancestor new where new.id_ancestor=old.id_descendent
    and num_generations <>0 );

/* DataMart insert new id_dm_acc for moving account and descendents */
        insert into t_dm_account(id_dm_acc,id_acc,vt_start,vt_end) select seq_t_dm_account.nextval,anc.id_descendent, anc.vt_start, anc.vt_end
        from t_account_ancestor anc
        inner join tmp_t_dm_account acc on anc.id_descendent = acc.id_acc
        where anc.id_ancestor=1
        and acc.vt_end = varMaxDateTime;
    
        insert into t_dm_account_ancestor
        select dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
        from
        t_account_ancestor aa1
        inner join t_dm_account dm1 on aa1.id_descendent=dm1.id_acc and aa1.vt_start <= dm1.vt_end and dm1.vt_start <= aa1.vt_end
        inner join t_dm_account dm2 on aa1.id_ancestor=dm2.id_acc and aa1.vt_start <= dm2.vt_end and dm2.vt_start <= aa1.vt_end
        inner join tmp_t_dm_account acc on aa1.id_descendent = acc.id_acc
        where dm1.id_acc <> dm2.id_acc
        and dm1.vt_start >= dm2.vt_start
        and dm1.vt_end <= dm2.vt_end
        and acc.vt_end = varMaxDateTime;

        /*we are adding 0 level record for all children of moving account */
        insert into t_dm_account_ancestor select dm1.id_dm_acc,dm1.id_dm_acc,0
        from
        t_dm_account dm1
        inner join tmp_t_dm_account acc on dm1.id_acc = acc.id_acc
        and acc.vt_end = varMaxDateTime;
    
        delete from tmp_t_dm_account;
        delete from tmp_deletethese;

        
    SELECT NVL(MAX(all_types),0)
        INTO allTypesSupported
        FROM t_acc_tmpl_types;
    SELECT NVL(MIN(id_acc_template),-1), NVL(MIN(templOwner),-1), COUNT(*)
        INTO templateId, templateOwner, templateCount
        FROM
        (
        select  id_acc_template
                , template.id_folder as templOwner
            from
                    t_acc_template template
            INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
            INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
            inner join t_account_type atype on template.id_acc_type = atype.id_type
                WHERE id_descendent = p_new_parent AND
                    p_system_time between vt_start AND vt_end AND
                    (atype.name = p_acc_type OR allTypesSupported = 1)
            ORDER BY num_generations asc
        )
        where ROWNUM = 1;

    IF (templateCount <> 0 AND templateId <> -1)
    THEN
        updateprivatetempates(
            id_template => templateId
        );
        inserttemplatesession(templateOwner, p_acc_type, 0, ' ', 0, 0, 0, sessionId, 'N');
        ApplyAccountTemplate(
            accountTemplateId => templateId,
            sessionId => sessionId,
            systemDate => p_system_time,
            sub_start => p_system_time,
            sub_end => NULL,
            next_cycle_after_startdate => 'N',
            next_cycle_after_enddate   => 'N',
            id_event_success           => NULL,
            id_event_failure           => NULL,
            account_id                 => NULL,
            doCommit                   => 'N'
        );
    ELSE
        FOR tmpl IN (
            SELECT template.id_acc_template, template.id_folder, atype.name
                FROM t_account_ancestor ancestor
                JOIN t_acc_template template ON ancestor.id_descendent = template.id_folder
                JOIN t_account_type atype on template.id_acc_type = atype.id_type
                WHERE ancestor.id_ancestor = p_new_parent
        )
        LOOP
            updateprivatetempates(
                id_template => tmpl.id_acc_template
            );
            inserttemplatesession(templateOwner, p_acc_type, 0, ' ', 0, 0, 0, sessionId, 'N');
            ApplyAccountTemplate(
                accountTemplateId => tmpl.id_acc_template,
                sessionId => sessionId,
                systemDate => p_system_time,
                sub_start => p_system_time,
                sub_end => NULL,
                next_cycle_after_startdate => 'N',
                next_cycle_after_enddate   => 'N',
                id_event_success           => NULL,
                id_event_failure           => NULL,
                account_id                 => NULL,
                doCommit                   => 'N'
            );
        END LOOP;
        
    END IF;

    p_status:=1;
END;
/

CREATE OR REPLACE PROCEDURE GetPCViewHierarchy(
                p_id_acc       INT,
                p_id_interval  INT,
                p_id_lang_code INT,
                p_cur OUT sys_refcursor)
            AS
            BEGIN
                OPEN p_cur FOR
                SELECT 
                tb_po.n_display_name id_po,/* use the display name as the product offering ID */
                /* au.id_prod id_po, */
                pi_template.id_template_parent id_template_parent,
                /* po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end, */
                CASE WHEN T_DESCRIPTION.tx_desc IS NULL THEN template_desc.tx_desc ELSE T_DESCRIPTION.tx_desc END po_nm_name,
                ed.nm_enum_data pv_child,
                ed.id_enum_data pv_childID,
                CASE WHEN parent_kind.nm_productview IS NULL THEN tb_po.n_display_name ELSE tenum_parent.id_enum_data END pv_parentID,
                CASE WHEN pi_props.n_kind = 15 THEN 'Y' ELSE 'N' END AggRate,
                CASE WHEN au.id_pi_instance IS NULL THEN id_view ELSE 
                    (CASE WHEN pi_props.n_kind = 15 AND child_kind.nm_productview = ed.nm_enum_data THEN
                    -(au.id_pi_instance + TO_NUMBER(40000000,'XXXXXXXX'))
                    ELSE
                    -au.id_pi_instance 
                    END)
                END viewID,
                id_view realPVID,
                /* ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end, */
                CASE WHEN tb_instance.nm_display_name IS NULL THEN tb_template.nm_display_name ELSE tb_instance.nm_display_name END ViewName,
                'Product' ViewType,
                /* id_view DescriptionID, */
                CASE WHEN T_DESCRIPTION.tx_desc IS NULL THEN template_props.n_display_name ELSE id_view END DescriptionID,
                SUM(au.amount) Amount,
                COUNT(au.id_sess) COUNT,
                au.am_currency Currency, SUM((NVL((au.tax_federal), 
                0.0) + NVL((au.tax_state), 0.0) + NVL((au.tax_county), 0.0) + 
                NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0))) TaxAmount, 
                SUM(au.amount + 
                  /*If implied taxes, then taxes are already included, don't add them again */
                  (case when au.is_implied_tax = 'N' then (NVL((au.tax_federal), 0.0) + NVL((au.tax_state), 0.0) + 
                    NVL((au.tax_county), 0.0) + NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0)) else 0 end)
                  /*If informational taxes, then they shouldn't be in the total */
                  - (case when au.tax_informational = 'Y' then (NVL((au.tax_federal), 0.0) + NVL((au.tax_state), 0.0) + 
                    NVL((au.tax_county), 0.0) + NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0)) else 0 end))
                  AmountWithTax
                FROM T_USAGE_INTERVAL
                JOIN T_ACC_USAGE au ON au.id_acc = p_id_acc AND au.id_usage_interval = p_id_interval AND au.id_pi_template IS NOT NULL
                JOIN T_BASE_PROPS tb_template ON tb_template.id_prop = au.id_pi_template
                JOIN T_PI_TEMPLATE pi_template ON pi_template.id_template = au.id_pi_template
                JOIN T_PI child_kind ON child_kind.id_pi = pi_template.id_pi
                JOIN T_BASE_PROPS pi_props ON pi_props.id_prop = child_kind.id_pi
                JOIN T_ENUM_DATA ed ON ed.id_enum_data = au.id_view
                JOIN T_BASE_PROPS template_props ON pi_template.id_template = template_props.id_prop
                JOIN T_DESCRIPTION template_desc ON template_props.n_display_name = template_desc.id_desc AND template_desc.id_lang_code = p_id_lang_code
                LEFT OUTER JOIN T_PI_TEMPLATE parent_template ON parent_template.id_template = pi_template.id_template_parent
                LEFT OUTER JOIN T_PI parent_kind ON parent_kind.id_pi = parent_template.id_pi
                LEFT OUTER JOIN T_ENUM_DATA tenum_parent ON tenum_parent.nm_enum_data = parent_kind.nm_productview
                LEFT OUTER JOIN T_BASE_PROPS tb_po ON tb_po.id_prop = au.id_prod
                LEFT OUTER JOIN T_BASE_PROPS tb_instance ON tb_instance.id_prop = au.id_pi_instance 
                LEFT OUTER JOIN T_DESCRIPTION ON T_DESCRIPTION.id_desc = tb_po.n_display_name AND T_DESCRIPTION.id_lang_code = p_id_lang_code
                WHERE
                T_USAGE_INTERVAL.id_interval = p_id_interval
                GROUP BY 
                /* t_pl_map.id_po,t_pl_map.id_pi_instance_parent, */
                tb_po.n_display_name,tb_instance.n_display_name,
                T_DESCRIPTION.tx_desc,template_desc.tx_desc,
                tb_instance.nm_display_name,tb_template.nm_display_name,
                tb_instance.nm_display_name, /* this shouldn't need to be here!! */
                child_kind.nm_productview,
                parent_kind.nm_productview,tenum_parent.id_enum_data,
                pi_props.n_kind,
                id_view,ed.nm_enum_data,ed.id_enum_data,
                au.am_currency,
                tb_template.nm_name,
                pi_template.id_template_parent,
                au.id_pi_instance,
                template_props.n_display_name
                ORDER BY tb_po.n_display_name ASC, pi_template.id_template_parent ASC;
            END;
/

CREATE OR REPLACE PROCEDURE GetBalances(
p_id_acc int,
p_id_interval int,
p_previous_balance OUT number ,
p_balance_forward OUT number ,
p_current_balance OUT number ,
p_currency OUT nvarchar2 ,
p_estimation_code OUT int ,  /* 0 = NONE: no estimate, all balances taken from t_invoice */
                             /* 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, p_previous_balance taken from t_invoice */
                             /* 2 = PREVIOUS_BALANCE: all balances estimated  */
p_return_code OUT int
)
AS
  v_temp_bal number(22,10):=0;
  v_balance_date date;
  v_unbilled_prior_charges number(22,10);  /* unbilled charges from interval after invoice and before this one */
  v_previous_charges number(22,10);        /* payments, adjsutments for this interval */
  v_current_charges number(22,10);         /* current charges for this interval */
  v_interval_start date;
  v_tmp_amount number(22,10);
  v_tmp_currency nvarchar2(3);

BEGIN

  p_return_code := 0;

  /* step1: check for existing t_invoice, and use that one if exists */
  for i in ( SELECT
    current_balance current_balance ,
    current_balance - invoice_amount - tax_ttl_amt balance_forward,
    p_balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt previous_balance,
    invoice_currency currency
  FROM t_invoice
  WHERE id_acc = p_id_acc
  AND id_interval = p_id_interval) loop

    p_current_balance := i.current_balance ;
    p_balance_forward := i.balance_forward;
    p_previous_balance := i.previous_balance;
    p_currency := i.currency;

  end loop;

  IF p_current_balance IS NOT NULL THEN
    p_estimation_code := 0 ;
    RETURN; /* done */
  END IF;

  /* step2: get balance (as of v_interval_start) from previous invoice */
  /* set v_interval_start = (select dt_start from t_usage_interval where id_interval = p_id_interval) */
  /* AR: Bug fix for 10238, when billing cycle is changed. */

  for i in (select CASE WHEN aui.dt_effective IS NULL THEN ui.dt_start
                        ELSE dbo.addsecond(aui.dt_effective)
                   END effect_dt
            from t_acc_usage_interval aui
            inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval
            where aui.id_acc = p_id_acc
            AND ui.id_interval = p_id_interval)
    loop
        v_interval_start := i.effect_dt;
    end loop;

  GetLastBalance (p_id_acc, v_interval_start, p_previous_balance , v_balance_date , p_currency);

  /* step3: calc v_unbilled_prior_charges */
  v_unbilled_prior_charges := 0;

  /* add unbilled payments, and ar adjustments */

  for i in (SELECT SUM(au.Amount) Amount,
     au.am_currency am_currency
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
   INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
    AND au.id_acc = p_id_acc
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency)
  loop
    v_tmp_amount   := i.Amount;
    v_tmp_currency := i.am_currency;
    if v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
    end if;
  end loop;

  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := v_unbilled_prior_charges + v_tmp_amount;
  v_tmp_amount := 0.0;

  /* add unbilled current charges */
  for i in
  (SELECT SUM(nvl(au.Amount, 0.0)) +
           /*For implied taxes, tax is already included, so don't add it again*/
                       SUM(CASE WHEN (au.is_implied_tax = 'N') THEN  nvl(au.Tax_Federal,0.0) +
                       nvl(au.Tax_State,0.0) +
                       nvl(au.Tax_County,0.0) +
                       nvl(au.Tax_Local,0.0) +
                       nvl(au.Tax_Other,0.0) else 0 end) -
            /* Informational taxes don't get added into total */
                       SUM(CASE WHEN (au.tax_informational = 'Y') THEN  nvl(au.Tax_Federal,0.0) +
                       nvl(au.Tax_State,0.0) +
                       nvl(au.Tax_County,0.0) +
                       nvl(au.Tax_Local,0.0) +
                       nvl(au.Tax_Other,0.0) else 0 end) amt,
          au.am_currency curr
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
    INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval
    INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval
  WHERE
    vh.id_view = vh.id_view_parent
    AND au.id_acc = p_id_acc
    AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
    AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
    AND ui.dt_end > v_balance_date
    AND ui.dt_start < v_interval_start
  GROUP BY au.am_currency)
  loop
      v_tmp_amount   :=   i.amt;
      v_tmp_currency :=   i.curr;
      IF v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;
  end loop;

  v_tmp_amount := nvl(v_tmp_amount, 0);
  v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_tmp_amount,0);

  /* add unbilled pre-bill and post-bill adjustments */
        SELECT SUM(nvl(PrebillAdjAmt,0.0)) +
               SUM(nvl(PostbillAdjAmt,0.0)) +
               SUM(nvl(PrebillTaxAdjAmt,0.0)) +
               SUM(nvl(PostbillTaxAdjAmt,0.0))
        into v_temp_bal
         FROM vw_adjustment_summary
         WHERE id_acc = p_id_acc
         AND dt_end > v_balance_date
         AND dt_start < v_interval_start;

         v_unbilled_prior_charges := nvl(v_unbilled_prior_charges,0) + nvl(v_temp_bal,0);

  /* step4: add v_unbilled_prior_charges to p_previous_balance if any found */
  IF v_unbilled_prior_charges <> 0 then
    p_estimation_code  := 2;
    p_previous_balance := p_previous_balance + v_unbilled_prior_charges;
  ELSE
    p_estimation_code := 1;
  END IF;

  /* step5: get previous charges */
  for i in (SELECT
     SUM(au.Amount) amt,
     au.am_currency curr
  FROM t_acc_usage au
   INNER JOIN t_prod_view pv on au.id_view = pv.id_view
  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')
  AND au.id_acc = p_id_acc
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency) loop
       v_previous_charges := i.amt;
       v_tmp_currency     := i.curr;
        if v_tmp_currency <> p_currency then
            p_return_code := 1; /* currency mismatch */
            RETURN;
        END if;
   end loop;

  IF v_previous_charges IS NULL then
    v_previous_charges := 0;
  end if;

  /* add post-bill adjustments */
     SELECT SUM(nvl(PostbillAdjAmt,0.0)) +
            SUM(nvl(PostbillTaxAdjAmt,0.0)) into v_temp_bal FROM vw_adjustment_summary
     WHERE id_acc = p_id_acc AND id_usage_interval = p_id_interval;

     v_previous_charges := v_previous_charges + nvl(v_temp_bal,0);


  /* step6: get current charges */
  for i in(
  SELECT
   SUM(nvl(au.Amount, 0.0)) +
   /*For implied taxes, tax is already included, so don't add it again*/
                       SUM(CASE WHEN (au.is_implied_tax = 'N') THEN  nvl(au.Tax_Federal,0.0) +
                       nvl(au.Tax_State,0.0) +
                       nvl(au.Tax_County,0.0) +
                       nvl(au.Tax_Local,0.0) +
                       nvl(au.Tax_Other,0.0) else 0 end)  -
            /* Informational taxes don't get added into total */
                       SUM(CASE WHEN (au.tax_informational = 'Y') THEN  nvl(au.Tax_Federal,0.0) +
                       nvl(au.Tax_State,0.0) +
                       nvl(au.Tax_County,0.0) +
                       nvl(au.Tax_Local,0.0) +
                       nvl(au.Tax_Other,0.0) else 0 end) amt,
   au.am_currency curr
  FROM t_acc_usage au
    inner join t_view_hierarchy vh on au.id_view = vh.id_view
    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi
    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data
  WHERE
    vh.id_view = vh.id_view_parent
  AND au.id_acc = p_id_acc
  AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))
  AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
  AND au.id_usage_interval = p_id_interval
  GROUP BY au.am_currency)
  loop
      v_current_charges :=i.amt;
      v_tmp_currency    := i.curr;
      if v_tmp_currency <> p_currency then
        p_return_code := 1; /* currency mismatch */
        RETURN;
      END if;
  end loop;

  IF v_current_charges IS NULL then
    v_current_charges := 0;
  end if;

  /* add pre-bill adjustments */
    SELECT nvl(SUM(PrebillAdjAmt),0) +
           nvl(SUM(PrebillTaxAdjAmt),0) into v_temp_bal FROM vw_adjustment_summary
    WHERE id_acc = p_id_acc AND id_usage_interval = p_id_interval;

    v_current_charges := v_current_charges + nvl(v_temp_bal,0);
    p_balance_forward := p_previous_balance + v_previous_charges;
    p_current_balance := p_balance_forward + v_current_charges;
END;
/

CREATE OR REPLACE PROCEDURE MTSP_INSERTINVOICE_BALANCES(
  p_id_billgroup int,
  p_exclude_billable char, /* '1' to only return non-billable accounts, '0' to return all accounts */
  p_id_run int,
  p_return_code OUT int )
  AS
  v_debug_flag number(1) :=1; /* yes */
  v_SQLError int;
  v_ErrMsg varchar2(200);
  FatalError exception;
  v_dummy_datamart varchar2(10);
  id_sess_min int;
  id_sess_max int;
BEGIN
    delete from tmp_all_accounts;
    delete from tmp_acc_amounts;
    delete from tmp_prev_balance;
    delete from tmp_invoicenumber;
    delete from tmp_adjustments;
    
    /* Get Max and Min id_sess values to be used later on the JOIN */
    select min(id_sess), max(id_sess) into id_sess_min, id_sess_max from t_acc_usage
where id_acc in (select id_acc from t_billgroup_member where id_billgroup = p_id_billgroup)
and id_usage_interval = (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = p_id_billgroup);
    
/*  populate the driver table with account ids  */

begin
  INSERT INTO tmp_all_accounts
     (id_acc,namespace)
SELECT /*DISTINCT*/
bgm.id_acc,
map.nm_space
    FROM t_billgroup_member bgm
    INNER JOIN t_acc_usage au ON au.id_acc = bgm.id_acc
    INNER JOIN t_account_mapper map
    ON map.id_acc = au.id_acc
    INNER JOIN t_namespace ns
    ON ns.nm_space = map.nm_space
    WHERE ns.tx_typ_space = 'system_mps' AND
    bgm.id_billgroup = p_id_billgroup AND
    au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                             WHERE id_billgroup = p_id_billgroup)
  UNION
SELECT /*DISTINCT*/
ads.id_acc,
map.nm_space
    FROM vw_adjustment_summary ads
    INNER JOIN t_billgroup_member bgm ON bgm.id_acc = ads.id_acc
    INNER JOIN t_account_mapper map
    ON map.id_acc = ads.id_acc
    INNER JOIN t_namespace ns
    ON ns.nm_space = map.nm_space
    WHERE ns.tx_typ_space = 'system_mps' AND
    bgm.id_billgroup = p_id_billgroup AND
    ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                             WHERE id_billgroup = p_id_billgroup)
  UNION
  select inv.id_acc, inv.namespace from t_invoice inv
  inner join t_billgroup_member bgm on inv.id_acc = bgm.id_acc
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and bgm.id_billgroup = p_id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt))  <> 0;
exception
when others then
  raise FatalError;
end;

begin
/* Populate with accounts that are non-billable but have payers that are billable.
 in specified billing group */
if (p_exclude_billable = '1')
then
    INSERT INTO tmp_all_accounts
    (id_acc, namespace)
    SELECT /*DISTINCT*/
    pr.id_payee,
    map.nm_space
        FROM t_billgroup_member bgm
        INNER JOIN t_payment_redirection pr ON pr.id_payer = bgm.id_acc
        INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
        INNER JOIN t_account_mapper map ON map.id_acc = au.id_acc
        INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
        WHERE ns.tx_typ_space = 'system_mps' AND
        bgm.id_billgroup = p_id_billgroup AND
        pr.id_payee NOT IN (SELECT id_acc FROM tmp_all_accounts) AND
        au.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                                WHERE id_billgroup = p_id_billgroup)
    UNION
    SELECT /*DISTINCT*/
    ads.id_acc,
    map.nm_space
        FROM vw_adjustment_summary ads
        INNER JOIN t_payment_redirection pr ON pr.id_payee = ads.id_acc
        INNER JOIN t_billgroup_member bgm ON bgm.id_acc = pr.id_payer
        INNER JOIN t_account_mapper map ON map.id_acc = ads.id_acc
        INNER JOIN t_namespace ns ON ns.nm_space = map.nm_space
        WHERE ns.tx_typ_space = 'system_mps' AND
        bgm.id_billgroup = p_id_billgroup AND
        pr.id_payee NOT IN (SELECT id_acc FROM tmp_all_accounts) AND
        ads.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                                WHERE id_billgroup = p_id_billgroup)
    UNION
  select inv.id_acc, inv.namespace from t_invoice inv
  inner join t_payment_redirection pr on pr.id_payee  = inv.id_acc
  inner join t_billgroup_member bgm on pr.id_payer = bgm.id_acc
  inner join t_billgroup bg on bgm.id_billgroup = bg.id_billgroup
  inner join t_usage_interval uii on bg.id_usage_interval = uii.id_interval
  inner join t_namespace ns on inv.namespace = ns.nm_space
  WHERE ns.tx_typ_space = 'system_mps' and pr.id_payee not in (select id_acc from tmp_all_accounts)
      AND bgm.id_billgroup = p_id_billgroup
  group by inv.id_acc, inv.namespace
  having (sum(invoice_amount) + sum(payment_ttl_amt) + sum(postbill_adj_ttl_amt) + sum(ar_adj_ttl_amt))  <> 0;
end if;
exception
when others then
  raise FatalError;
end;

/*  populate tmp_acc_amounts with accounts and their invoice amounts */
IF (v_debug_flag = 1 and p_id_run IS NOT NULL) then
  INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'Invoice-Bal: Begin inserting to the tmp_acc_amounts table', dbo.getutcdate) ;
end if;

SELECT value into v_dummy_datamart FROM t_db_values WHERE parameter = N'DATAMART';

if (v_dummy_datamart = 'FALSE' OR v_dummy_datamart = 'false')
then
    begin
        INSERT INTO tmp_acc_amounts
            (TMP_SEQ,
            namespace,
            id_interval,
            id_acc,
            invoice_currency,
            payment_ttl_amt,
            postbill_adj_ttl_amt,
            ar_adj_ttl_amt,
            previous_balance,
            tax_ttl_amt,
            current_charges,
            id_payer,
            id_payer_interval
        )
        SELECT
        seq_tmp_acc_amounts.NextVal,
        x.namespace,
        x.id_interval,
        x.id_acc,
        x.invoice_currency,
        x.payment_ttl_amt,
        x.postbill_adj_ttl_amt,
        x.ar_adj_ttl_amt,
        x.previous_balance,
        x.tax_ttl_amt,
        x.current_charges,
        x.id_payer,
        x.id_payer_interval
        FROM
    (
            SELECT
            cast(RTRIM(ammps.nm_space) as nvarchar2(40)) namespace,
            au.id_usage_interval id_interval,
            ammps.id_acc,
            avi.c_currency invoice_currency,
            SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE nvl(au.amount,0) END) payment_ttl_amt,
            0 postbill_adj_ttl_amt, /* postbill_adj_ttl_amt */
            SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE nvl(au.amount,0) END) ar_adj_ttl_amt,
            0 previous_balance, /* previous_balance */
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
            (nvl(au.Tax_Federal,0.0)) ELSE 0 END) +
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
            (nvl(au.Tax_State,0.0))ELSE 0 END) +
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
            (nvl(au.Tax_County,0.0))ELSE 0 END) +
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
            (nvl(au.Tax_Local,0.0))ELSE 0 END) +
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN
            (nvl(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,
            SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN
              nvl(au.Amount, 0.0) -
              /*If implied taxes, then taxes are already included, don't add them again */
              ((CASE WHEN (au.is_implied_tax = 'Y') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0) +
                  nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) ELSE 0 END)
              /*If informational taxes, then they shouldn't be in the total */
              + (CASE WHEN (au.tax_informational = 'Y') THEN (nvl(au.Tax_Federal,0.0) + nvl(au.Tax_State,0.0) +
                nvl(au.Tax_County,0.0) + nvl(au.Tax_Local,0.0) + nvl(au.Tax_Other,0.0)) ELSE 0 END))
              ELSE 0 END)
              current_charges,
            CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,
            CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval
        FROM  tmp_all_accounts tmpall
        INNER JOIN t_av_internal avi ON avi.id_acc = tmpall.id_acc
        INNER JOIN t_account_mapper ammps ON ammps.id_acc = tmpall.id_acc
        INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space
            AND ns.tx_typ_space = 'system_mps'
        INNER join t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc
        INNER join t_usage_interval ui ON aui.id_usage_interval = ui.id_interval
        AND ui.id_interval IN (SELECT id_usage_interval
                                                                                                FROM t_billgroup
                                                                                                WHERE id_billgroup = p_id_billgroup)/*= @id_interval*/
        INNER join t_payment_redirection pr ON tmpall.id_acc = pr.id_payee
            AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
        INNER join t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer
        INNER join t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval
                        AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE dbo.addsecond(auipay.dt_effective) END AND uipay.dt_end
        LEFT OUTER JOIN
        (SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc, au1.id_view,
             au1.is_implied_tax, au1.tax_informational
        FROM t_acc_usage au1
        LEFT OUTER JOIN t_pi_template piTemplated2
        ON piTemplated2.id_template=au1.id_pi_template
        LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi
        LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data
        AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')
        WHERE au1.id_sess between id_sess_min and id_sess_max
        AND au1.id_parent_sess is NULL
    AND au1.id_usage_interval IN (SELECT id_usage_interval
                                                                                                    FROM t_billgroup
                                                                                                    WHERE id_billgroup = p_id_billgroup) /*= @id_interval*/
        AND ((au1.id_pi_template is null and au1.id_parent_sess is null) or (au1.id_pi_template is not null and piTemplated2.id_template_parent is null))
        ) au ON
            au.id_acc = tmpall.id_acc
        /*  join with the tables used for calculating the sums */
        LEFT OUTER JOIN t_view_hierarchy vh
            ON au.id_view = vh.id_view
            AND vh.id_view = vh.id_view_parent
        LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess and au.id_usage_interval=pvar.id_usage_interval
        LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess and au.id_usage_interval=pvpay.id_usage_interval
        /*  non-join conditions */
        WHERE
        (p_exclude_billable = '0' OR avi.c_billable = '0')
        GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable) x;
    end;
else
begin
/* else datamarts are being used. join against t_mv_payer_interval */
      if (table_exists('t_mv_payer_interval')) then
         execute immediate ('INSERT INTO tmp_acc_amounts
                     (tmp_seq, namespace, id_interval, id_acc,
                      invoice_currency, payment_ttl_amt,
                      postbill_adj_ttl_amt, ar_adj_ttl_amt, previous_balance,
                      tax_ttl_amt, current_charges, id_payer,
                      id_payer_interval)
            SELECT seq_tmp_acc_amounts.NEXTVAL, x.namespace, x.id_interval,
                   x.id_acc, x.invoice_currency, x.payment_ttl_amt,
                   x.postbill_adj_ttl_amt, x.ar_adj_ttl_amt,
                   x.previous_balance, x.tax_ttl_amt, x.current_charges,
                   x.id_payer, x.id_payer_interval
              FROM (SELECT   CAST
                                (RTRIM (ammps.nm_space) AS NVARCHAR2 (40)
                                ) namespace,
                             dm.id_usage_interval id_interval, tmpall.id_acc,
                             avi.c_currency invoice_currency,
                             SUM
                                (CASE
                                    WHEN ed.nm_enum_data =
                                                       ''metratech.com/Payment''
                                       THEN NVL (dm.TotalAmount, 0)
                                    ELSE 0
                                 END
                                ) payment_ttl_amt,
                             0 postbill_adj_ttl_amt,
                             SUM
                                (CASE
                                    WHEN ed.nm_enum_data =
                                                  ''metratech.com/ARAdjustment''
                                       THEN NVL (dm.TotalAmount, 0)
                                    ELSE 0
                                 END
                                ) ar_adj_ttl_amt,
                             0 previous_balance,
                             SUM
                                (CASE
                                    WHEN (    ed.nm_enum_data <>
                                                       ''metratech.com/Payment''
                                          AND ed.nm_enum_data <>
                                                  ''metratech.com/ARAdjustment''
                                         )
                                       THEN (NVL (dm.TotalTax,
                                                  0.0
                                                 )
                                            )
                                    ELSE 0
                                 END
                                ) tax_ttl_amt,
                             SUM
                                (CASE
                                    WHEN (    ed.nm_enum_data <>
                                                       ''metratech.com/Payment''
                                          AND ed.nm_enum_data <>
                                                  ''metratech.com/ARAdjustment''
                                         )
                                       THEN (
                                       NVL(dm.TotalAmount, 0.0) - NVL(dm.TotalImpliedTax, 0.0) - NVL(dm.TotalInformationalTax, 0.0) + NVL(dm.TotalImplInfTax, 0.0)
                                            )
                                    ELSE 0
                                 END
                                ) current_charges,
                             CASE
                                WHEN avi.c_billable = ''0''
                                   THEN pr.id_payer
                                ELSE tmpall.id_acc
                             END id_payer,
                             CASE
                                WHEN avi.c_billable = ''0''
                                   THEN auipay.id_usage_interval
                                ELSE dm.id_usage_interval
                             END id_payer_interval
                        FROM tmp_all_accounts tmpall INNER JOIN t_av_internal avi ON avi.id_acc =
                                                                                       tmpall.id_acc
                             INNER JOIN t_account_mapper ammps ON ammps.id_acc =
                                                                    tmpall.id_acc
                             INNER JOIN t_namespace ns ON ns.nm_space =
                                                                ammps.nm_space
                                                     AND ns.tx_typ_space =
                                                                  ''system_mps''
                             INNER JOIN t_acc_usage_interval aui ON aui.id_acc =
                                                                      tmpall.id_acc
                             INNER JOIN t_usage_interval ui ON aui.id_usage_interval =
                                                                 ui.id_interval
                                                          AND ui.id_interval IN (
                                                                 SELECT id_usage_interval
                                                                   FROM t_billgroup
                                                                  WHERE id_billgroup = ' || to_char(p_id_billgroup) || ')
                             INNER JOIN t_payment_redirection pr ON tmpall.id_acc =
                                                                      pr.id_payee
                                                               AND ui.dt_end
                                                                      BETWEEN pr.vt_start
                                                                          AND pr.vt_end
                             INNER JOIN t_acc_usage_interval auipay ON auipay.id_acc =
                                                                         pr.id_payer
                             INNER JOIN t_usage_interval uipay ON auipay.id_usage_interval =
                                                                    uipay.id_interval
                                                             AND ui.dt_end
                                                                    BETWEEN CASE
                                                                    WHEN auipay.dt_effective IS NULL
                                                                       THEN uipay.dt_start
                                                                    ELSE dbo.addsecond
                                                                           (auipay.dt_effective
                                                                           )
                                                                 END
                                                                        AND uipay.dt_end
                             LEFT OUTER JOIN t_mv_payer_interval dm
                                             ON dm.id_acc = tmpall.id_acc
                                             AND dm.id_usage_interval IN (SELECT id_usage_interval
                                                                          FROM t_billgroup
                                                                          WHERE id_billgroup =
                                                                          ' || to_char(p_id_billgroup) || ') /*= @id_interval*/
                             LEFT OUTER JOIN t_enum_data ed ON dm.id_view =
                                                                 ed.id_enum_data /*  non-join conditions */
                        WHERE ('|| p_exclude_billable ||' = ''0'' OR avi.c_billable = ''0'')
                    GROUP BY ammps.nm_space,
                             tmpall.id_acc,
                             dm.id_usage_interval,
                             avi.c_currency,
                             pr.id_payer,
                             auipay.id_usage_interval,
                             avi.c_billable) x');
      END if;
    end;
end if;

/* populate tmp_adjustments with postbill and prebill adjustments */
begin

/*
  FULL OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc

  Here we're doing a union of two outer joins because FULL outer join seems
  to create and Oracle carsh.
 */

  INSERT INTO tmp_adjustments
   ( id_acc,
     PrebillAdjAmt,
     PrebillTaxAdjAmt,
     PostbillAdjAmt,
     PostbillTaxAdjAmt
   )
  select nvl(adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
         nvl(PrebillAdjAmt, 0) PrebillAdjAmt,
         nvl(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
         nvl(PostbillAdjAmt, 0) PostbillAdjAmt,
         nvl(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  LEFT OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = p_id_billgroup and
     adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                                    WHERE id_billgroup = p_id_billgroup)
UNION
  select nvl(adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
         nvl(PrebillAdjAmt, 0) PrebillAdjAmt,
         nvl(PrebillTaxAdjAmt, 0) PrebillTaxAdjAmt,
         nvl(PostbillAdjAmt, 0) PostbillAdjAmt,
         nvl(PostbillTaxAdjAmt, 0) PostbillTaxAdjAmt
  from vw_adjustment_summary adjtrx
  INNER JOIN t_billgroup_member bgm ON bgm.id_acc = adjtrx.id_acc
  RIGHT OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc
  WHERE bgm.id_billgroup = p_id_billgroup and
     adjtrx.id_usage_interval IN (SELECT id_usage_interval FROM t_billgroup
                                    WHERE id_billgroup = p_id_billgroup);

exception
when others then
  raise FatalError;
end;

/* populate tmp_prev_balance with the previous balance */
begin
  INSERT INTO tmp_prev_balance
    (id_acc,
    previous_balance)
  SELECT id_acc, CAST(SUBSTR(comp,CASE WHEN INSTR(comp,'-') = 0 THEN 10 ELSE INSTR(comp,'-') END,28) as NUMBER(22,10)) previous_balance
  FROM  (SELECT inv.id_acc,
  nvl(MAX(TO_CHAR(ui.dt_end,'YYYYMMDD')||
        RPAD('0',20-LENGTH(inv.current_balance)) ||
        TO_CHAR(inv.current_balance)),'00000000000') comp
    FROM t_invoice inv
    INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval
    INNER JOIN tmp_all_accounts ON inv.id_acc = tmp_all_accounts.id_acc
    GROUP BY inv.id_acc) maxdtend;
exception
when others then
  raise FatalError;
end;

IF (v_debug_flag = 1  and p_id_run IS NOT NULL) then
  INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'Invoice-Bal: Completed successfully', dbo.getutcdate) ;
end if;

p_return_code := 0;
RETURN;
exception
when FatalError then
  IF v_ErrMsg IS NULL then
    v_ErrMsg := 'Invoice-Bal: Stored procedure failed';
  END IF;
  IF (v_debug_flag = 1  and p_id_run IS NOT NULL) then
    INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
  end if;
  p_return_code := -1;
  RETURN;
END;
/

CREATE OR REPLACE PROCEDURE export_getqueuedreportinfo (
        p_id_work_queue IN CHAR DEFAULT NULL,
        p_system_datetime IN DATE DEFAULT NULL
      )
AS
    v_rawworkqid   RAW (16) := NULL;
    v_dt_end       DATE := NULL;
BEGIN
    v_rawworkqid := HEXTORAW (TRANSLATE (p_id_work_queue, '0{-}', '0'));
    
    execute immediate 'TRUNCATE TABLE tt_queuedreportinfo';
    
    INSERT INTO tt_queuedreportinfo
        (SELECT   c_rep_title,
                  c_rep_type,
                  c_rep_def_source,
                  c_rep_query_tag,
                  LOWER (c_rep_output_type) c_rep_output_type,
                  c_rep_distrib_type,
                  c_rep_destn,
                  NVL (c_destn_direct, 0) c_destn_direct,
                  c_destn_access_user,
                  c_destn_access_pwd,
                  c_generate_control_file,
                  c_control_file_delivery_locati,
                  c_exec_type,
                  c_compressreport,
                  NVL (c_compressthreshold, -1) c_compressthreshold,
                  NVL (c_ds_id, 0) c_ds_id,
                  c_eop_step_instance_name,
                  dt_last_run,
                  dt_next_run,
                  c_output_execute_params_info,
                  c_use_quoted_identifiers,
                  id_rep_instance_id,
                  id_schedule,
                  c_sch_type,
                  dt_sched_run,
                  REPLACE (c_param_name_values, '%', '^') c_param_name_values,
                  c_output_file_name,
                  id_work_queue,
                  dt_queued,
                  TO_CHAR (NVL (dt_next_run, p_system_datetime) - 1, 'MM/DD/YYYY')
                      control_file_data_date
           FROM   t_export_workqueue a
          WHERE   id_work_queue = v_rawworkqid);
          
    BEGIN
        SELECT   ui.dt_end
          INTO   v_dt_end
          FROM       tt_queuedreportinfo qri
                 LEFT OUTER JOIN t_usage_interval ui
                 ON (CAST (REGEXP_SUBSTR(regexp_replace(qri.c_param_name_values,
             '.*?\^\^ID_INTERVAL\^\^\=(\d{10})(,?.*?)',
          '\1'), '\d{10}', 1) AS number) = ui.id_interval)
         WHERE   id_work_queue IN
                         (SELECT   tt_queuedreportinfo.id_work_queue
                            FROM   tt_queuedreportinfo
                           WHERE   tt_queuedreportinfo.c_exec_type = 'eop'
                                   AND tt_queuedreportinfo.c_param_name_values LIKE
                                          '%ID_INTERVAL%')
                 AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            UPDATE   tt_queuedreportinfo
               SET   c_param_name_values =
                         REPLACE (c_param_name_values, '^', '%');

            RETURN;
    END;

    UPDATE   tt_queuedreportinfo
       SET   control_file_data_date =
                 TO_CHAR (NVL (v_dt_end, p_system_datetime) + 1, 'MM/DD/YYYY');

    UPDATE   tt_queuedreportinfo
       SET   c_param_name_values = REPLACE (c_param_name_values, '^', '%');
END;
/

CREATE OR REPLACE 
PROCEDURE addnewaccount  (
   p_id_acc_ext                 IN       VARCHAR2,
   p_acc_state                  IN       VARCHAR2,
   p_acc_status_ext             IN       INT,
   p_acc_vtstart                IN       DATE,
   p_acc_vtend                  IN       DATE,
   p_nm_login                   IN       NVARCHAR2,
   p_nm_space                   IN       NVARCHAR2,
   p_tx_password                IN       NVARCHAR2,
   p_auth_type                  IN       INT,
   p_langcode                   IN       VARCHAR2,
   p_profile_timezone           IN       INT,
   p_id_cycle_type              IN       INT,
   p_day_of_month               IN       INT,
   p_day_of_week                IN       INT,
   p_first_day_of_month         IN       INT,
   p_second_day_of_month        IN       INT,
   p_start_day                  IN       INT,
   p_start_month                IN       INT,
   p_start_year                 IN       INT,
   p_billable                   IN       VARCHAR2,
   p_id_payer                   IN       INT,
   p_payer_startdate            IN       DATE,
   p_payer_enddate              IN       DATE,
   p_payer_login                IN       NVARCHAR2,
   p_payer_namespace            IN       NVARCHAR2,
   p_id_ancestor                IN       INT,
   p_hierarchy_start            IN       DATE,
   p_hierarchy_end              IN       DATE,
   p_ancestor_name              IN       NVARCHAR2,
   p_ancestor_namespace         IN       NVARCHAR2,
   p_acc_type                   IN       VARCHAR2,
   p_apply_default_policy       IN       VARCHAR2,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2, /*  pass the currency through to CreatePaymentRecord */ /*  stored procedure only to validate it against the payer */ /*  We have to do it, because the t_av_internal record */ /* is not created yet */
   p_account_currency                    NVARCHAR2,
   p_profile_id                          INT,
   p_login_app                           VARCHAR2,
   accountid                             INTEGER,
   status                       OUT      INTEGER,
   p_hierarchy_path             OUT      VARCHAR2,
   p_currency                   OUT      NVARCHAR2,
   p_id_ancestor_out            OUT      INT,
   p_corporate_account_id       OUT      INT,
   p_ancestor_type_out          OUT      VARCHAR2
)
AS
   existing_account     INTEGER;
   payerid              INT;
   intervalid           INTEGER;
   intervalstart        DATE;
   intervalend          DATE;
   usagecycleid         INTEGER;
   acc_startdate        DATE;
   acc_enddate          DATE;
   payer_startdate      DATE;
   payer_enddate        DATE;
   ancestor_startdate   DATE;
   ancestor_enddate     DATE;
   create_dt_end        DATE;
   ancestorid           INTEGER;
   siteid               INTEGER;
   foldername           VARCHAR2 (255);
   isnotsubscriber      INTEGER;
   payerbillable        VARCHAR2 (1);
   authancestor         INTEGER;
   varmaxdatetime       DATE;
   stoo_error           INTEGER        := 0;
   stoo_errmsg          VARCHAR2 (255);
   temp_count           INT;
   dummycursor          sys_refcursor;
   id_type              INT;
   acc_type_out         VARCHAR2 (40);
   p_count              INTEGER;
   l_polID              INTEGER;
   l_id_parent_cap          INTEGER;
   l_id_atomic_cap          INTEGER;
   templateId           INTEGER;
   templateOwner        INTEGER;
   sessionId            INTEGER;
   templateCount        INTEGER;
BEGIN
   p_ancestor_type_out := 'Err';
/* step : validate that the account does not already exist.  Note    that this check is performed by checking the t_account_mapper table.    However, we don't check the account state so the new account could
conflict with an account that is an archived state.  You would need
to purge the archived account before the new account could be created.
*/
   varmaxdatetime := dbo.mtmaxdate ();
   existing_account := dbo.lookupaccount (p_nm_login, p_nm_space);

   IF existing_account <> -1
   THEN
      /* ACCOUNTMAPPER_ERR_ALREADY_EXISTS*/
      status := -501284862;
      RETURN;
   END IF;

   /* step : check account creation business rules*/
   IF (LOWER (p_nm_login) NOT IN ('rm', 'mps_folder'))
   THEN
      checkaccountcreationbusinessru (p_nm_space,
                                      p_acc_type,
                                      p_id_ancestor,
                                      status
                                     );

      IF (status <> 1)
      THEN
         RETURN;
      END IF;
   END IF;

   /* step : populate the account start dates if the values were
   not passed into the sproc
   */
   SELECT CASE
             WHEN p_acc_vtstart IS NULL
                THEN dbo.mtstartofday (p_systemdate)
             ELSE dbo.mtstartofday (p_acc_vtstart)
          END,
          CASE
             WHEN p_acc_vtend IS NULL
                THEN dbo.mtmaxdate ()
             ELSE dbo.mtendofday (p_acc_vtend)
          END
     INTO acc_startdate,
          acc_enddate
     FROM DUAL;

   /* step : get the account ID and increment counter
   select id_current
     into accountid
     from t_current_id
    where nm_current = 'id_acc';

   update t_current_id
      set id_current = id_current + 1
    where nm_current = 'id_acc'; */

   /* step: populate t_account*/
   SELECT id_type
     INTO id_type
     FROM t_account_type
    WHERE LOWER (NAME) = LOWER (p_acc_type);

   IF p_id_acc_ext IS NULL
   THEN
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, SYS_GUID (), acc_startdate, id_type
                  );
   ELSE
      INSERT INTO t_account
                  (id_acc, id_acc_ext, dt_crt, id_type
                  )
           VALUES (accountid, p_id_acc_ext, acc_startdate, id_type
                  );
   END IF;

   /* step : initial account state*/
   INSERT INTO t_account_state
               (id_acc, status, vt_start, vt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate
               );

   INSERT INTO t_account_state_history
               (id_acc, status, vt_start, vt_end,
                tt_start, tt_end
               )
        VALUES (accountid, p_acc_state, acc_startdate, acc_enddate,
                p_systemdate, varmaxdatetime
               );

   /* step : login and namespace information*/
   INSERT INTO t_account_mapper
               (nm_login, nm_space, id_acc
               )
        VALUES (p_nm_login, LOWER (p_nm_space), accountid
               );

   /* step : user credentials*/
   /* check if authentification is MetraNetInternal then add user credentials */
   IF (COALESCE(p_auth_type, 1) = 1)
   THEN
       INSERT INTO t_user_credentials
                   (nm_login, nm_space, tx_password
                   )
            VALUES (p_nm_login, LOWER (p_nm_space), p_tx_password
                   );
   END IF;

   /* step : t_profile. This looks like it is only for timezone information */
   INSERT INTO t_profile
               (id_profile, nm_tag, val_tag, tx_desc
               )
        VALUES (p_profile_id, 'timeZoneID', p_profile_timezone, 'System'
               );

   /* step : site user information*/
   getlocalizedsiteinfo (p_nm_space, p_langcode, siteid);

   INSERT INTO t_site_user
               (nm_login, id_site, id_profile
               )
        VALUES (p_nm_login, siteid, p_profile_id
               );

   /* associates the account with the Usage Server */

   /* step : determines the usage cycle ID from the passed in date properties*/
   BEGIN
      FOR i IN (SELECT id_usage_cycle
                  FROM t_usage_cycle CYCLE
                 WHERE CYCLE.id_cycle_type = p_id_cycle_type
                   AND (   p_day_of_month = CYCLE.day_of_month
                        OR p_day_of_month IS NULL
                       )
                   AND (   p_day_of_week = CYCLE.day_of_week
                        OR p_day_of_week IS NULL
                       )
                   AND (   p_first_day_of_month = CYCLE.first_day_of_month
                        OR p_first_day_of_month IS NULL
                       )
                   AND (   p_second_day_of_month = CYCLE.second_day_of_month
                        OR p_second_day_of_month IS NULL
                       )
                   AND (p_start_day = CYCLE.start_day OR p_start_day IS NULL
                       )
                   AND (   p_start_month = CYCLE.start_month
                        OR p_start_month IS NULL
                       )
                   AND (p_start_year = CYCLE.start_year
                        OR p_start_year IS NULL
                       ))
      LOOP
         usagecycleid := i.id_usage_cycle;
      END LOOP;
   END;

   /* step : add the account to usage cycle mapping */
   INSERT INTO t_acc_usage_cycle
               (id_acc, id_usage_cycle
               )
        VALUES (accountid, usagecycleid
               );

   /* step : creates only needed intervals and mappings for this account only.
    other accounts affected by any new intervals (same cycle) will
    be associated later in the day via a usm -create. */
   /* Defines the date range that an interval must fall into to
     be considered 'active'. */
   SELECT (p_systemdate + n_adv_interval_creation) INTO create_dt_end FROM t_usage_server;

   IF (
     /* Exclude archived accounts. */
     p_acc_state <> 'AR'
     /* The account has already started or is about to start. */
     AND acc_startdate < create_dt_end
     /* The account has not yet ended. */
     AND acc_enddate >= p_systemdate)
   THEN
     INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
     SELECT ref.id_interval,ref.id_cycle,ref.dt_start,ref.dt_end, 'O'
     FROM
     t_pc_interval ref
     WHERE
     /* Only add intervals that don't exist */
     NOT EXISTS (
       SELECT 1 FROM t_usage_interval ui
       WHERE ref.id_interval = ui.id_interval)
     AND
     ref.id_cycle = usagecycleid AND
     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
     (ref.dt_end >= acc_startdate AND
      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END);

     INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
     SELECT accountid, ref.id_interval, ref.tx_interval_status, NULL
     FROM t_usage_interval ref
     WHERE
     ref.id_usage_cycle = usagecycleid AND
     /* Reference interval must at least partially overlap the [minstart, maxend] period. */
     (ref.dt_end >= acc_startdate AND
      ref.dt_start <= CASE WHEN acc_enddate < create_dt_end THEN acc_enddate ELSE create_dt_end END)
     /* Only add mappings for non-blocked intervals */
     AND ref.tx_interval_status <> 'B';
   END IF;

   /* step : Non-billable accounts must have a payment redirection record*/
   IF (    p_billable = 'N'
       AND (    p_id_payer IS NULL
            AND (    p_id_payer IS NULL
                 AND p_payer_login IS NULL
                 AND p_payer_namespace IS NULL
                )
           )
      )
   THEN
      /* MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER*/
      status := -486604768;
      RETURN;
   END IF;

   SELECT
          /* default the payer start date to the start of the account  */
          CASE
             WHEN p_payer_startdate IS NULL
                THEN acc_startdate
             ELSE dbo.mtstartofday (p_payer_startdate)
          END,
          /* default the payer end date to the end of the account if NULL*/
          CASE
             WHEN p_payer_enddate IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday (p_payer_enddate)
          END,
          /* step : default the hierarchy start date to the account start date */
          CASE
             WHEN p_hierarchy_start IS NULL
                THEN acc_startdate
             ELSE p_hierarchy_start
          END,
          /* step : default the hierarchy end date to the account end date*/
          CASE
             WHEN p_hierarchy_end IS NULL
                THEN acc_enddate
             ELSE dbo.mtendofday(p_hierarchy_end)
          END,
          /* step : resolve the ancestor ID if necessary*/
          CASE
             WHEN p_ancestor_name IS NOT NULL
             AND p_ancestor_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_ancestor_name, p_ancestor_namespace)
             ELSE
                 /* if the ancestor ID iis NULL then default to the root*/
          CASE
             WHEN p_id_ancestor IS NULL
                THEN 1
             ELSE p_id_ancestor
          END
          END,
          /* step : resolve the payer account if necessary*/
          CASE
             WHEN p_payer_login IS NOT NULL AND p_payer_namespace IS NOT NULL
                THEN dbo.lookupaccount (p_payer_login, p_payer_namespace)
             ELSE CASE
             WHEN p_id_payer IS NULL
                THEN accountid
             ELSE p_id_payer
          END
          END
     INTO payer_startdate,
          payer_enddate,
          ancestor_startdate,
          ancestor_enddate,
          ancestorid,
          payerid
     FROM DUAL;

   /* -- Fix CORE-762: Check that payerid exists */
   begin
     select count(*) into p_count
     from t_account
     where id_acc = payerid;
     if p_count = 0 then /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
       status := -486604792;
       return;
     end if;
   end;

   IF ancestorid = -1
   THEN
      /* MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT*/
      status := -486604791;
      RETURN;
   ELSE
      p_id_ancestor_out := ancestorid;
   END IF;

   IF (UPPER (p_acc_type) = 'SYSTEMACCOUNT')
   THEN
      /* anyone who is not a system account is a subscriber */
      isnotsubscriber := 1;
   END IF;

   /* step: we trust AddAccToHIerarchy to set the status
   to 1 in case of success*/
   addacctohierarchy (ancestorid,
                      accountid,
                      ancestor_startdate,
                      ancestor_enddate,
                      acc_startdate,
                      p_ancestor_type_out,
                      acc_type_out,
                      status
                     );

   IF status <> 1
   THEN
      RETURN;
   END IF;

   /* step: populate t_dm_account and t_dm_account_ancestor table */
   INSERT INTO t_dm_account
               (id_dm_acc, id_acc, vt_start, vt_end)
      SELECT seq_t_dm_account.NEXTVAL, id_descendent, vt_start, vt_end
        FROM t_account_ancestor
       WHERE id_ancestor = 1 AND id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT dm2.id_dm_acc, dm1.id_dm_acc, aa1.num_generations
        FROM t_account_ancestor aa1 INNER JOIN t_dm_account dm1 ON aa1.id_descendent =
                                                                     dm1.id_acc
                                                              AND aa1.vt_start <=
                                                                     dm1.vt_end
                                                              AND dm1.vt_start <=
                                                                     aa1.vt_end
             INNER JOIN t_dm_account dm2 ON aa1.id_ancestor = dm2.id_acc
                                       AND aa1.vt_start <= dm2.vt_end
                                       AND dm2.vt_start <= aa1.vt_end
       WHERE dm1.id_acc <> dm2.id_acc
         AND dm1.vt_start >= dm2.vt_start
         AND dm1.vt_end <= dm2.vt_end
         AND aa1.id_descendent = accountid;

   INSERT INTO t_dm_account_ancestor
               (id_dm_ancestor, id_dm_descendent, num_generations)
      SELECT id_dm_acc, id_dm_acc, 0
        FROM t_dm_account
       WHERE id_acc = accountid;

   /* step: pass in the current account's billable flag when creating the    payment redirection record IF the account is paying for itself */
   SELECT CASE
             WHEN payerid = accountid
                THEN p_billable
             ELSE NULL
          END
     INTO payerbillable
     FROM DUAL;

   createpaymentrecord (payerid,
                        accountid,
                        payer_startdate,
                        payer_enddate,
                        payerbillable,
                        p_systemdate,
                        'N',
                        p_enforce_same_corporation,
                        p_account_currency,
                        status
                       );

   IF (status <> 1)
   THEN
      RETURN;
   END IF;

      BEGIN
      SELECT tx_path
        INTO p_hierarchy_path
        FROM t_account_ancestor
       WHERE id_descendent = accountid
         AND id_ancestor = 1
         AND ancestor_startdate BETWEEN vt_start AND vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   /* if "Apply Default Policy" flag is set, then figure out    "ancestor" id based on account type in case the account is not    a subscriber*/

    /*BP: 10/5 Make sure that t_principal_policy record is always there, otherwise ApplyRoleMembership will break*/
    Sp_Insertpolicy( 'id_acc', accountID,'A', l_polID );

    /* 2/11/2010: TRW - We are now granting the "Manage Account Hierarchies" capability to all accounts
        upon their creation.  They are being granted read/write access to their own account only (not to
        sub accounts).  This is being done to facilitate access to their own information via the MetraNet
        ActivityServices web services, which are now checking capabilities a lot more */

    /* Insert "Manage Account Hierarchies" parent capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
    'ABCD',
        null,
        l_polID,
        id_cap_type
    from
        t_composite_capability_type
    where
        tx_name = 'Manage Account Hierarchies';

    select seq_t_cap_instance.CURRVAL into l_id_parent_cap from dual;

    /* Insert MTPathCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTPATHCAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_path_capability account's path */
    insert into t_path_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    values( l_id_atomic_cap, null, null, p_hierarchy_path || '/');

    /* Insert MTEnumCapability atomic capability */
    insert into t_capability_instance(id_cap_instance, tx_guid, id_parent_cap_instance, id_policy, id_cap_type)
    select
        seq_t_cap_instance.NextVal,
        'ABCD',
        l_id_parent_cap,
        l_polID,
        id_cap_type
    from
        t_atomic_capability_type
    where
        upper(tx_name) = 'MTENUMTYPECAPABILITY';

    select seq_t_cap_instance.CURRVAL into l_id_atomic_cap from dual;

    /* Insert into t_enum_capability to grant Write access */
    insert into t_enum_capability(id_cap_instance, tx_param_name, tx_op, param_value)
    select
        l_id_atomic_cap,
        null,
        '=',
        id_enum_data
    from
        t_enum_data
    where
        upper(nm_enum_data) = 'GLOBAL/ACCESSLEVEL/WRITE';

   IF (   UPPER (p_apply_default_policy) = 'Y'
       OR UPPER (p_apply_default_policy) = 'T'
       OR UPPER (p_apply_default_policy) = '1'
      )
   THEN
      authancestor := ancestorid;

      IF isnotsubscriber > 0
      THEN
         foldername :=
            CASE
               WHEN UPPER (p_login_app) = 'CSR'
                  THEN 'csr_folder'
               WHEN UPPER (p_login_app) = 'MOM'
                  THEN 'mom_folder'
               WHEN UPPER (p_login_app) = 'MCM'
                  THEN 'mcm_folder'
               WHEN UPPER (p_login_app) = 'MPS'
                  THEN 'mps_folder'
            END;

         BEGIN
            authancestor := NULL;

            SELECT id_acc
              INTO authancestor
              FROM t_account_mapper
             WHERE UPPER (nm_login) = UPPER (foldername)
               AND UPPER (nm_space) = 'AUTH'; /* record  for ancestor is not on t_account_mapper just return OK*/
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               status := 1;
         END;
      END IF; /* apply default security policy; only do it if ancestor was found*/

      IF authancestor > 1
      THEN
         clonesecuritypolicy (authancestor, accountid, 'D', 'A');
      END IF;
   END IF;

    /* resolve accounts' corporation.
    select ancestor whose ancestor is of a type that
    has b_iscorporate set to true */

   BEGIN
      SELECT ancestor.id_ancestor
        INTO p_corporate_account_id
        FROM t_account_ancestor ancestor INNER JOIN t_account acc ON acc.id_acc =
                                                                       ancestor.id_ancestor
             INNER JOIN t_account_type atype ON acc.id_type = atype.id_type
       WHERE ancestor.id_descendent = accountid
         AND atype.b_iscorporate = '1'
         AND acc_startdate BETWEEN ancestor.vt_start AND ancestor.vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF (p_corporate_account_id IS NULL)
   THEN
      p_corporate_account_id := accountid;
   END IF;

   IF ancestorid <> 1
   THEN
      BEGIN
         SELECT c_currency
           INTO p_currency
           FROM t_av_internal
          WHERE id_acc = ancestorid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /* if cross corp business rule is enforced,
      verify that currencis match */
      IF (    p_enforce_same_corporation = '1'
          AND (LOWER (p_currency) <> LOWER (p_account_currency))
         )
      THEN
         /* MT_CURRENCY_MISMATCH*/
         status := -486604737;
         RETURN;
      END IF;
   END IF;

   /* done*/
   status := 1;
END;
/

CREATE Procedure GetAccByType
(acc_type varchar2, p_result out sys_refcursor)
As
Begin
            
open p_result for
SELECT map.NM_LOGIN as Loggin,
    map.NM_SPACE as Mn_Space,
    tp.name as Acc_Type
FROM T_ACCOUNT_MAPPER map
INNER JOIN T_ACCOUNT acc
    ON acc.id_acc= map.id_acc
INNER JOIN T_ACCOUNT_TYPE tp
    ON acc.id_type= tp.id_type
WHERE tp.name = acc_type;
                 
END GetAccByType;
/

CREATE TRIGGER TR_T_PT_UDRCTIEREDIDSC AFTER INSERT OR UPDATE ON t_pt_udrctiered FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_udrctiered table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_UDRCTAPEREDIDSC AFTER INSERT OR UPDATE ON t_pt_udrctapered FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_udrctapered table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_TIEREDUNITRATESPTIDSC AFTER INSERT OR UPDATE ON t_pt_tieredunitratespt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_tieredunitratespt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_TIEREDEVENTRATESPTIDSC AFTER INSERT OR UPDATE ON t_pt_tieredeventratespt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_tieredeventratespt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_PERCENTDISCOUNT_NOIDSC AFTER INSERT OR UPDATE ON t_pt_percentdiscount_nocond FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_percentdiscount_nocond table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_PERCENTDISCOUNTIDSC AFTER INSERT OR UPDATE ON t_pt_percentdiscount FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_percentdiscount table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_NONRECURRINGCHARGEIDSC AFTER INSERT OR UPDATE ON t_pt_nonrecurringcharge FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_nonrecurringcharge table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_INCREMENTALDISCOUNIDSC AFTER INSERT OR UPDATE ON t_pt_incrementaldiscountpt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_incrementaldiscountpt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_FREEUSAGEPTIDSC AFTER INSERT OR UPDATE ON t_pt_freeusagept FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_freeusagept table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_FLATRECURRINGCHARGIDSC AFTER INSERT OR UPDATE ON t_pt_flatrecurringcharge FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_flatrecurringcharge table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_FLATDISCOUNT_NOCONIDSC AFTER INSERT OR UPDATE ON t_pt_flatdiscount_nocond FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_flatdiscount_nocond table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_FLATDISCOUNTIDSC AFTER INSERT OR UPDATE ON t_pt_flatdiscount FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_flatdiscount table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_CURRENCYEXCHANGERAIDSC AFTER INSERT OR UPDATE ON t_pt_currencyexchangerates FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_currencyexchangerates table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_COMMITMENTPTIDSC AFTER INSERT OR UPDATE ON t_pt_commitmentpt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_commitmentpt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_CALENDARIDSC AFTER INSERT OR UPDATE ON t_pt_calendar FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_calendar table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_BULKUNITRATESPTIDSC AFTER INSERT OR UPDATE ON t_pt_bulkunitratespt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_bulkunitratespt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_BULKEVENTRATESPTIDSC AFTER INSERT OR UPDATE ON t_pt_bulkeventratespt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_bulkeventratespt table');
    END IF;
        
END;
/

CREATE TRIGGER TR_T_PT_BULKDISCOUNTPTIDSC AFTER INSERT OR UPDATE ON t_pt_bulkdiscountpt FOR EACH ROW
DECLARE
    record_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   record_count
    FROM (
        SELECT id_sched FROM t_rsched WHERE id_sched = :NEW.id_sched
        UNION ALL
        SELECT id_sched FROM t_rsched_pub WHERE id_sched = :NEW.id_sched
    );

    IF (record_count = 0) THEN
        RAISE_APPLICATION_ERROR(-20101, 'No parent key found for record in t_pt_bulkdiscountpt table');
    END IF;
        
END;
/

CREATE TRIGGER trg_gsubmember_icb_rates
AFTER INSERT OR UPDATE ON t_gsubmember
FOR EACH ROW
BEGIN
    mt_rate_pkg.recursive_inherit_sub(
        v_id_audit => NULL,
        v_id_acc   => :NEW.id_acc,
        v_id_sub   => NULL,
        v_id_group => :NEW.id_group
    );
END;
/

DECLARE
    obj_count number;
BEGIN
    SELECT COUNT(1)
    INTO   obj_count
    FROM   user_objects
    WHERE object_name = 'QUOTEHEADER_QUOTEID_INCREMENT' AND object_type = 'TRIGGER';

    IF (obj_count > 0) THEN
        EXECUTE IMMEDIATE 'DROP TRIGGER quoteheader_quoteid_increment';
    END IF;
END;
/

CREATE OR REPLACE
PROCEDURE UpdatePrivateTempates
(
  id_template int
)    
AS
  id_account int;
  id_parent_account_template int;
  id_acc_type int;
BEGIN
    SELECT id_acc_type, id_folder
    INTO UpdatePrivateTempates.id_acc_type, UpdatePrivateTempates.id_account
    FROM t_acc_template WHERE id_acc_template = id_template;
  
  /*delete old values for properties of private templates of current account and child accounts*/
  DELETE
    FROM t_acc_template_props tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);
  
  /*delete old values for subscriptions of private templates of current account and child accounts*/
  DELETE
    FROM t_acc_template_subs tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);
  
  /*insert new values for private template from public template for all sub-tree of current account.*/
  INSERT INTO t_acc_template_props
          (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
   SELECT seq_t_acc_template_props.NextVal, id_acc_template, nm_prop_class, nm_prop, nm_value
     FROM t_acc_template_props_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);

  INSERT INTO t_acc_template_subs
          (id_po, id_group, id_acc_template, vt_start, vt_end)
   SELECT id_po, id_group, id_acc_template, vt_start, vt_end
     FROM t_acc_template_subs_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);

/*  INSERT INTO t_acc_template_props 
          (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
        SELECT
          seq_t_acc_template_props.NextVal, id_acc_template, nm_prop_class, nm_prop, nm_value
        FROM 
          t_acc_template_props_pub
        WHERE
          id_acc_template IN
        (SELECT t.id_acc_template
           FROM vw_account_ancestor aa
                LEFT JOIN t_acc_template t on aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
           START WITH aa.id_ancestor = id_account
           CONNECT BY PRIOR aa.id_descendent = aa.id_ancestor
         UNION ALL
         SELECT id_template FROM DUAL);*/

    /*insert private template of an account's parent*/
    INSERT INTO t_acc_template_props
                (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT seq_t_acc_template_props.NextVal, UpdatePrivateTempates.id_template, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp
           JOIN (SELECT ROWNUM AS rownumber, b.*
                   FROM (SELECT aa.num_generations, t.id_acc_template
                           FROM t_account_ancestor aa
                                JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
                          WHERE aa.id_descendent = id_account AND aa.id_descendent <> aa.id_ancestor
                        ORDER BY aa.num_generations) b
                ) a ON tatpp.id_acc_template = a.id_acc_template
     WHERE a.rownumber = 1
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = UpdatePrivateTempates.id_template AND t.nm_prop = tatpp.nm_prop);

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, UpdatePrivateTempates.id_template, vt_start, vt_end
      FROM t_acc_template_subs tatps
           JOIN (SELECT ROWNUM AS rownumber, b.*
                   FROM (SELECT aa.num_generations, t.id_acc_template
                           FROM t_account_ancestor aa
                                JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
                          WHERE aa.id_descendent = id_account AND aa.id_descendent <> aa.id_ancestor
                        ORDER BY aa.num_generations) b
                ) a ON tatps.id_acc_template = a.id_acc_template
     WHERE a.rownumber = 1
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = UpdatePrivateTempates.id_template AND t.id_po = tatps.id_po);

   /*insert new values from parent private templates*/
   FOR rec IN (SELECT aa.id_ancestor, aa.id_descendent, NVL(pa.id_acc_template, a1.id_acc_template) AS id_parent_acc_template, a2.id_acc_template AS current_id, aa.num_generations
                FROM t_account_ancestor aa
                     JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = UpdatePrivateTempates.id_acc_type
                     JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = UpdatePrivateTempates.id_acc_type
                     LEFT JOIN (
                        SELECT t2.id_acc_template, a3.id_descendent
                        FROM   t_account_ancestor a3
                               JOIN t_acc_template t2 ON a3.id_ancestor = t2.id_folder AND t2.id_acc_type = UpdatePrivateTempates.id_acc_type
                        WHERE  num_generations =
                                (SELECT MIN(num_generations)
                                FROM   t_account_ancestor ac
                                       JOIN t_acc_template t3 ON ac.id_ancestor = t3.id_folder
                                WHERE  ac.id_descendent = a3.id_descendent AND num_generations > 0)

                     ) pa ON pa.id_descendent = aa.id_descendent
               WHERE aa.id_ancestor = id_account AND aa.num_generations > 0
              ORDER BY aa.num_generations ASC
             ) LOOP
    /*recursive merge properties to private template of each level of child account from private template of current account */
    INSERT INTO t_acc_template_props
                (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT seq_t_acc_template_props.NextVal, rec.current_id, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp 
     WHERE tatpp.id_acc_template = rec.id_parent_acc_template
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = rec.current_id AND t.nm_prop = tatpp.nm_prop);

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, rec.current_id, vt_start, vt_end
      FROM t_acc_template_subs tatps
     WHERE tatps.id_acc_template = rec.id_parent_acc_template
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = rec.current_id AND t.id_po = tatps.id_po);

   END LOOP;
END;
/

CREATE OR REPLACE 
PROCEDURE ApplyAccountTemplate
(
    accountTemplateId          NUMBER,
    sessionId                  NUMBER,
    systemDate                 DATE,
    sub_start                  DATE,
    sub_end                    DATE,
    next_cycle_after_startdate CHAR,
    next_cycle_after_enddate   CHAR,
    id_event_success           INT,
    id_event_failure           INT,
    account_id                 INT DEFAULT NULL,
    doCommit                   CHAR DEFAULT 'Y'
)
AS
    nRetryCount NUMBER := 0;
    DetailTypeGeneral NUMBER(10);
    DetailResultInformation NUMBER(10);
    DetailTypeSubscription NUMBER(10);
    id_acc_type NUMBER(10);
    id_acc NUMBER(10);
    user_id NUMBER(10);
BEGIN

    SELECT id_acc_type, id_folder
      INTO id_acc_type, id_acc
      FROM t_acc_template
     WHERE id_acc_template = accountTemplateId;


    SELECT id_enum_data
      INTO DetailTypeGeneral
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success';
     
    SELECT id_enum_data
      INTO DetailResultInformation
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information';
     
    SELECT id_enum_data
      INTO DetailTypeSubscription
      FROM t_enum_data
     WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription';
     
    SELECT id_submitter
    INTO   user_id
    FROM   t_acc_template_session ts
    WHERE  id_session = sessionId;
    
    --!!!Starting application of template
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Starting application of template',
        nRetryCount
    );

    /* Updating session details with a number of themplates to be applied in the session */
    UPDATE t_acc_template_session
    SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = id_acc AND aa.id_descendent = at.id_folder)
    WHERE  id_session = sessionId;
    
    IF (doCommit = 'Y')
    THEN
    COMMIT;
    END IF;

    --Select account hierarchy for current template and for each child template.
    FOR tmpl in (
        SELECT tat.id_acc_template
          FROM t_account_ancestor taa
          JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = id_acc_type
         WHERE taa.id_ancestor = id_acc)
    LOOP

        --Apply account template to appropriate account list.
        ApplyTemplateToAccounts
        (
            idAccountTemplate          => tmpl.id_acc_template,
            sessionId                  => sessionId,
            nRetryCount                => nRetryCount,
            systemDate                 => systemDate,
            sub_start                  => sub_start,
            sub_end                    => sub_end,
            next_cycle_after_startdate => next_cycle_after_startdate,
            next_cycle_after_enddate   => next_cycle_after_enddate,
            user_id                    => user_id,
            id_event_success           => id_event_success,
            id_event_failure           => id_event_failure,
            account_id                 => account_id
        );
        
        UPDATE t_acc_template_session
        SET    n_templates_applied = n_templates_applied + 1
        WHERE  id_session = sessionId;
        
        IF (doCommit = 'Y')
        THEN
        COMMIT;
        END IF;

    END LOOP;

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = accountTemplateId
       AND aa.num_generations > 0
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role);
   
    /* Finalize session state */
    UPDATE t_acc_template_session
    SET    n_templates = n_templates_applied
    WHERE  id_session = sessionId;

    --!!!Template application complete
    InsertTmplSessionDetail
    (
        sessionId,
        DetailTypeGeneral,
        DetailResultInformation,
        'Template application complete',
        nRetryCount
    );
END;
/

CREATE OR REPLACE 
PROCEDURE applytemplatetooneaccount
   (
     accountID IN NUMBER
    ,p_systemdate IN DATE
    ,p_acc_type IN VARCHAR2
    )
   IS
   templateId INTEGER;
   templateOwner INTEGER;
   templateCount INTEGER;
   sessionId INTEGER;
BEGIN
    SELECT NVL(MIN(id_acc_template),-1), NVL(MIN(templOwner),-1), COUNT(*)
        INTO templateId, templateOwner, templateCount
        FROM
        (
        select  id_acc_template
                , template.id_folder as templOwner
            from
                    t_acc_template template
            INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
            INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
            inner join t_account_type atype on template.id_acc_type = atype.id_type
            left join t_acc_tmpl_types tatt on tatt.id = 1
                WHERE id_descendent = accountID AND
                    p_systemdate between vt_start AND vt_end AND
                    (atype.name = p_acc_type or tatt.all_types = 1)
            ORDER BY num_generations asc
        )
        where ROWNUM = 1;

    IF (templateCount <> 0 AND templateId <> -1)
    THEN
        inserttemplatesession(templateOwner, p_acc_type, 0, ' ', 0, 0, 0, sessionId, 'N');
        ApplyAccountTemplate(
            accountTemplateId => templateId,
            sessionId => sessionId,
            systemDate => p_systemdate,
            sub_start => p_systemdate,
            sub_end => NULL,
            next_cycle_after_startdate => 'N',
            next_cycle_after_enddate   => 'N',
            id_event_success           => NULL,
            id_event_failure           => NULL,
            account_id                 => accountid,
            doCommit                   => 'N'
        );
    END IF;
END;
/

CREATE OR REPLACE 
PROCEDURE InsertTmplSessionDetail
(
    sessionId NUMBER,
    detailType NUMBER,
    resultInfo NUMBER,
    textData VARCHAR2,
    retryCount NUMBER,
    doCommit CHAR DEFAULT 'Y'
)
AS
BEGIN
    INSERT INTO t_acc_template_session_detail
    (
        id_detail,
        id_session,
        n_detail_type,
        n_result,
        dt_detail,
        nm_text,
        n_retry_count
    )
    VALUES
    (
        seq_template_session_detail.NEXTVAL,
        sessionId,
        detailType,
        resultInfo,
        sysdate,
        textData,
        retryCount
    );
    
    IF (doCommit = 'Y') THEN
        COMMIT;
    END IF;
END;
/

DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT MAX(upgrade_id)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;

    
    UPDATE t_sys_upgrade
    SET db_upgrade_status = 'C',
    dt_end_db_upgrade = SYSDATE()
    WHERE upgrade_id = last_upgrade_id; 
END;
/
CREATE OR REPLACE PROCEDURE recursive_inherit_sub_by_rsch
(
    v_id_rsched   int
)
AS
    id_sub NUMBER;
BEGIN
    SELECT MAX(pm.id_sub)
    INTO   id_sub
    FROM   t_pl_map pm
           INNER JOIN t_rsched r
                ON   r.id_pricelist = pm.id_pricelist
                AND pm.id_pi_template = r.id_pi_template
    WHERE  r.id_sched = v_id_rsched AND pm.id_sub IS NOT NULL;

    IF (id_sub IS NOT NULL) THEN
        mt_rate_pkg.recursive_inherit_sub_to_accs(v_id_sub => id_sub);
    END IF;
END;
/
