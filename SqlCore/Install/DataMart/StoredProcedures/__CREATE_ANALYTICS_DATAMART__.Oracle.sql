create or replace
PROCEDURE CreateAnalyticsDataMart (
   p_dt_now           DATE,
   p_id_run           NUMBER,
   p_nm_currency      NVARCHAR2,
   p_nm_instance      NVARCHAR2,
   p_n_months         NUMBER,
   p_STAGINGDB_prefix VARCHAR2)
   AUTHID CURRENT_USER
AS
    /* >>>>> WORK IN PROGRESS <<<<< -- SInsero */
    /* Variables for log_details */
    v_debug_level    PLS_INTEGER := 1; /* 0=Info, 1=Debug, 2=Trace */
    v_TBD_BYPASS     BOOLEAN := TRUE;
    v_debug_hdr      VARCHAR2(31) := 'CreateAnalyticsDataMart:';
    /* General Variables */
    v_count             PLS_INTEGER;
    v_tmp_tbl           VARCHAR2(61); /* 30 plus dot plus 30 */
    v_sql               VARCHAR2(4000);
    v_tmp_tbl_options   VARCHAR2(1000);
    /* Variable for MetraTime conversion */
    v_dt_start_utc   DATE;
    v_dt_start_mt    DATE; /* MetraTime Start time */
   /* Table names in variables to make changing them easier. */
    /* Use Dynamic SQL with these tables. */
    v_tbl_Customer                 VARCHAR2(30) := UPPER('Customer');
    v_tbl_SalesRep                 VARCHAR2(30) := UPPER('SalesRep');
    v_tbl_SubscriptionByMonth      VARCHAR2(30) := UPPER('SubscriptionByMonth');
    v_tbl_Subscription             VARCHAR2(30) := UPPER('Subscription');
    v_tbl_SubscriptionPrice        VARCHAR2(30) := UPPER('SubscriptionPrice');
    v_tbl_SubscriptionUnits        VARCHAR2(30) := UPPER('SubscriptionUnits');
    v_tbl_SubscriptionSummary      VARCHAR2(30) := UPPER('SubscriptionSummary');
    v_tbl_Counters                 VARCHAR2(30) := UPPER('Counters');
    v_tbl_CurrencyExchangeMonthly  VARCHAR2(30) := UPPER('CurrencyExchangeMonthly');
    v_tbl_ProductOffering          VARCHAR2(30) := UPPER('ProductOffering');
    /* Local function for logging */
    PROCEDURE log_details (p_tx_type VARCHAR2, p_tx_detail NVARCHAR2)
    IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     v_logit      BOOLEAN := TRUE;
     v_len        PLS_INTEGER;
     v_tx_detail  NVARCHAR2(2000);
     v_tx_type    t_recevent_run_details.tx_type%TYPE;
    BEGIN
     /* Trace gets stored as Debug in the DB */
     v_tx_type := p_tx_type;
     CASE
       WHEN p_id_run IS NULL THEN v_logit := FALSE;
       WHEN p_tx_type = 'Debug' AND v_debug_level <  1 THEN v_logit := FALSE;
       WHEN p_tx_type = 'Trace' AND v_debug_level <  2 THEN v_logit := FALSE;
       WHEN p_tx_type = 'Trace' AND v_debug_level >= 2 THEN v_tx_type := 'Debug';
       ELSE v_logit := TRUE;
     END CASE;
     IF (v_logit) THEN
       IF (LENGTH(v_debug_hdr || p_tx_detail) > 2000) THEN
        /* Make all 2 spaces into a single space to compact */
        v_tx_detail := REGEXP_REPLACE(v_debug_hdr || p_tx_detail,'( ){2,}', ' ');
        v_tx_detail := RTRIM(v_tx_detail, 2000);
       ELSE
        v_tx_detail := v_debug_hdr || p_tx_detail;
       END IF;
       INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
       VALUES (seq_t_recevent_run_details.NEXTVAL, p_id_run,v_tx_type,
        v_tx_detail,
        DBO.GETUTCDATE () - v_dt_start_utc + v_dt_start_mt
       );
     END IF;
     COMMIT; /* AUTONOMOUS_TRANSACTION must COMMIT/ROLLBACK before exiting */
    END log_details;
BEGIN
  /* This PROC has multiple COMMITs. It is not a single transaction. */
  /* However, the DELETE from the permanent Datamart tables,         */
  /* and the subsequent INSERT operations, will be part of one BIG   */
  /* transaction. This is basically a Full Refresh.                  */

  /* Get the DB UTC date so we can calculate the MetraTime offset */
  v_dt_start_utc := DBO.GETUTCDATE ();
  /* Default to now if MetraTime (p_dt_now) is not passed in */
  v_dt_start_mt := COALESCE (p_dt_now, v_dt_start_utc);
  /* Above vt_dt variables need to be set before log_details is called. */
  log_details('Debug', 'Proc started');
  log_details('Debug', '>>>>> WORK IN PROGRESS <<<<< -- SInsero'); /* TBD: Remove when finished */

 /* ===== Generating Customers DataMart ===== */
  log_details('Info',  'Generating Customers DataMart started');

  v_tmp_tbl_options := 'NOLOGGING PCTFREE 0';

  /* TBD: tmp tables should have PK, indexes, and statistics generated. */

  /* Generate tmp_adm_corps */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' NUM_GENERATIONS  NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS)                                ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS                                 ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  '  with root_accts as                                                               ' || CHR(10) ||
  '  (                                                                                ' || CHR(10) ||
  '    select /* corporate accounts */                                                ' || CHR(10) ||
  '    a.id_acc                                                                       ' || CHR(10) ||
  '    from t_account a                                                               ' || CHR(10) ||
  '    inner join t_account_type t on t.id_type = a.id_type                           ' || CHR(10) ||
  '    where 1=1                                                                      ' || CHR(10) ||
  '    and t.b_iscorporate = 1                                                        ' || CHR(10) ||
  '    and t.b_isvisibleinhierarchy = 1                                               ' || CHR(10) ||
  '  )                                                                                ' || CHR(10) ||
  '  select /*+ ORDERED */                                                            ' || CHR(10) ||
  '  r.id_acc id_ancestor, aa.id_descendent, aa.num_generations                       ' || CHR(10) ||
  '  from root_accts r                                                                ' || CHR(10) ||
  '  inner join t_account_ancestor aa on aa.id_ancestor = r.id_acc                    ' || CHR(10) ||
  '        and :B1 between aa.vt_start and aa.vt_end                                  ' || CHR(10) ||
  '  where 1=1                                                                        ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Found Corporate Accounts : ' || v_count);
  COMMIT;

  /* Generate tmp_adm_accs */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with my_gens as                                                                    ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select                                                                           ' || CHR(10) ||
  '  id_descendent, max(num_generations) num_generations                              ' || CHR(10) ||
  '  from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps')  || '        ' || CHR(10) ||
  '  group by id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'max(a.id_ancestor) id_ancestor, a.id_descendent                                    ' || CHR(10) ||
  'from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_corps')  || ' a        ' || CHR(10) ||
  'inner join my_gens g on a.id_descendent = g.id_descendent                          ' || CHR(10) ||
  'and a.num_generations = g.num_generations                                          ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  'group by a.id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Found Corporate Hierarchy Accounts : ' || v_count);
  COMMIT;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with root_accts as                                                                 ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select /*+ ORDERED */                                                            ' || CHR(10) ||
  '  aa.id_descendent id_acc                                                          ' || CHR(10) ||
  '  from t_account_ancestor aa                                                       ' || CHR(10) ||
  '  inner join t_account a  on a.id_acc = aa.id_descendent                           ' || CHR(10) ||
  '  inner join t_account_type t  on t.id_type = a.id_type                            ' || CHR(10) ||
  '  and (t.b_iscorporate = 0 or t.b_isvisibleinhierarchy = 0)                        ' || CHR(10) ||
  '  where 1=1                                                                        ' || CHR(10) ||
  '  and :B1 between aa.vt_start and aa.vt_end                                        ' || CHR(10) ||
  '  and aa.id_ancestor = 1                                                           ' || CHR(10) ||
  '  and aa.num_generations = 1                                                       ' || CHR(10) ||
  '  and aa.b_children = ''Y''                                                        ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'r.id_acc id_ancestor, aa.id_descendent                                             ' || CHR(10) ||
  'from root_accts r                                                                  ' || CHR(10) ||
  'inner join t_account_ancestor aa  on aa.id_ancestor = r.id_acc                     ' || CHR(10) ||
  'and :B2 between aa.vt_start and aa.vt_end                                          ' || CHR(10) ||
  'left outer join                                                                    ' || CHR(10) ||
  ' ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs') || ' a              ' || CHR(10) ||
  'on aa.id_descendent = a.id_descendent                                              ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  'and a.id_descendent is null                                                        ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt, v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Corporate Hierarchy Accounts : ' || v_count);
  COMMIT;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                 || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                     ' || CHR(10) ||
  'select a.id_acc,    a.id_acc                                           ' || CHR(10) ||
  'from t_account a                                                       ' || CHR(10) ||
  'left outer join ' || v_tmp_tbl || ' b on a.id_acc = b.id_descendent    ' || CHR(10) ||
  'inner join t_account_ancestor aa  on aa.id_descendent = a.id_acc       ' || CHR(10) ||
  'and :B1 between aa.vt_start and aa.vt_end                              ' || CHR(10) ||
  'and aa.id_ancestor = 1 and aa.num_generations > 0                      ' || CHR(10) ||
  'where 1=1                                                              ' || CHR(10) ||
  'and b.id_descendent is null                                            '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Corporate Non-Hierarchy Accounts : ' || v_count);
  COMMIT;

  /* Generate tmp_adm_unrooted */
  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted');
  IF (TABLE_EXISTS(v_tmp_tbl)) THEN
    EXEC_DDL('TRUNCATE TABLE ' || v_tmp_tbl);
    log_details('Debug', 'Truncated tmp table : ' || v_tmp_tbl);
  ELSE
    v_sql :=
      'CREATE TABLE ' || v_tmp_tbl || ' ('        || CHR(10) ||
      ' ID_ANCESTOR      NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' ID_DESCENDENT    NUMBER(10)    NOT NULL,' || CHR(10) ||
      ' NUM_GENERATIONS  NUMBER(10)    NOT NULL ' || CHR(10) ||
      ') ' || v_tmp_tbl_options
      ;
    log_details('Trace', v_sql);
    EXECUTE IMMEDIATE v_sql;
    log_details('Info', 'Created tmp table : ' || v_tmp_tbl);
  END IF;

  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                 || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS)                    ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT, NUM_GENERATIONS                     ' || CHR(10) ||
  'FROM (                                                                 ' || CHR(10) ||
  'select                                                                 ' || CHR(10) ||
  'aa.id_ancestor, aa.id_descendent, aa.num_generations                   ' || CHR(10) ||
  'from t_account a                                                       ' || CHR(10) ||
  'left outer join                                                        ' || CHR(10) ||
   UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs') || ' b        ' || CHR(10) ||
  'on a.id_acc = b.id_descendent                                          ' || CHR(10) ||
  'inner join t_account_ancestor aa on aa.id_descendent = a.id_acc        ' || CHR(10) ||
  'and :B1 between aa.vt_start and aa.vt_end                              ' || CHR(10) ||
  'where 1=1                                                              ' || CHR(10) ||
  'and b.id_descendent is null                                            ' || CHR(10) ||
  ')                                                                      '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql USING v_dt_start_mt;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Unrooted Accounts : ' || v_count);
  COMMIT;

  v_tmp_tbl := UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_accs');
  v_sql :=
  'INSERT /*+ APPEND */ INTO ' || v_tmp_tbl                                             || CHR(10) ||
  '      (ID_ANCESTOR, ID_DESCENDENT)                                                 ' || CHR(10) ||
  'SELECT ID_ANCESTOR, ID_DESCENDENT                                                  ' || CHR(10) ||
  'FROM (                                                                             ' || CHR(10) ||
  'with my_unrooted as                                                                ' || CHR(10) ||
  '(                                                                                  ' || CHR(10) ||
  '  select id_descendent, max(num_generations) num_generations                       ' || CHR(10) ||
  '  from ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted') || '      ' || CHR(10) ||
  '  group by id_descendent                                                           ' || CHR(10) ||
  ')                                                                                  ' || CHR(10) ||
  'select                                                                             ' || CHR(10) ||
  'b.id_ancestor, b.id_descendent                                                     ' || CHR(10) ||
  'from my_unrooted a                                                                 ' || CHR(10) ||
  'inner join ' || UPPER(COALESCE(p_STAGINGDB_prefix,'') || 'tmp_adm_unrooted') || ' b' || CHR(10) ||
  'on a.id_descendent = b.id_descendent                                               ' || CHR(10) ||
  'and a.num_generations = b.num_generations                                          ' || CHR(10) ||
  'where 1=1                                                                          ' || CHR(10) ||
  ')                                                                                  '
  ;

  log_details('Trace', v_sql);
  EXECUTE IMMEDIATE v_sql;
  v_count := SQL%ROWCOUNT;

  log_details('Debug', 'Added Non-Rooted Accounts : ' || v_count);
  COMMIT;

  log_details('Info', 'Generating Customers DataMart ended');

 /* ===== Flush ===== */
 /* Flushing old DataMart, and refreshing with the new one, needs to be */
 /* one big transaction, for now. */

  log_details('Debug', 'Flush started');

  /* TRUNCATE commits, so must use DELETE here. */
  IF (NOT v_TBD_BYPASS) THEN
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Customer;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SalesRep;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionByMonth;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Subscription;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionPrice;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionUnits;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_SubscriptionSummary;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_Counters;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_CurrencyExchangeMonthly;
  EXECUTE IMMEDIATE 'DELETE FROM ' || v_tbl_ProductOffering;
  END IF; /* v_TBD_BYPASS */

  log_details('Debug', 'Flush ended');

   /* ===== End ===== */

  log_details('Debug', 'Proc ended');
  COMMIT;

EXCEPTION
WHEN OTHERS THEN
  log_details('Info', 'Failed : ' || SQLCODE || ' : ' || SQLERRM);
  log_details('Info', DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
  ROLLBACK;
  RAISE;
END;
