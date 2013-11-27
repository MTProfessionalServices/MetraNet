CREATE OR REPLACE PROCEDURE getmaterializedviewquerytags (
   mv_name                 NVARCHAR2,
   op_type                 VARCHAR2,
   base_table_name         NVARCHAR2,
   updatetag         OUT   NVARCHAR2
)
AS
   foo   str_tab := dbo.csvtostrtab (base_table_name);
BEGIN
   updatetag := NULL;

   INSERT INTO tmp_getmviewquerytags
      SELECT COLUMN_VALUE
        FROM TABLE (foo);

   FOR x IN
      (SELECT update_query_tag
         FROM t_mview_queries
        WHERE id_event =
                 (SELECT DISTINCT mbt1.id_event
                             FROM t_mview_base_tables mbt1 INNER JOIN t_mview_event c
                                  ON mbt1.id_event = c.id_event
                                  INNER JOIN t_mview_catalog d
                                  ON c.id_mv = d.id_mv
                            WHERE NOT EXISTS (
                                     SELECT 1
                                       FROM t_mview_base_tables mbt2
                                      WHERE mbt1.id_event = mbt2.id_event
                                        AND NOT EXISTS (
                                               SELECT 1
                                                 FROM tmp_getmviewquerytags f
                                                WHERE mbt2.base_table_name =
                                                                f.COLUMN_VALUE))
                              AND NOT EXISTS (
                                     SELECT 1
                                       FROM tmp_getmviewquerytags f
                                      WHERE NOT EXISTS (
                                               SELECT 1
                                                 FROM t_mview_base_tables mbt2
                                                WHERE mbt1.id_event =
                                                                 mbt2.id_event
                                                  AND mbt2.base_table_name =
                                                                f.COLUMN_VALUE))
                              AND d.NAME = mv_name)
          AND operation_type = op_type)
   LOOP
      updatetag := x.update_query_tag;
   END LOOP;
END getmaterializedviewquerytags;
/

CREATE OR REPLACE PROCEDURE workflowretrieveinstancestate (
   p_id_instance            NVARCHAR2,
   p_id_owner               NVARCHAR2,
   p_dt_owneduntil          DATE,
   p_result           OUT   NUMBER,
   p_currentownerid   OUT   NVARCHAR2,
   p_state            OUT   sys_refcursor
)
AS
   p_failed_ownership   NVARCHAR2 (256);
BEGIN
   p_failed_ownership := 'Instance ownership conflict';
   p_result := 0;
   p_currentownerid := p_id_owner; /* Possible workflow n_status: 0 for executing; 1 for completed; 2 for suspended; 3 for terminated; 4 for invalid */

   IF p_id_owner IS NOT NULL
   THEN /* if id is null then just loading readonly state, so ignore the ownership check */
      BEGIN
         UPDATE t_wf_instancestate
            SET id_owner = p_id_owner,
                dt_owneduntil = p_dt_owneduntil
          WHERE id_instance = p_id_instance
            AND (   id_owner = p_id_owner
                 OR id_owner IS NULL
                 OR dt_owneduntil < SYSDATE ()
                );

         IF (SQL%ROWCOUNT = 0)
         THEN
            BEGIN
               BEGIN
                  SELECT id_owner
                    INTO p_currentownerid
                    FROM t_wf_instancestate
                   WHERE id_instance = p_id_instance;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_currentownerid := NULL;
               END;

               IF (SQL%ROWCOUNT = 0)
               THEN
                  p_result := -1;
               ELSE
                  p_result := -2;
               END IF;

               GOTO done;
            END;
         END IF;
      END;
   END IF;

   OPEN p_state FOR
      SELECT state
        FROM t_wf_instancestate
       WHERE id_instance = p_id_instance;

   p_result := SQL%ROWCOUNT;

   IF (p_result = 0)
   THEN
      BEGIN
         p_result := -1;
         GOTO done;
      END;
   END IF;

   <<done>> /*        COMMIT TRANSACTION */
   RETURN;
END workflowretrieveinstancestate;
/

CREATE OR REPLACE PROCEDURE workflowunlockinstancestate (
   p_id_instance   IN   NVARCHAR2,
   p_id_owner           NVARCHAR2
)
AS
BEGIN
   UPDATE t_wf_instancestate
      SET id_owner = NULL,
          dt_owneduntil = NULL
    WHERE id_instance = p_id_instance
      AND (   (id_owner = p_id_owner AND dt_owneduntil >= SYSDATE ())
           OR (id_owner IS NULL AND p_id_owner IS NULL)
          );
END workflowunlockinstancestate;
/

CREATE OR REPLACE PROCEDURE getmetadataforprops (
   p_tablename          VARCHAR2,
   p_columnname         VARCHAR2 DEFAULT NULL,
   p_cur          OUT   sys_refcursor
)
AS
   v_sql   VARCHAR2 (1000);
BEGIN
   v_sql :=
         'select column_name as name,
        data_type as type,

			/* Determine data size */
			case
			when data_type in (''NVARCHAR2'', ''VARCHAR2'', ''NVARCHAR'', ''VARCHAR'', ''NCHAR'', ''CHAR'')
			then
			nvl(char_length,0)
			when data_type in (''RAW'') then
			nvl(data_length,0)
			else
			nvl(data_precision,0)
			end as length,
			nvl(data_scale, 0) as decplaces,
			(case nullable
			WHEN ''N'' THEN ''TRUE''
			WHEN ''Y'' THEN ''FALSE''  END )  as required,
			(select count(*) from user_tab_columns
			where table_name = upper('''
      || p_tablename
      || ''')) as isRowType
			FROM user_tab_columns where table_name = upper('''
      || p_tablename
      || ''')';

   IF (p_columnname IS NOT NULL AND p_columnname != ' ')
   THEN
      v_sql :=
         v_sql || ' AND column_name = upper(' || '''' || p_columnname
         || ''')';
   END IF;

   v_sql := v_sql || ' ORDER BY column_id';

   OPEN p_cur FOR v_sql;
END;
/

CREATE OR REPLACE PROCEDURE wfretrieveexpiredtimerids (
   p_id_owner              NVARCHAR2,
   p_dt_owneduntil         DATE,
   p_now                   DATE,
   p_result          OUT   sys_refcursor
)
AS
BEGIN /* gkc 9/27/07 allow return of multiple "id_instance" by adding a "sys_refcursor" parameter */
   OPEN p_result FOR
      SELECT id_instance
        FROM t_wf_instancestate
       WHERE dt_nexttimer < p_now
         AND n_status <> 1
         AND n_status <> 3
         AND n_status <>
                2 /* not n_blocked and not completed and not terminated and not suspended */
         AND (   (n_unlocked = 1 AND id_owner IS NULL)
              OR dt_owneduntil < SYSDATE ()
             );
END wfretrieveexpiredtimerids;
/

CREATE OR REPLACE PROCEDURE wfretnonblockinstancestateids (
   p_id_owner              NVARCHAR2,
   p_dt_owneduntil         DATE,
   p_now                   DATE,
   p_result          OUT   sys_refcursor
)
AS
BEGIN
   OPEN p_result FOR /* gkc 9/27/07 added for update nowait to lock the rows */
      SELECT     id_instance
            FROM t_wf_instancestate /* WITH (TABLOCK,UPDLOCK,HOLDLOCK) */
           WHERE n_blocked = 0
             AND n_status <> 1
             AND n_status <> 3
             AND n_status <>
                    2 /* not n_blocked and not completed and not terminated and not suspended */
             AND (id_owner IS NULL OR dt_owneduntil < SYSDATE ())
      FOR UPDATE NOWAIT;

   IF (SQL%ROWCOUNT > 0)
   THEN
      BEGIN /* lock the table entries that are returned */
         UPDATE t_wf_instancestate
            SET id_owner = p_id_owner,
                dt_owneduntil = p_dt_owneduntil
          WHERE n_blocked = 0
            AND n_status <> 1
            AND n_status <> 3
            AND n_status <> 2
            AND (id_owner IS NULL OR dt_owneduntil < SYSDATE ());
      END;
   END IF;
END wfretnonblockinstancestateids;
/

CREATE OR REPLACE PROCEDURE deleteuniquekeymetadata (consname VARCHAR2)
AS
BEGIN                                        /* Delete key colums first     */
   DELETE FROM t_unique_cons_columns
         WHERE id_unique_cons IN (
                              SELECT id_unique_cons
                                FROM t_unique_cons
                               WHERE LOWER (constraint_name) =
                                                             LOWER (consname));
                                                    /* Delete key name     */

   DELETE FROM t_unique_cons
         WHERE LOWER (constraint_name) = LOWER (consname);
END deleteuniquekeymetadata;
/

CREATE OR REPLACE PROCEDURE workflowinsertcompletedscope (
   p_id_instance         NVARCHAR2,
   p_id_completedscope   NVARCHAR2,
   p_state               BLOB
)
AS
BEGIN /* gkc 9/27/07 if entry exists update else insert */
   MERGE INTO t_wf_completedscope twc
      USING t_wf_completedscope twc1
      ON (twc1.id_completedscope = p_id_completedscope)
      WHEN MATCHED THEN
         UPDATE
            SET twc.state = p_state, twc.dt_modified = SYSDATE ()
      WHEN NOT MATCHED THEN
         INSERT (twc.id_instance, twc.id_completedscope, twc.state,
                 twc.dt_modified)
         VALUES (p_id_instance, p_id_completedscope, p_state, SYSDATE ());
END workflowinsertcompletedscope;
/

CREATE OR REPLACE PROCEDURE getnewuievents (p_id_acc INTEGER, p_result OUT sys_refcursor)
AS
BEGIN
   OPEN p_result FOR
      SELECT   ueq.id_event_queue, ueq.id_event, ueq.id_acc, ueq.dt_crt,
               ueq.dt_viewed, ueq.b_deleted, ueq.b_bubbled, ue.tx_event_type,
               ue.json_blob
          FROM t_ui_event_queue ueq, t_ui_event ue
         WHERE ue.id_event = ueq.id_event
           AND (ueq.id_event_queue > p_id_acc AND dt_viewed IS NULL)
      ORDER BY id_event DESC;
END getnewuievents;
/

CREATE OR REPLACE PROCEDURE workflowdeletecompletedscope (p_id_completedscope NVARCHAR2)
AS
BEGIN
   DELETE FROM t_wf_completedscope
         WHERE id_completedscope = p_id_completedscope;
END workflowdeletecompletedscope;
/

CREATE OR REPLACE PROCEDURE mt_sys_analyze_all_tables (
   username           VARCHAR2 DEFAULT NULL,
   p_sampling_ratio   VARCHAR2 DEFAULT '20'
)
AS
/* How to run this stored procedure        begin       MT_sys_analyze_all_tables;       end;       */
   v_user_name   VARCHAR2 (30);
   v_sql         VARCHAR2 (4000);
BEGIN
   IF (username IS NULL)
   THEN
      SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER')
        INTO v_user_name
        FROM DUAL;
   END IF;

   v_sql :=
         'begin dbms_stats.gather_schema_stats(
					ownname=> '''
      || v_user_name
      || ''',
					estimate_percent=> '
      || p_sampling_ratio
      || ',
					degree=> dbms_stats.auto_degree,
					granularity=> ''AUTO'',
					method_opt=> ''FOR ALL COLUMNS SIZE 1'',
					options=> ''GATHER'',
					cascade=> TRUE); end;';

   EXECUTE IMMEDIATE v_sql;
END;
/

CREATE OR REPLACE PROCEDURE workflowretrievecompletedscope (
   p_id_completedscope         NVARCHAR2,
   p_result              OUT   NUMBER,
   p_state               OUT   sys_refcursor
)
AS
BEGIN
   OPEN p_state FOR
      SELECT state
        FROM t_wf_completedscope
       WHERE id_completedscope = p_id_completedscope;

   p_result := SQL%ROWCOUNT;
END workflowretrievecompletedscope;
/

CREATE OR REPLACE PROCEDURE workflowinsertinstancestate (
   p_id_instance            NVARCHAR2,
   p_state                  BLOB,
   p_n_status               NUMBER,
   p_n_unlocked             NUMBER,
   p_n_blocked              NUMBER,
   p_tx_info                NCLOB,
   p_id_owner               NVARCHAR2,
   p_dt_owneduntil          DATE,
   p_dt_nexttimer           DATE,
   p_result           OUT   NUMBER,
   p_currentownerid   OUT   NVARCHAR2
)
AS
   p_insertinstancestate_failed   NVARCHAR2 (256);
   p_now                          DATE;
   p_cnt                          NUMBER;
BEGIN
   p_result := 0;
   p_cnt := 0;
   p_insertinstancestate_failed := 'Instance ownership conflict';
   p_currentownerid := p_id_owner;
   p_now := SYSDATE; /* SET TRANSACTION ISOLATION LEVEL READ COMMITTED; */

   IF p_n_status = 1 OR p_n_status = 3
   THEN
      BEGIN
         DELETE FROM t_wf_instancestate
               WHERE id_instance = p_id_instance
                 AND (   (id_owner = p_id_owner AND dt_owneduntil >= p_now)
                      OR (id_owner IS NULL AND p_id_owner IS NULL)
                     );

         IF (SQL%ROWCOUNT = 0)
         THEN
            BEGIN
               BEGIN
                  SELECT id_owner
                    INTO p_currentownerid
                    FROM t_wf_instancestate
                   WHERE id_instance = p_id_instance;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     p_currentownerid := NULL;
               END;

               IF (p_currentownerid IS NOT NULL)
               THEN
                  BEGIN /* gkc 9/27/07 leave out the RAISERERROR                             cannot delete the instance state because of an ownership conflict                         RAISEERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                     p_result := -2;
                     RETURN;
                  END;
               END IF;
            END;
         ELSE
            BEGIN
               DELETE FROM t_wf_completedscope
                     WHERE id_instance = p_id_instance;
            END;
         END IF;
      END;
   ELSE
      BEGIN /* if not exists ( Select 1 from t_wf_InstanceState Where id_instance = p_id_instance ) then                      gkc 9/27/07 when p_cnt = 0, is equivalent to NOT EXISTS (SELECT 1) in sql server */
         BEGIN
            SELECT 1
              INTO p_cnt
              FROM t_wf_instancestate
             WHERE id_instance = p_id_instance;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_cnt := 0;
         END;

         IF p_cnt = 0
         THEN
            BEGIN /* Insert Operation */
               IF p_n_unlocked = 0
               THEN
                  BEGIN
                     INSERT INTO t_wf_instancestate
                                 (id_instance, state, n_status,
                                  n_unlocked, n_blocked, tx_info,
                                  dt_modified, id_owner, dt_owneduntil,
                                  dt_nexttimer
                                 )
                          VALUES (p_id_instance, p_state, p_n_status,
                                  p_n_unlocked, p_n_blocked, p_tx_info,
                                  p_now, p_id_owner, p_dt_owneduntil,
                                  p_dt_nexttimer
                                 );
                  END;
               ELSE
                  BEGIN
                     INSERT INTO t_wf_instancestate
                                 (id_instance, state, n_status,
                                  n_unlocked, n_blocked, tx_info,
                                  dt_modified, id_owner, dt_owneduntil,
                                  dt_nexttimer
                                 )
                          VALUES (p_id_instance, p_state, p_n_status,
                                  p_n_unlocked, p_n_blocked, p_tx_info,
                                  p_now, p_id_owner, p_dt_owneduntil,
                                  p_dt_nexttimer
                                 );
                  END;
               END IF;
            END;
         ELSE
            BEGIN
               IF p_n_unlocked = 0
               THEN
                  BEGIN
                     UPDATE t_wf_instancestate
                        SET state = p_state,
                            n_status = p_n_status,
                            n_unlocked = p_n_unlocked,
                            n_blocked = p_n_blocked,
                            tx_info = p_tx_info,
                            dt_modified = p_now,
                            dt_owneduntil = p_dt_owneduntil,
                            dt_nexttimer = p_dt_nexttimer
                      WHERE id_instance = p_id_instance
                        AND (   (    id_owner = p_id_owner
                                 AND dt_owneduntil >= p_now
                                )
                             OR (id_owner IS NULL AND p_id_owner IS NULL)
                            );

                     IF (SQL%ROWCOUNT = 0)
                     THEN
                        BEGIN /* gkc 9/27/07 leave out the RAISERERROR                  RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                           BEGIN
                              SELECT id_owner
                                INTO p_currentownerid
                                FROM t_wf_instancestate
                               WHERE id_instance = p_id_instance;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 p_currentownerid := NULL;
                           END;

                           p_result := -2;
                           RETURN;
                        END;
                     END IF;
                  END;
               ELSE
                  BEGIN
                     UPDATE t_wf_instancestate
                        SET state = p_state,
                            n_status = p_n_status,
                            n_unlocked = p_n_unlocked,
                            n_blocked = p_n_blocked,
                            tx_info = p_tx_info,
                            dt_modified = p_now,
                            id_owner = NULL,
                            dt_owneduntil = NULL,
                            dt_nexttimer = p_dt_nexttimer
                      WHERE id_instance = p_id_instance
                        AND (   (    id_owner = p_id_owner
                                 AND dt_owneduntil >= p_now
                                )
                             OR (id_owner IS NULL AND p_id_owner IS NULL)
                            );

                     IF (SQL%ROWCOUNT = 0)
                     THEN
                        BEGIN /* gkc 9/27/07 leave out the RAISERERROR                        RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                           BEGIN
                              SELECT id_owner
                                INTO p_currentownerid
                                FROM t_wf_instancestate
                               WHERE id_instance = p_id_instance;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 p_currentownerid := NULL;
                           END;

                           p_result := -2;
                           RETURN;
                        END;
                     END IF;
                  END;
               END IF;
            END;
         END IF; /* gkc 9/27/07 goes with outer begin */
      END;
   END IF; /* gkc 9/27/07 what about exception handling ?? */

   RETURN;
END workflowinsertinstancestate;
/

CREATE OR REPLACE PROCEDURE wfretnonblockinstancestateid (
   p_id_owner              NVARCHAR2,
   p_dt_owneduntil         DATE,
   p_id_instance     OUT   NVARCHAR2,
   p_found           OUT   NUMBER
)
AS
BEGIN /* Guarantee that no one else grabs this record between the select and update                   SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;                    accept the default transaction isolation level of "Read Committed"                      Begin TRANASCTION                        gkc 9/27/07 get lock on ONE row... */
   BEGIN
      SELECT     id_instance
            INTO p_id_instance
            FROM t_wf_instancestate
           WHERE n_blocked = 0
             AND n_status NOT IN (1, 2, 3)
             AND (id_owner IS NULL OR dt_owneduntil < SYSDATE ())
             AND ROWNUM <= 1
      FOR UPDATE NOWAIT;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_id_instance := NULL;
   END; /* what is going to release this lock?  */

   IF p_id_instance IS NOT NULL
   THEN
      BEGIN
         UPDATE t_wf_instancestate
            SET id_owner = p_id_owner,
                dt_owneduntil = p_dt_owneduntil
          WHERE id_instance = p_id_instance;

         p_found := 1;
      END;
   ELSE
      BEGIN
         p_found := 0;
      END;
   END IF; /*  gkc 9/27/07 ???? question do we want the commit to occur;                   COMMIT; */
END wfretnonblockinstancestateid;
/

CREATE OR REPLACE PROCEDURE addacctohierarchy (
   p_id_ancestor     IN       INT DEFAULT NULL,
   p_id_descendent   IN       INT DEFAULT NULL,
   p_dt_start        IN       DATE DEFAULT NULL,
   p_dt_end          IN       DATE DEFAULT NULL,
   p_acc_startdate   IN       DATE DEFAULT NULL,
   ancestor_type     OUT      VARCHAR2,
   acc_type          OUT      VARCHAR2,
   status            IN OUT   INT
)
AS
   realstartdate          DATE;
   realenddate            DATE;
   varmaxdatetime         DATE;
   ancestor               INT;
   descendentidasstring   VARCHAR2 (50);
   ancestorstartdate      DATE;
   realaccstartdate       DATE;
   ancestor_acc_type      INT;
   descendent_acc_type    INT;
   nfound                 INT;
BEGIN                                               /* begin business rules */
   varmaxdatetime := dbo.mtmaxdate ();
   descendentidasstring := CAST (p_id_descendent AS VARCHAR2);

   FOR x IN (SELECT atype.NAME, atype.id_type
               FROM t_account acc INNER JOIN t_account_type atype
                    ON atype.id_type = acc.id_type
              WHERE acc.id_acc = p_id_ancestor)
   LOOP
      ancestor_type := x.NAME;
      ancestor_acc_type := x.id_type;
   END LOOP;

   FOR x IN (SELECT atype.NAME, atype.id_type
               FROM t_account acc INNER JOIN t_account_type atype
                    ON atype.id_type = acc.id_type
              WHERE acc.id_acc = p_id_descendent)
   LOOP
      acc_type := x.NAME;
      descendent_acc_type := x.id_type;
   END LOOP;

   FOR x IN (SELECT id_acc
               FROM t_account
              WHERE id_acc = p_id_ancestor)
   LOOP
      ancestor := x.id_acc;
   END LOOP;

   IF p_id_ancestor IS NULL
   THEN                                       /* MT_PARENT_NOT_IN_HIERARCHY */
      status := -486604771;
      RETURN;
   END IF;

   SELECT COUNT (*)
     INTO nfound
     FROM DUAL
    WHERE descendent_acc_type NOT IN (SELECT id_descendent_type
                                        FROM t_acctype_descendenttype_map
                                       WHERE id_type = ancestor_acc_type);

   IF nfound <> 0
   THEN                                    /* MT_ANCESTOR_OF_INCORRECT_TYPE */
      status := -486604714;
      RETURN;
   END IF;

   IF p_acc_startdate IS NULL
   THEN
      SELECT dt_crt
        INTO realaccstartdate
        FROM t_account
       WHERE id_acc = p_id_descendent;
   ELSE
      realaccstartdate := p_acc_startdate;
   END IF;

   FOR x IN (SELECT dt_crt
               FROM t_account
              WHERE id_acc = p_id_ancestor)
   LOOP
      ancestorstartdate := x.dt_crt;
   END LOOP;

   IF dbo.mtstartofday (realaccstartdate) <
                                          dbo.mtstartofday (ancestorstartdate)
   THEN                   /* MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START */
      status := -486604746;
      RETURN;
   END IF;

   SELECT COUNT (*)
     INTO status
     FROM t_account_ancestor
    WHERE id_descendent = p_id_descendent
      AND id_ancestor = p_id_ancestor
      AND num_generations = 1
      AND (dbo.overlappingdaterange (vt_start, vt_end, p_dt_start, p_dt_end) =
                                                                             1
          );

   IF (status > 0)
   THEN                                   /* MT_ACCOUNT_ALREADY_IN_HIEARCHY */
      status := -486604785;
      RETURN;
   END IF;                                     /* end business rule checks. */

   realstartdate := dbo.mtstartofday (p_dt_start);

   IF (p_dt_end IS NULL)
   THEN
      realenddate := dbo.mtstartofday (dbo.mtmaxdate ());
   ELSE
      realenddate := dbo.mtendofday (p_dt_end);
   END IF;
/* todo: we need error handling code to detect when the ancestor does    not exist at the time interval!!    populate t_account_ancestor (no bitemporal data)    */

   INSERT INTO t_account_ancestor
               (id_ancestor, id_descendent, num_generations, vt_start, vt_end,
                tx_path)
      SELECT id_ancestor, p_id_descendent, num_generations + 1,
             dbo.mtmaxoftwodates (vt_start, realstartdate),
             dbo.mtminoftwodates (vt_end, realenddate),
             CASE
                WHEN (id_descendent = 1 OR id_descendent = -1)
                   THEN tx_path || descendentidasstring
                ELSE tx_path || '/' || descendentidasstring
             END
        FROM t_account_ancestor
       WHERE id_descendent = p_id_ancestor
         AND id_ancestor <> id_descendent
         AND dbo.overlappingdaterange (vt_start,
                                       vt_end,
                                       realstartdate,
                                       realenddate
                                      ) = 1
      UNION ALL            /* the new record to parent.  note that the ..?? */
      SELECT p_id_ancestor, p_id_descendent, 1, realstartdate, realenddate,
             CASE
                WHEN (id_descendent = 1 OR id_descendent = -1)
                   THEN tx_path || descendentidasstring
                ELSE tx_path || '/' || descendentidasstring
             END
        FROM t_account_ancestor
       WHERE id_descendent = p_id_ancestor
         AND num_generations = 0
         AND dbo.overlappingdaterange (vt_start,
                                       vt_end,
                                       realstartdate,
                                       realenddate
                                      ) = 1                 /* self pointer */
      UNION ALL
      SELECT p_id_descendent, p_id_descendent, 0, realstartdate, realenddate,
             descendentidasstring
        FROM DUAL;              /* update our parent entry to have children */

   UPDATE t_account_ancestor
      SET b_children = 'Y'
    WHERE id_descendent = p_id_ancestor
      AND dbo.overlappingdaterange (vt_start,
                                    vt_end,
                                    realstartdate,
                                    realenddate
                                   ) = 1;

   IF (SQLCODE <> 0)
   THEN
      status := 0;
      RETURN;
   END IF;

   status := 1;
END addacctohierarchy;
/

CREATE OR REPLACE PROCEDURE createreportingdb (
   p_strdbname            IN       NVARCHAR2,
   p_strpassword          IN       NVARCHAR2,
   p_strnetmeterdbname    IN       NVARCHAR2,
   p_strdatalogfilepath   IN       NVARCHAR2,
   p_dbsize               IN       INT,
   p_return_code          OUT      INT
)
AUTHID CURRENT_USER
AS
   strdatafilename          VARCHAR2 (255);
   strdbcreatequery         VARCHAR2 (2000);
   stradddbtobackupquery    VARCHAR2 (2000);
   strcreatedbuser          VARCHAR2 (2000);
   straddtableexitsquery    VARCHAR2 (2000);
   straddobjectexitsquery   VARCHAR2 (2000);
   strsetuserprovileges     VARCHAR2 (400);
   bdebug                   INT;
   errmsg                   VARCHAR2 (200);
   v_sqlcode                NUMBER (12);
   v_sqlerrm                VARCHAR2 (200);
   btablespacecreated       BOOLEAN;
   busercreated             BOOLEAN;
   fatalerror               EXCEPTION;
BEGIN
   btablespacecreated := TRUE;
   busercreated := TRUE;
   errmsg := NULL;
   p_return_code := 0;
   bdebug := 1;
   strdatafilename :=
                    p_strdatalogfilepath || '\' || p_strdbname || '_data.dbf';
   strdbcreatequery :=
         'create tablespace '
      || p_strdbname
      || ' datafile '''
      || strdatafilename
      || ''' size '
      || TO_CHAR (p_dbsize)
      || 'M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED '
      || 'LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO';
   strcreatedbuser :=
         'create user '
      || p_strdbname
      || ' identified by '
      || p_strpassword
      || ' default tablespace '
      || p_strdbname
      || ' temporary tablespace temp quota unlimited on '
      || p_strdbname;
   stradddbtobackupquery :=
         'insert into '
      || p_strnetmeterdbname
      || '.t_ReportingDBLog(NameOfReportingDB, doBackup)'
      || ' Values('''
      || p_strdbname
      || ''', ''Y'')';
   straddtableexitsquery :=
         'CREATE OR REPLACE function '
      || p_strdbname
      || '.table_exists(tab varchar2) return boolean authid current_user'
      || ' as exist int := 0; begin'
      || ' select count(1) into exist from user_tables where table_name = upper(tab);'
      || ' if (exist > 0)then return true; end if;'
      || ' select count(1) into exist from all_tables where owner || ''.'' || table_name = upper(tab);'
      || ' return(exist > 0); end;';
   straddobjectexitsquery :=
         'CREATE OR REPLACE function '
      || p_strdbname
      || '.object_exists(obj varchar2) return boolean authid current_user'
      || ' as exist int := 0; begin'
      || ' select count (1) into exist from user_objects where object_name = upper (obj);'
      || ' if (exist > 0) then return true; end if;'
      || ' select count (1) into exist from all_objects where owner || ''.'' || object_name = upper(obj);'
      || ' return (exist > 0); end;';              /* Create the tablespace */

   BEGIN
      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line (   'About to execute create DB Query : '
                               || strdbcreatequery
                              );
      END IF;

      EXECUTE IMMEDIATE (strdbcreatequery);
   EXCEPTION
      WHEN OTHERS
      THEN
         btablespacecreated := FALSE;
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
              'An error occured while creating the database: ' || p_strdbname;
         RAISE fatalerror;
   END;                                      /* Create user for tablespace. */

   BEGIN
      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line (   'About to execute create DB user Query : '
                               || strcreatedbuser
                              );
      END IF;

      EXECUTE IMMEDIATE (strcreatedbuser);
/* Add dbcreator role to nmdbo, used for creating datamart database later in datamart adapter */

      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line ('About to grant user privileges');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         busercreated := FALSE;
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
               'An error occured while creating the db user: ' || p_strdbname;
         RAISE fatalerror;
   END;

   BEGIN
      strsetuserprovileges :=
            'grant CONNECT, RESOURCE, CREATE TABLE, CREATE VIEW, EXECUTE ANY PROCEDURE,'
         || 'SELECT ANY TABLE,SELECT ANY SEQUENCE,INSERT ANY TABLE,'
         || 'CREATE SEQUENCE, QUERY REWR
ITE, CREATE MATERIALIZED VIEW to '
         || p_strdbname;

      EXECUTE IMMEDIATE (strsetuserprovileges);
   EXCEPTION
      WHEN OTHERS
      THEN
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
            'An error occured while granting user priveleges: '
            || p_strdbname;
         RAISE fatalerror;
   END;                                     /* Add 'table_exists' function. */

   BEGIN
      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line ('About to add ''table_exists'' function.');
      END IF;

      EXECUTE IMMEDIATE (straddtableexitsquery);
   EXCEPTION
      WHEN OTHERS
      THEN
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
               'An error occured while adding ''table_exits'' function. Database: '
            || p_strdbname;
         RAISE fatalerror;
   END;                                    /* Add 'object_exists' function. */

   BEGIN
      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line ('About to add ''object_exists'' function.');
      END IF;

      EXECUTE IMMEDIATE (straddobjectexitsquery);
   EXCEPTION
      WHEN OTHERS
      THEN
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
               'An error occured while adding ''object_exists'' function. Database: '
            || p_strdbname;
         RAISE fatalerror;
   END;                             /* Execute database to backup db table. */

   BEGIN
      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line
                       (   'About to execute add DB to backup table Query : '
                        || stradddbtobackupquery
                       );
      END IF;

      EXECUTE IMMEDIATE (stradddbtobackupquery);
   EXCEPTION
      WHEN OTHERS
      THEN
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg :=
               'An error occured while adding database to t_ReportingDBLog table. Database: '
            || p_strdbname;
         RAISE fatalerror;
   END;

   RETURN;
EXCEPTION
   WHEN fatalerror
   THEN
      IF errmsg IS NULL
      THEN
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         errmsg := 'CreateReportingDB: stored procedure failed';
      END IF;

      IF (bdebug = 1)
      THEN
         DBMS_OUTPUT.put_line (   errmsg
                               || ' error code: '
                               || TO_CHAR (v_sqlcode)
                               || ', '
                               || v_sqlerrm
                              );
      END IF;

      IF (busercreated = TRUE)
      THEN
         EXECUTE IMMEDIATE ('drop user ' || p_strdbname || ' cascade');
      END IF;

      IF (btablespacecreated = TRUE)
      THEN
         EXECUTE IMMEDIATE (   'drop tablespace '
                            || p_strdbname
                            || ' including contents and datafiles'
                           );

         EXECUTE IMMEDIATE (   'delete from '
                            || p_strnetmeterdbname
                            || '.t_ReportingDBLog where NameOfReportingDB = '''
                            || p_strdbname
                            || ''''
                           );
      END IF;

      p_return_code := -1;
      RETURN;
END;
/

CREATE OR REPLACE PROCEDURE createuievent (eventtype VARCHAR2, jsonblob NCLOB, accountid NUMBER)
AS
   eventid   NUMBER (10);
BEGIN
   INSERT INTO t_ui_event
               (id_event, tx_event_type, json_blob
               )
        VALUES (seq_t_ui_event.NEXTVAL, eventtype, jsonblob
               );

   SELECT seq_t_ui_event.CURRVAL
     INTO eventid
     FROM DUAL;

   INSERT INTO t_ui_event_queue
               (id_event_queue, id_event, id_acc, dt_crt,
                dt_viewed, b_deleted, b_bubbled
               )
        VALUES (seq_t_ui_event_queue.NEXTVAL, eventid, accountid, SYSDATE,
                NULL, '0', '0'
               );
END;
/

CREATE OR REPLACE PROCEDURE updatedataforenumtostring (p_table VARCHAR2, p_column VARCHAR2)
AS
   p_query   VARCHAR2 (1000);
BEGIN
   p_query :=
         'update '
      || p_table
      || ' set '
      || p_column
      || ' =
									(select REVERSE(to_char(substr(REVERSE(to_char(nm_enum_data)),1,
									instr(reverse(to_char(nm_enum_data)),''/'',1,1)-1)))
									from t_enum_data
									WHERE id_enum_data = '
      || p_column
      || ')';

   EXECUTE IMMEDIATE (p_query);
END;
/

CREATE OR REPLACE PROCEDURE getevents (p_id_event_queue INTEGER, p_result OUT sys_refcursor)
AS
BEGIN
   OPEN p_result FOR
      SELECT   ueq.id_event_queue, ueq.id_event, ueq.id_acc, ueq.dt_crt,
               ueq.dt_viewed, ueq.b_deleted, ueq.b_bubbled, ue.tx_event_type,
               ue.json_blob
          FROM t_ui_event_queue ueq, t_ui_event ue
         WHERE ue.id_event = ueq.id_event
           AND (ueq.id_event_queue > p_id_event_queue AND dt_viewed IS NULL)
      ORDER BY id_event DESC;
END getevents;
/

CREATE OR REPLACE PROCEDURE wfretallinstancedescriptions (p_result OUT sys_refcursor)
AS
BEGIN /* gkc 9/27/07 add a parm type of cursor to record set */
   OPEN p_result FOR
      SELECT id_instance, tx_info, n_status, dt_nexttimer, n_blocked
        FROM t_wf_instancestate;
END wfretallinstancedescriptions;
/

CREATE OR REPLACE PROCEDURE mtsp_insertinvoice_balances (
   p_id_billgroup             INT,
   p_exclude_billable         CHAR,
    /* '1' to only return non-billable accounts, '0' to return all accounts */
   p_id_run                   INT,
   p_return_code        OUT   INT
)
AS
   v_debug_flag       NUMBER (1)     := 1;                          /* yes */
   v_sqlerror         INT;
   v_errmsg           VARCHAR2 (200);
   fatalerror         EXCEPTION;
   v_dummy_datamart   VARCHAR2 (10);
BEGIN                       /*  populate the driver table with account ids  */
   BEGIN
      INSERT INTO tmp_all_accounts
                  (id_acc, namespace)
         SELECT /*DISTINCT*/ bgm.id_acc, MAP.nm_space
           FROM t_billgroup_member bgm INNER JOIN t_acc_usage au
                ON au.id_acc = bgm.id_acc
                INNER JOIN t_account_mapper MAP ON MAP.id_acc = au.id_acc
                INNER JOIN t_namespace ns ON ns.nm_space = MAP.nm_space
          WHERE ns.tx_typ_space = 'system_mps'
            AND bgm.id_billgroup = p_id_billgroup
            AND au.id_usage_interval IN (SELECT id_usage_interval
                                           FROM t_billgroup
                                          WHERE id_billgroup = p_id_billgroup)
         UNION
         SELECT /*DISTINCT*/ ads.id_acc, MAP.nm_space
           FROM vw_adjustment_summary ads INNER JOIN t_billgroup_member bgm
                ON bgm.id_acc = ads.id_acc
                INNER JOIN t_account_mapper MAP ON MAP.id_acc = ads.id_acc
                INNER JOIN t_namespace ns ON ns.nm_space = MAP.nm_space
          WHERE ns.tx_typ_space = 'system_mps'
            AND bgm.id_billgroup = p_id_billgroup
            AND ads.id_usage_interval IN (SELECT id_usage_interval
                                            FROM t_billgroup
                                           WHERE id_billgroup = p_id_billgroup)
         UNION
/* The convoluted logic below is to find the latest current balance for the account.  This may */
/* not be the previous interval, as the invoice adapter may not have been run */
/* for certain intervals.  Won't happen in production, but I encountered this */
/* a lot while testing. */
         SELECT DISTINCT id_acc, namespace
                    FROM (SELECT   inv.id_acc, inv.namespace,
                                   NVL
                                      (MAX
                                          (   TO_CHAR (ui.dt_end, 'YYYYMMDD')
                                           || RPAD
                                                 ('0',
                                                    20
                                                  - LENGTH
                                                          (inv.current_balance),
                                                  '0'
                                                 )
                                           || TO_CHAR (inv.current_balance)
                                          ),
                                       '00000000000'
                                      ) comp
                              FROM t_invoice inv INNER JOIN t_billgroup_member bgm
                                   ON bgm.id_acc = inv.id_acc
                                   INNER JOIN t_billgroup bg
                                   ON bg.id_billgroup = bgm.id_billgroup
                                   INNER JOIN t_usage_interval ui
                                   ON ui.id_interval = bg.id_usage_interval
                                   INNER JOIN t_namespace ns
                                   ON ns.nm_space = inv.namespace
                             WHERE ns.tx_typ_space = 'system_mps'
                               AND bgm.id_billgroup = p_id_billgroup
                          GROUP BY inv.id_acc, inv.namespace) latestinv
                   WHERE CAST
                            (SUBSTR (comp,
                                     CASE
                                        WHEN INSTR (comp, '-', 1) = 0
                                           THEN 10
                                        ELSE INSTR (comp, '-', 1)
                                     END,
                                     28
                                    ) AS NUMBER (18, 6)
                            ) <> 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE fatalerror;
   END;

   BEGIN
/* Populate with accounts that are non-billable but have payers that are billable.
 in specified billing group */
      IF (p_exclude_billable = '1')
      THEN
         INSERT INTO tmp_all_accounts
                     (id_acc, namespace)
            SELECT                                               /*DISTINCT*/
                   pr.id_payee, MAP.nm_space
              FROM t_billgroup_member bgm INNER JOIN t_payment_redirection pr
                   ON pr.id_payer = bgm.id_acc
                   INNER JOIN t_acc_usage au ON au.id_acc = pr.id_payee
                   INNER JOIN t_account_mapper MAP ON MAP.id_acc = au.id_acc
                   INNER JOIN t_namespace ns ON ns.nm_space = MAP.nm_space
             WHERE ns.tx_typ_space = 'system_mps'
               AND bgm.id_billgroup = p_id_billgroup
               AND pr.id_payee NOT IN (SELECT id_acc
                                         FROM tmp_all_accounts)
               AND au.id_usage_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup)
            UNION
            SELECT                                                /*DISTINCT*/
                   ads.id_acc, MAP.nm_space
              FROM vw_adjustment_summary ads INNER JOIN t_payment_redirection pr
                   ON pr.id_payee = ads.id_acc
                   INNER JOIN t_billgroup_member bgm ON bgm.id_acc =
                                                                   pr.id_payer
                   INNER JOIN t_account_mapper MAP ON MAP.id_acc = ads.id_acc
                   INNER JOIN t_namespace ns ON ns.nm_space = MAP.nm_space
             WHERE ns.tx_typ_space = 'system_mps'
               AND bgm.id_billgroup = p_id_billgroup
               AND pr.id_payee NOT IN (SELECT id_acc
                                         FROM tmp_all_accounts)
               AND ads.id_usage_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup)
            UNION
            /* The convoluted logic below is to find the latest current balance for the account.  This may
            not be the previous interval, as the invoice adapter may not have been run
            for certain intervals.  Won't happen in production, but I encountered this  a lot while testing */
            SELECT DISTINCT id_acc, namespace
                       FROM (SELECT   inv.id_acc, inv.namespace,
                                      NVL
                                         (MAX
                                             (   TO_CHAR (ui.dt_end,
                                                          'YYYYMMDD'
                                                         )
                                              || RPAD
                                                    ('0',
                                                       20
                                                     - LENGTH
                                                          (inv.current_balance),
                                                     '0'
                                                    )
                                              || TO_CHAR (inv.current_balance)
                                             ),
                                          '00000000000'
                                         ) comp
                                 FROM t_invoice inv INNER JOIN t_payment_redirection pr
                                      ON pr.id_payee = inv.id_acc
                                      INNER JOIN t_billgroup_member bgm
                                      ON bgm.id_acc = pr.id_payer
                                      INNER JOIN t_billgroup bg
                                      ON bg.id_billgroup = bgm.id_billgroup
                                      INNER JOIN t_usage_interval ui
                                      ON ui.id_interval = bg.id_usage_interval
                                      INNER JOIN t_namespace ns
                                      ON ns.nm_space = inv.namespace
                                WHERE ns.tx_typ_space = 'system_mps'
                                  AND pr.id_payee NOT IN (
                                                         SELECT id_acc
                                                           FROM tmp_all_accounts)
                                  AND bgm.id_billgroup = p_id_billgroup
                             GROUP BY inv.id_acc, inv.namespace) latestinv
                      WHERE CAST
                               (SUBSTR (comp,
                                        CASE
                                           WHEN INSTR (comp, '-', 1) = 0
                                              THEN 10
                                           ELSE INSTR (comp, '-', 1)
                                        END,
                                        28
                                       ) AS NUMBER (18, 6)
                               ) <> 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE fatalerror;
   END;
       /*  populate tmp_acc_amounts with accounts and their invoice amounts */

   IF (v_debug_flag = 1 AND p_id_run IS NOT NULL)
   THEN
      INSERT INTO t_recevent_run_details
                  (id_detail, id_run, tx_type,
                   tx_detail,
                   dt_crt
                  )
           VALUES (seq_t_recevent_run_details.NEXTVAL, p_id_run, 'Debug',
                   'Invoice-Bal: Begin inserting to the tmp_acc_amounts table',
                   dbo.getutcdate
                  );
   END IF;

   SELECT VALUE
     INTO v_dummy_datamart
     FROM t_db_values
    WHERE parameter = N'DATAMART';

   IF (v_dummy_datamart = 'FALSE' OR v_dummy_datamart = 'false')
   THEN
      BEGIN
         INSERT INTO tmp_acc_amounts
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
                             au.id_usage_interval id_interval, ammps.id_acc,
                             avi.c_currency invoice_currency,
                             SUM
                                (CASE
                                    WHEN pvpay.id_sess IS NULL
                                       THEN 0
                                    ELSE NVL (au.amount, 0)
                                 END
                                ) payment_ttl_amt,
                             0 postbill_adj_ttl_amt,
                                                    /* postbill_adj_ttl_amt */
                             SUM
                                (CASE
                                    WHEN pvar.id_sess IS NULL
                                       THEN 0
                                    ELSE NVL (au.amount, 0)
                                 END
                                ) ar_adj_ttl_amt,
                             0 previous_balance,        /* previous_balance */
                               SUM
                                  (CASE
                                      WHEN (    pvpay.id_sess IS NULL
                                            AND pvar.id_sess IS NULL
                                           )
                                         THEN (NVL (au.tax_federal, 0.0))
                                      ELSE 0
                                   END
                                  )
                             + SUM
                                  (CASE
                                      WHEN (    pvpay.id_sess IS NULL
                                            AND pvar.id_sess IS NULL
                                           )
                                         THEN (NVL (au.tax_state, 0.0))
                                      ELSE 0
                                   END
                                  )
                             + SUM
                                  (CASE
                                      WHEN (    pvpay.id_sess IS NULL
                                            AND pvar.id_sess IS NULL
                                           )
                                         THEN (NVL (au.tax_county, 0.0))
                                      ELSE 0
                                   END
                                  )
                             + SUM
                                  (CASE
                                      WHEN (    pvpay.id_sess IS NULL
                                            AND pvar.id_sess IS NULL
                                           )
                                         THEN (NVL (au.tax_local, 0.0))
                                      ELSE 0
                                   END
                                  )
                             + SUM
                                  (CASE
                                      WHEN (    pvpay.id_sess IS NULL
                                            AND pvar.id_sess IS NULL
                                           )
                                         THEN (NVL (au.tax_other, 0.0))
                                      ELSE 0
                                   END
                                  ) tax_ttl_amt,
                             SUM
                                (CASE
                                    WHEN (    pvpay.id_sess IS NULL
                                          AND pvar.id_sess IS NULL
                                          AND NOT vh.id_view IS NULL
                                         )
                                       THEN (NVL (au.amount, 0.0))
                                    ELSE 0
                                 END
                                ) current_charges,
                             CASE
                                WHEN avi.c_billable = '0'
                                   THEN pr.id_payer
                                ELSE ammps.id_acc
                             END id_payer,
                             CASE
                                WHEN avi.c_billable = '0'
                                   THEN auipay.id_usage_interval
                                ELSE au.id_usage_interval
                             END id_payer_interval
                        FROM tmp_all_accounts tmpall INNER JOIN t_av_internal avi
                             ON avi.id_acc = tmpall.id_acc
                             INNER JOIN t_account_mapper ammps
                             ON ammps.id_acc = tmpall.id_acc
                             INNER JOIN t_namespace ns
                             ON ns.nm_space = ammps.nm_space
                           AND ns.tx_typ_space = 'system_mps'
                             INNER JOIN t_acc_usage_interval aui
                             ON aui.id_acc = tmpall.id_acc
                             INNER JOIN t_usage_interval ui
                             ON aui.id_usage_interval = ui.id_interval
                           AND ui.id_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup)
                                                            /*= @id_interval*/
                             INNER JOIN t_payment_redirection pr
                             ON tmpall.id_acc = pr.id_payee
                           AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end
                             INNER JOIN t_acc_usage_interval auipay
                             ON auipay.id_acc = pr.id_payer
                             INNER JOIN t_usage_interval uipay
                             ON auipay.id_usage_interval = uipay.id_interval
                           AND ui.dt_end
                                  BETWEEN CASE
                                  WHEN auipay.dt_effective IS NULL
                                     THEN uipay.dt_start
                                  ELSE dbo.addsecond (auipay.dt_effective)
                               END
                                      AND uipay.dt_end
                             LEFT OUTER JOIN
                             (SELECT au1.id_usage_interval, au1.amount,
                                     au1.tax_federal, au1.tax_state,
                                     au1.tax_county, au1.tax_local,
                                     au1.tax_other, au1.id_sess, au1.id_acc,
                                     au1.id_view
                                FROM t_acc_usage au1 LEFT OUTER JOIN t_pi_template pitemplated2
                                     ON pitemplated2.id_template =
                                                            au1.id_pi_template
                                     LEFT OUTER JOIN t_base_props pi_type_props
                                     ON pi_type_props.id_prop =
                                                            pitemplated2.id_pi
                                     LEFT OUTER JOIN t_enum_data enumd2
                                     ON au1.id_view = enumd2.id_enum_data
                                   AND (   pi_type_props.n_kind IS NULL
                                        OR pi_type_props.n_kind <> 15
                                        OR UPPER (enumd2.nm_enum_data) NOT LIKE
                                                                      '%_TEMP'
                                       )
                               WHERE au1.id_parent_sess IS NULL
                                 AND au1.id_usage_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup)
                                                            /*= @id_interval*/
                                 AND (   (    au1.id_pi_template IS NULL
                                          AND au1.id_parent_sess IS NULL
                                         )
                                      OR (    au1.id_pi_template IS NOT NULL
                                          AND pitemplated2.id_template_parent IS NULL
                                         )
                                     )) au
                             ON au.id_acc =
                                  tmpall.id_acc
                     /*  join with the tables used for calculating the sums */
                             LEFT OUTER JOIN t_view_hierarchy vh
                             ON au.id_view = vh.id_view
                           AND vh.id_view = vh.id_view_parent
                             LEFT OUTER JOIN t_pv_aradjustment pvar
                             ON pvar.id_sess = au.id_sess
                           AND au.id_usage_interval = pvar.id_usage_interval
                             LEFT OUTER JOIN t_pv_payment pvpay
                             ON pvpay.id_sess = au.id_sess
                           AND au.id_usage_interval =
                                  pvpay.id_usage_interval
                                                    /*  non-join conditions */
                       WHERE (p_exclude_billable = '0' OR avi.c_billable = '0'
                             )
                    GROUP BY ammps.nm_space,
                             ammps.id_acc,
                             au.id_usage_interval,
                             avi.c_currency,
                             pr.id_payer,
                             auipay.id_usage_interval,
                             avi.c_billable) x;
      END;
   ELSE
      BEGIN
        /* else datamarts are being used. join against t_mv_payer_interval */
         IF (table_exists ('t_mv_payer_interval'))
         THEN
            EXECUTE IMMEDIATE (   'INSERT INTO tmp_acc_amounts
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
                                       THEN (NVL (dm.TotalAmount,
                                                  0.0
                                                 )
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
                                                                  WHERE id_billgroup = '
                               || TO_CHAR (p_id_billgroup)
                               || ')
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
                                                                          '
                               || TO_CHAR (p_id_billgroup)
                               || ') /*= @id_interval*/
                             LEFT OUTER JOIN t_enum_data ed ON dm.id_view =
                                                                 ed.id_enum_data /*  non-join conditions */
						WHERE ('
                               || p_exclude_billable
                               || ' = ''0'' OR avi.c_billable = ''0'')
                    GROUP BY ammps.nm_space,
                             tmpall.id_acc,
                             dm.id_usage_interval,
                             avi.c_currency,
                             pr.id_payer,
                             auipay.id_usage_interval,
                             avi.c_billable) x'
                              );
         END IF;
      END;
   END IF;
          /* populate tmp_adjustments with postbill and prebill adjustments */

   BEGIN
/*   FULL OUTER JOIN tmp_all_accounts ON adjtrx.id_acc = tmp_all_accounts.id_acc    Here we're doing a union of two outer joins because FULL outer join seems
to create and Oracle carsh.
*/
      INSERT INTO tmp_adjustments
                  (id_acc, prebilladjamt, prebilltaxadjamt, postbilladjamt,
                   postbilltaxadjamt)
         SELECT NVL (adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
                NVL (prebilladjamt, 0) prebilladjamt,
                NVL (prebilltaxadjamt, 0) prebilltaxadjamt,
                NVL (postbilladjamt, 0) postbilladjamt,
                NVL (postbilltaxadjamt, 0) postbilltaxadjamt
           FROM vw_adjustment_summary adjtrx INNER JOIN t_billgroup_member bgm
                ON bgm.id_acc = adjtrx.id_acc
                LEFT OUTER JOIN tmp_all_accounts
                ON adjtrx.id_acc = tmp_all_accounts.id_acc
          WHERE bgm.id_billgroup = p_id_billgroup
            AND adjtrx.id_usage_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup)
         UNION
         SELECT NVL (adjtrx.id_acc, tmp_all_accounts.id_acc) id_acc,
                NVL (prebilladjamt, 0) prebilladjamt,
                NVL (prebilltaxadjamt, 0) prebilltaxadjamt,
                NVL (postbilladjamt, 0) postbilladjamt,
                NVL (postbilltaxadjamt, 0) postbilltaxadjamt
           FROM vw_adjustment_summary adjtrx INNER JOIN t_billgroup_member bgm
                ON bgm.id_acc = adjtrx.id_acc
                RIGHT OUTER JOIN tmp_all_accounts
                ON adjtrx.id_acc = tmp_all_accounts.id_acc
          WHERE bgm.id_billgroup = p_id_billgroup
            AND adjtrx.id_usage_interval IN (
                                           SELECT id_usage_interval
                                             FROM t_billgroup
                                            WHERE id_billgroup =
                                                                p_id_billgroup);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE fatalerror;
   END;

/* populate tmp_prev_balance with the previous balance */
   BEGIN
      INSERT INTO tmp_prev_balance
                  (id_acc, previous_balance)
         SELECT id_acc,
                CAST
                   (SUBSTR (comp,
                            CASE
                               WHEN INSTR (comp, '-') = 0
                                  THEN 10
                               ELSE INSTR (comp, '-')
                            END,
                            28
                           ) AS NUMBER (18, 6)
                   ) previous_balance
           FROM (SELECT   inv.id_acc,
                          NVL (MAX (   TO_CHAR (ui.dt_end, 'YYYYMMDD')
                                    || RPAD ('0',
                                             20 - LENGTH (inv.current_balance)
                                            )
                                    || TO_CHAR (inv.current_balance)
                                   ),
                               '00000000000'
                              ) comp
                     FROM t_invoice inv INNER JOIN t_usage_interval ui
                          ON ui.id_interval = inv.id_interval
                          INNER JOIN tmp_all_accounts
                          ON inv.id_acc = tmp_all_accounts.id_acc
                 GROUP BY inv.id_acc) maxdtend;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE fatalerror;
   END;

/* truncate the table for future use */
   EXECUTE IMMEDIATE 'truncate table tmp_all_accounts';

   IF (v_debug_flag = 1 AND p_id_run IS NOT NULL)
   THEN
      INSERT INTO t_recevent_run_details
                  (id_detail, id_run, tx_type,
                   tx_detail, dt_crt
                  )
           VALUES (seq_t_recevent_run_details.NEXTVAL, p_id_run, 'Debug',
                   'Invoice-Bal: Completed successfully', dbo.getutcdate
                  );
   END IF;

   p_return_code := 0;
   RETURN;
EXCEPTION
   WHEN fatalerror
   THEN
      IF v_errmsg IS NULL
      THEN
         v_errmsg := 'Invoice-Bal: Stored procedure failed';
      END IF;

      IF (v_debug_flag = 1 AND p_id_run IS NOT NULL)
      THEN
         INSERT INTO t_recevent_run_details
                     (id_detail, id_run, tx_type,
                      tx_detail, dt_crt
                     )
              VALUES (seq_t_recevent_run_details.NEXTVAL, p_id_run, 'Debug',
                      v_errmsg, dbo.getutcdate
                     );
      END IF;

      p_return_code := -1;
      RETURN;
END;
/

CREATE OR REPLACE PROCEDURE account_bucket_mapping (
   p_partition         NVARCHAR2 DEFAULT NULL,
   p_interval          INT DEFAULT NULL,
   p_hash              INT,
   p_result      OUT   NVARCHAR2
)
AS
   v_sql           VARCHAR2 (4000);
   v_count         NUMBER (10)      := 0;
   v_partname      NVARCHAR2 (2000);
   v_maxdate       VARCHAR2 (100);
   v_currentdate   VARCHAR2 (100);
BEGIN
/* Before we run the archving procedures, directory should exist and access is granted to MetraNet schema owner: for example CREATE DIRECTORY backup_dir AS '/usr/apps/datafiles'; GRANT READ,WRITE ON DIRECTORY backup_dir TO nmdbo; */
/* How to run this procedure DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVAL NUMBER;   P_HASH NUMBER;   P_RESULT NVARCHAR2(200); BEGIN    P_PARTITION := NULL;   P_INTERVAL := 883621891;   P_HASH := 2;   P_RESULT := NULL;   ACCOUNT_BUCKET_MAPPING ( P_PARTITION, P_INTERVAL, P_HASH, P_RESULT );   dbms_output.put_line(p_result);   COMMIT;  END;   OR DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVAL NUMBER;   P_HASH NUMBER;   P_RESULT NVARCHAR2(200);  BEGIN    P_PARTITION := 'HS_20070131';   P_INTERVAL := null;   P_HASH := 2;   P_RESULT := NULL;   ACCOUNT_BUCKET_MAPPING ( P_PARTITION, P_INTERVAL, P_HASH, P_RESULT );   dbms_output.put_line(p_result);   COMMIT;  END;   */
   SELECT SYSDATE
     INTO v_currentdate
     FROM DUAL;

   SELECT dbo.mtmaxdate
     INTO v_maxdate
     FROM DUAL;     /* Check that either Interval or Partition is specified */

   IF (   (p_partition IS NOT NULL AND p_interval IS NOT NULL)
       OR (p_partition IS NULL AND p_interval IS NULL)
      )
   THEN
      p_result :=
         '4000001-account_bucket_mapping operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;               /* Run the following code if Interval is specified */

   IF (p_interval IS NOT NULL)
   THEN                                        /*Check that Interval exists */
      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = p_interval;

      IF v_count = 0
      THEN
         p_result :=
            '4000002-account_bucket_mapping operation failed-->Interval Does not exists';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = p_interval AND tx_interval_status = 'H';

      IF v_count = 0
      THEN
         p_result :=
            '4000002a-account_bucket_mapping operation failed-->Interval is not Hard Closed';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = p_interval;

      IF v_count > 0
      THEN
         p_result :=
            '4000003-account_bucket_mapping operation failed-->Mapping already exists';
         ROLLBACK;
         RETURN;
      END IF;
/* We will apply the hash function on all the payers in the specified interval, we are using t_acc_usage_interval to avoid scan of t_acc_usage */

      BEGIN
         v_sql :=
               'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
                select distinct '
            || CAST (p_interval AS VARCHAR2)
            || ',id_acc,mod(id_acc,'
            || CAST (p_hash AS VARCHAR2)
            || '),''U'','''
            || v_currentdate
            || ''','''
            || v_maxdate
            || ''' from t_acc_usage_interval where id_usage_interval = '
            || CAST (p_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '4000004-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN                 /* Get all the intervals in the specified Partition */
      IF table_exists ('tmp_acc_bucket_map')
      THEN
         exec_ddl ('truncate table tmp_acc_bucket_map');
      END IF;

      INSERT INTO tmp_acc_bucket_map
         SELECT id_interval
           FROM t_partition_interval_map MAP
          WHERE id_partition = (SELECT id_partition
                                  FROM t_partition
                                 WHERE partition_name = p_partition);

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval inte INNER JOIN tmp_acc_bucket_map MAP
             ON inte.id_interval = MAP.id_interval
           AND tx_interval_status <> 'H'
             ;

      IF (v_count > 0)
      THEN
         p_result :=
            '4000005-account_bucket_mapping operation failed-->Interval is not Hard Closed';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;          /*Check that mapping should not already exists */

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map inte INNER JOIN tmp_acc_bucket_map MAP
             ON inte.id_usage_interval = MAP.id_interval
             ;

      IF (v_count > 0)
      THEN
         p_result :=
            '4000006-account_bucket_mapping operation failed-->Mapping already exists';
         ROLLBACK;
         RETURN;
      END IF;
/* We will apply the hash function on all the payers in the all the intervals of partition,  we are using t_acc_usage_interval to avoid scan of t_acc_usage */

      BEGIN
         v_sql :=
               'INSERT INTO t_acc_bucket_map
                     (id_usage_interval, id_acc, bucket, status, tt_start,
                      tt_end)
         select id_usage_interval,id_acc,mod(id_acc,'
            || CAST (p_hash AS VARCHAR2)
            || '),
            ''U'','''
            || v_currentdate
            || ''','''
            || v_maxdate
            || ''' from t_acc_usage_interval where id_usage_interval in (select id_interval
            from tmp_acc_bucket_map)';

         EXECUTE IMMEDIATE (v_sql);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '4000007-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-account_bucket_mapping operation successful';
END;
/

CREATE OR REPLACE PROCEDURE removesubscription (p_id_sub IN INTEGER, p_systemdate IN DATE)
AS
   groupid   INTEGER;
   maxdate   DATE;
   icbid     INTEGER;
   status    INTEGER;
BEGIN
   BEGIN
      SELECT id_group, dbo.mtmaxdate ()
        INTO groupid, maxdate
        FROM t_sub
       WHERE id_sub = p_id_sub AND p_systemdate BETWEEN vt_start AND vt_end;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;             /* Look for an ICB pricelist and delete it if it exists */

   BEGIN
      SELECT id_pricelist
        INTO icbid
        FROM t_pl_map
       WHERE id_sub = p_id_sub AND ROWNUM < 2;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF groupid IS NOT NULL
   THEN
      UPDATE t_gsubmember_historical
         SET tt_end = p_systemdate
       WHERE tt_end = maxdate AND id_group = groupid;

      DELETE FROM t_gsubmember
            WHERE id_group = groupid;

      DELETE FROM t_gsub_recur_map
            WHERE id_group = groupid;
   END IF;

   DELETE FROM t_pl_map
         WHERE id_sub = p_id_sub;

   DELETE FROM t_sub
         WHERE id_sub = p_id_sub;

   UPDATE t_recur_value
      SET tt_end = p_systemdate
    WHERE id_sub = p_id_sub AND tt_end = maxdate;

   UPDATE t_sub_history
      SET tt_end = p_systemdate
    WHERE tt_end = maxdate AND id_sub = p_id_sub;

   IF icbid IS NOT NULL
   THEN
      sp_deletepricelist (icbid, status);

      IF (status <> 0)
      THEN
         RETURN;
      END IF;
   END IF;
END;
/

CREATE OR REPLACE PROCEDURE createpaymentrecord (
   payer                              INT,
   npa                                INT,
   startdate                          DATE,
   enddate                            DATE,
   payerbillable                      VARCHAR2,
   systemdate                         DATE,
   p_fromupdate                       CHAR,
   p_enforce_same_corporation         VARCHAR2,
   p_account_currency                 NVARCHAR2,
   status                       OUT   INT
)
AS
   account_currency       NVARCHAR2 (5);
   realstartdate          DATE;
   realenddate            DATE;
   acccreatedate          DATE;
   billableflag           VARCHAR2 (1);
   payer_state            VARCHAR2 (10);
   npapayerrule           VARCHAR2 (1);
   samecurrency           INT;
   payeecurrentancestor   INT;
   check1                 INT;
   check2                 INT;
   check3                 INT;
   payer_cycle_type       INT;
   check4                 INT;
BEGIN
   status := 0;
   realstartdate := dbo.mtstartofday (startdate);
   account_currency := p_account_currency;

   IF (enddate IS NULL)
   THEN
      realenddate := dbo.mtstartofday (dbo.mtmaxdate ());
   ELSIF enddate <> dbo.mtstartofday (dbo.mtmaxdate ())
   THEN
      realenddate := dbo.mtstartofday (enddate) + 1;
   ELSE
      realenddate := enddate;
   END IF;

   SELECT dbo.mtstartofday (dt_crt)
     INTO acccreatedate
     FROM t_account
    WHERE id_acc = npa;

   IF realstartdate < acccreatedate
   THEN                          /* MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE */
      status := -486604753;
      RETURN;
   END IF;

   IF realstartdate = realenddate
   THEN                            /* MT_PAYMENT_START_AND_END_ARE_THE_SAME */
      status := -486604735;
      RETURN;
   END IF;

   IF realstartdate > realenddate
   THEN                                      /* MT_PAYMENT_START_AFTER_END  */
      status := -486604734;
      RETURN;
   END IF;
/* npa: non paying account           assumptions: the system has already checked if an existing payment           redirection record exists.  the user is asked whether the           system should truncate the existing payment redirection record.           business rule checks:             mt_account_can_not_pay_for_itself (0xe2ff0007l, -486604793)             account_is_not_billable (0xe2ff0005l,-486604795)             mt_payment_relationship_exists (0xe2ff0006l, -486604794)             step 1: account can not pay for itself           if (payer = npa)             begin               select status = -486604793               return             end   */

   IF (payer <> -1)
   THEN
      billableflag :=
         CASE
            WHEN payerbillable IS NULL
               THEN dbo.isaccountbillable (payer)
            ELSE payerbillable
         END;
/* step 2: the account is in a state such that new payment              records can be created */

      IF (billableflag = '0')
      THEN                                  /*  MT_ACCOUNT_IS_NOT_BILLABLE */
         status := -486604795;
         RETURN;
      END IF;
/* make sure that the paying account is active for the entire        payment period       */

      SELECT status
        INTO payer_state
        FROM t_account_state
       WHERE dbo.encloseddaterange (vt_start,
                                    vt_end,
                                    realstartdate,
                                    realenddate - 1 / (24 * 60 * 60)
                                   ) = 1
         AND id_acc = payer
         AND ROWNUM <= 1;

      IF payer_state IS NULL OR LOWER (payer_state) <> 'ac'
      THEN                                     /* mt_payer_in_invalid_state */
         status := -486604736;
         RETURN;
      END IF;

/* always check that payer and payee are on the same currency        (if they are not the same, of course)              if p_account_currency parameter was passed as empty string, then              the call is coming either from mam, and the currency is not available,              or the call is coming from account update session, where currency is not being              updated. in both cases it won't hurt to resolve it from t_av_internal and check
that it matches payer currency.. ok, in kona, an account that can never be a payer
need not have a currency, handle this.
*/
      IF (npa <> payer)
      THEN
         IF (   (LENGTH (account_currency) = 0)
             OR (LENGTH (account_currency) IS NULL)
            )
         THEN
            SELECT c_currency
              INTO account_currency
              FROM t_av_internal
             WHERE id_acc = npa;

            IF (account_currency IS NULL)
            THEN
               /* check if the account type has the b_canbepayer false, if it is
               then just assume that it has the same currency as the
               prospective payer. */
               SELECT b_canbepayer
                 INTO npapayerrule
                 FROM t_account_type atype INNER JOIN t_account acc
                      ON atype.id_type = acc.id_type
                WHERE acc.id_acc = npa;

               IF (npapayerrule = '0')
               THEN
                  SELECT c_currency
                    INTO account_currency
                    FROM t_av_internal
                   WHERE id_acc = payer;
               END IF;
            END IF;
         END IF;

         SELECT COUNT (payerav.id_acc)
           INTO samecurrency
           FROM t_av_internal payerav
          WHERE payerav.id_acc = payer
            AND UPPER (payerav.c_currency) = UPPER (account_currency);

         IF samecurrency = 0
         THEN
            /* MT_PAYER_PAYEE_CURRENCY_MISMATCH */
            status := -486604728;
            RETURN;
         END IF;
      END IF;                                               /* npa <> payer */

      /* check that both the payer and payee are in the same corporate account
      only check this if business rule is enforced
      only check this if the payee's current ancestor is not -1 */
      SELECT id_ancestor
        INTO payeecurrentancestor
        FROM t_account_ancestor
       WHERE id_descendent = npa
         AND realstartdate BETWEEN vt_start AND vt_end
         AND num_generations = 1;

      IF (    p_enforce_same_corporation = 1
          AND payeecurrentancestor <> -1
          AND dbo.isinsamecorporateaccount (payer, npa, realstartdate) <> 1
         )
      THEN          /* MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT */
         status := -486604758;
         RETURN;
      END IF;
   END IF;
/*  payer <> -1 */
       /* return without doing work in cases where nothing needs to be done */

   SELECT COUNT (*)
     INTO status
     FROM t_payment_redirection
    WHERE id_payer = payer
      AND id_payee = npa
      AND (   (    dbo.encloseddaterange (vt_start,
                                          vt_end,
                                          realstartdate,
                                          realenddate
                                         ) = 1
               AND p_fromupdate = 'n'
              )
           OR (    vt_start <= realstartdate
               AND vt_end = realenddate
               AND p_fromupdate = 'y'
              )
          );

   IF status > 0
   THEN
/* account is already paying for the account during the interval.            simply ignore the action */
      status := 1;
      RETURN;
   END IF;

   createpaymentrecordbitemporal (payer,
                                  npa,
                                  realstartdate,
                                  realenddate,
                                  systemdate,
                                  status
                                 );

   IF status <> 1
   THEN
      RETURN;
   END IF;
/* post-operation business rule checks (relies on rollback of work done up       until this point) */

   SELECT
             /* cr9906: checks to make sure the new payer's billing cycle matches all of
          the payee's group subscriptions' bcr constraints */
          NVL (MIN (dbo.checkgroupmembershipcycleconst (systemdate,
                                                        grps.id_group
                                                       )
                   ),
               1
              ),
          /* ebcr cycle constraint checks */
          NVL (MIN (dbo.checkgroupmembershipebcrconstr (systemdate,
                                                        grps.id_group
                                                       )
                   ),
               1
              )
     INTO check1,
          check2
     FROM (
           /* gets all of the payee's group subscriptions */
           SELECT DISTINCT gsm.id_group id_group
                      FROM t_gsubmember gsm
                     WHERE gsm.id_acc = npa /* payee id */) grps;

   IF (check1 <> 1)
   THEN
      status := check1;
      RETURN;
   ELSIF (check2 <> 1)
   THEN
      status := check2;
      RETURN;
   END IF;

   check3 := 1;

   FOR i IN
      (                            /* gets all of the payee's receiverships */
       SELECT DISTINCT gsrm.id_group id_group
                  FROM t_gsub_recur_map gsrm
                 WHERE gsrm.id_acc = npa /* payee id */)
   LOOP
      check3 := dbo.checkgroupreceiverebcrcons (systemdate, i.id_group);
      EXIT;
   END LOOP;

   IF (check3 <> 1)
   THEN
      status := check3;
   END IF;

   /* Part of bug fix for 13588
   check that - if the payee has individual subscriptions to product offerings with BCR constraints, then the
   new payer's cycle type satisfies those constraints. */
   FOR i IN (SELECT TYPE.id_cycle_type
               FROM t_acc_usage_cycle uc INNER JOIN t_usage_cycle ucc
                    ON uc.id_usage_cycle = ucc.id_usage_cycle
                    INNER JOIN t_usage_cycle_type TYPE
                    ON ucc.id_cycle_type = TYPE.id_cycle_type
              WHERE uc.id_acc = payer)
   LOOP
      payer_cycle_type := i.id_cycle_type;
   END LOOP;
/* g. cieplik 1/29/2009 (CORE-660) poConstrainedCycleType returns zero when there is no "ConstrainedCycleType", added predicate to check value being returned from "poConstrainedCycleType */

   SELECT COUNT (1)
     INTO check4
     FROM DUAL
    WHERE EXISTS (
             SELECT id_po
               FROM t_sub sub
              WHERE id_acc = npa
                AND id_group IS NULL
                AND realenddate >= sub.vt_start
                AND realstartdate <= sub.vt_end
                AND dbo.pocontainsbillingcyclerelative (id_po) = 1
                AND payer_cycle_type <> dbo.poconstrainedcycletype (id_po)
                AND 0 <> dbo.poconstrainedcycletype (id_po));

   IF (check4 <> 0)
   THEN
      status := -289472464;
   END IF;
END createpaymentrecord;
/

CREATE OR REPLACE PROCEDURE archive_queue (
   p_update_stats           CHAR DEFAULT 'N',
   p_sampling_ratio         VARCHAR2 DEFAULT '30',
   p_result           OUT   VARCHAR2
)
AS
   v_sql1                    VARCHAR2 (4000);
   v_tab1                    VARCHAR2 (1000);
   v_var1                    VARCHAR2 (1000);
   v_vartime                 DATE;
   v_maxtime                 DATE;
   v_count                   NUMBER;
   c1                        sys_refcursor;
   v_nu_varstatpercentchar   INT;
   v_user_name               VARCHAR2 (30);
BEGIN
/* How to run this stored procedure        DECLARE      P_RESULT VARCHAR2(200);      BEGIN      P_RESULT := NULL;        ARCHIVE_QUEUE ( p_result => P_RESULT );      dbms_output.put_line(p_result);        COMMIT;      END;      OR        DECLARE        P_UPDATE_STATS VARCHAR2(200);        P_SAMPLING_RATIO VARCHAR2(200);        P_RESULT VARCHAR2(200);      BEGIN        P_UPDATE_STATS := 'Y';        P_SAMPLING_RATIO := 100;        P_RESULT := NULL;        ARCHIVE_QUEUE ( P_UPDATE_STATS, P_SAMPLING_RATIO, P_RESULT );       dbms_output.put_line(p_result);        COMMIT;      END;         */
   v_maxtime := dbo.mtmaxdate ();
   v_count := 0;

   BEGIN
      IF table_exists ('tmp_t_session_state')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp_t_session_state';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000001--archive_queues operation failed-->error in dropping tmp_t_session_state';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      IF table_exists ('tmp2_t_session_state')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000001a--archive_queues operation failed-->error in dropping tmp2_t_session_state';
         ROLLBACK;
         RETURN;
   END;

   OPEN c1 FOR
      SELECT nm_table_name
        FROM t_service_def_log;

   LOOP
      FETCH c1
       INTO v_tab1;

      EXIT WHEN c1%NOTFOUND;

      EXECUTE IMMEDIATE ('lock table ' || v_tab1 || ' in exclusive mode');
   END LOOP;

   CLOSE c1;

   EXECUTE IMMEDIATE ('lock table t_message in exclusive mode');

   EXECUTE IMMEDIATE ('lock table t_session_set in exclusive mode');

   EXECUTE IMMEDIATE ('lock table t_session in exclusive mode');

   EXECUTE IMMEDIATE ('lock table t_session_state in exclusive mode');

   BEGIN
      INSERT INTO tmp_t_session_state
         SELECT sess.id_source_sess
           FROM t_session sess
          WHERE NOT EXISTS (SELECT 1
                              FROM t_session_state state
                             WHERE state.id_sess = sess.id_source_sess)
         UNION ALL
         SELECT id_sess
           FROM t_session_state state
          WHERE tx_state IN ('F', 'R') AND state.dt_end = v_maxtime;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000002-archive_queues operation failed-->Error in populating tmp_t_session_state';
         ROLLBACK;
         RETURN;
   END;

   SELECT COUNT (*)
     INTO v_count
     FROM t_prod_view
    WHERE b_can_resubmit_from = 'N' AND nm_table_name NOT LIKE 't_acc_usage';

   IF (v_count > 0)
   THEN
      BEGIN
         INSERT INTO tmp_t_session_state
            SELECT state.id_sess
              FROM t_acc_usage au INNER JOIN t_session_state state
                   ON au.tx_uid = state.id_sess
                   INNER JOIN t_prod_view prod
                   ON au.id_view = prod.id_view
                 AND prod.b_can_resubmit_from = 'N'
             WHERE state.dt_end = v_maxtime
               AND au.id_usage_interval IN (SELECT DISTINCT id_interval
                                                       FROM t_usage_interval
                                                      WHERE tx_interval_status <>
                                                                           'H');
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000003-archive_queues operation failed-->Error in populating tmp_t_session_state';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   v_count := 0;                                  /*Delete from t_svc tables*/

   OPEN c1 FOR
      SELECT nm_table_name
        FROM t_service_def_log;

   LOOP
      FETCH c1
       INTO v_tab1;

      EXIT WHEN c1%NOTFOUND;

      BEGIN
         IF table_exists ('tmp_svc')
         THEN
            EXECUTE IMMEDIATE 'drop table tmp_svc';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000005--archive_queues operation failed-->error in dropping tmp_svc table';
            ROLLBACK;

            CLOSE c1;

            RETURN;
      END;

      BEGIN
         v_sql1 :=
               'create table tmp_svc as select svc.* from '
            || v_tab1
            || ' svc in
ner join tmp_t_session_state au
									on svc.id_source_sess = au.id_sess';

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000006-archive_queues operation failed-->Error in t_svc Delete operation';
            ROLLBACK;

            CLOSE c1;

            RETURN;
      END;

      BEGIN
         EXECUTE IMMEDIATE 'truncate table ' || v_tab1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000007-archive_queues operation failed-->Error in t_svc Delete operation';
            ROLLBACK;

            CLOSE c1;

            RETURN;
      END;

      v_sql1 := 'insert into ' || v_tab1 || ' select * from tmp_svc';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000008-archive_queues operation failed-->Error in t_svc Delete operation';
            ROLLBACK;

            CLOSE c1;

            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_queue
                     (id_svc, status, tt_start, tt_end
                     )
              VALUES (v_tab1, 'A', v_vartime, v_maxtime
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000009-archive_queues operation failed-->Error in insert t_archive table';
            ROLLBACK;

            CLOSE c1;

            RETURN;
      END;
   END LOOP;

   CLOSE c1;
/*Delete from t_session, t_session_state, t_session_set and t_message tables table*/

   BEGIN
      IF table_exists ('tmp_t_session')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp_t_session';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000010A--archive_queues operation failed-->error in dropping tmp_t_session';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'insert into tmp_t_session
					select * from t_session where id_source_sess
					in (select id_sess from tmp_t_session_state)';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000010-archive_queues operation failed-->Error in insert into tmp_t_session';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'truncate table t_session';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000011-archive_queues operation failed-->Error in Delete from t_session';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      INSERT INTO t_session
         SELECT *
           FROM tmp_t_session;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000012-archive_queues operation failed-->Error in insert into t_session';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      IF table_exists ('tmp_t_session_set')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp_t_session_set';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000013A--archive_queues operation failed-->error in dropping tmp_t_session_set';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'Insert into tmp_t_session_set select * from t_session_set where id_ss in
					(select id_ss from t_session)';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000013-archive_queues operation failed-->Error in insert into tmp_t_session_set';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'truncate table t_session_set';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000014-archive_queues operation failed-->Error in Delete from t_session_set';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      INSERT INTO t_session_set
         SELECT *
           FROM tmp_t_session_set;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000015-archive_queues operation failed-->Error in insert into t_session_set';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      IF table_exists ('tmp_t_message')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp_t_message';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000016a--archive_queues operation failed-->error in dropping tmp_t_message';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'Insert into tmp_t_message select * from t_message where id_message in
					(select id_message from t_session_set)';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000016-archive_queues operation failed-->Error in insert into tmp_t_message';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'truncate table t_message';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000017-archive_queues operation failed-->Error in Delete from t_message';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      INSERT INTO t_message
         SELECT *
           FROM tmp_t_message;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000018-archive_queues operation failed-->Error in insert into t_message';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      IF table_exists ('tmp2_t_session_state')
      THEN
         EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000019a--archive_queues operation failed-->error in dropping tmp2_t_session_state';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'Insert into tmp2_t_session_state 
  			select state.* from t_session_state state  
  			where state.id_sess in  
  			(select id_sess from tmp_t_session_state)';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000019-archive_queues operation failed-->Error in insert into tmp2_t_session_state';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'truncate table t_session_state';
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000020-archive_queues operation failed-->Error in Delete from t_session_state table';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      INSERT INTO t_session_state
         SELECT *
           FROM tmp2_t_session_state;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '7000021-archive_queues operation failed-->Error in insert into t_session_state table';
         ROLLBACK;
         RETURN;
   END;

   IF table_exists ('tmp_t_session_state')
   THEN
      EXECUTE IMMEDIATE 'truncate table tmp_t_session_state';
   END IF;

   IF table_exists ('tmp2_t_session_state')
   THEN
      EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
   END IF;

   IF table_exists ('tmp_t_session')
   THEN
      EXECUTE IMMEDIATE 'truncate table tmp_t_session';
   END IF;

   IF table_exists ('tmp_t_session_set')
   THEN
      EXECUTE IMMEDIATE 'truncate table tmp_t_session_set';
   END IF;

   IF table_exists ('tmp_t_message')
   THEN
      EXECUTE IMMEDIATE 'truncate table tmp_t_message';
   END IF;

   IF table_exists ('tmp_svc')
   THEN
      EXECUTE IMMEDIATE 'drop table tmp_svc';
   END IF;

   IF (p_update_stats = 'Y')
   THEN
      SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER')
        INTO v_user_name
        FROM DUAL;

      OPEN c1 FOR
         SELECT nm_table_name
           FROM t_service_def_log;

      LOOP
         FETCH c1
          INTO v_tab1;

         EXIT WHEN c1%NOTFOUND;

         IF (p_sampling_ratio < 5)
         THEN
            v_nu_varstatpercentchar := 5;
         ELSIF (p_sampling_ratio >= 100)
         THEN
            v_nu_varstatpercentchar := 100;
         ELSE
            v_nu_varstatpercentchar := p_sampling_ratio;
         END IF;

         v_sql1 :=
               'begin dbms_stats.gather_table_stats(ownname=> '''
            || v_user_name
            || ''',
                 tabname=> '''
            || v_tab1
            || ''', estimate_percent=> '
            || v_nu_varstatpercentchar
            || ',
                 cascade=> TRUE); end;';

         BEGIN
            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '7000022-archive_queues operation failed-->Error in update stats';
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      CLOSE c1;

      v_sql1 :=
            'begin dbms_stats.gather_table_stats( 
 				ownname=> '''
         || v_user_name
         || ''',tabname=> ''T_SESSION'', 
 				estimate_percent=> '
         || v_nu_varstatpercentchar
         || ',cascade=> TRUE); end;';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000023-archive_queues operation failed-->Error in t_session update stats';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
            'begin dbms_stats.gather_table_stats( 
 				ownname=> '''
         || v_user_name
         || ''',tabname=> ''T_SESSION_SET'', 
 				estimate_percent=> '
         || v_nu_varstatpercentchar
         || ',cascade=> TRUE); end;';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000024-archive_queues operation failed-->Error in t_session_set update stats';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
            'begin dbms_stats.gather_table_stats( 
 				ownname=> '''
         || v_user_name
         || ''',tabname=> ''T_SESSION_STATE'', 
 				estimate_percent=> '
         || v_nu_varstatpercentchar
         || ',cascade=> TRUE); end;';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000025-archive_queues operation failed-->Error in t_session_state update stats';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
            'begin dbms_stats.gather_table_stats( 
 				ownname=> '''
         || v_user_name
         || ''',tabname=> ''T_MESSAGE'', 
 				estimate_percent=> '
         || v_nu_varstatpercentchar
         || ',cascade=> TRUE); end;';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '7000026-archive_queues operation failed-->Error in t_message update stats';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-archive_queue operation successful';
   COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE archive_trash (
   p_partition             NVARCHAR2 DEFAULT NULL,
   p_intervalid            INT,
   p_accountidlist         VARCHAR2,
   p_result          OUT   VARCHAR2
)
AS
/*        How to run this stored procedure    DECLARE      P_PARTITION NVARCHAR2(200);      P_INTERVALID NUMBER;      p_accountIDList varchar2(2000);      P_RESULT VARCHAR2(200);    BEGIN      p_accountIDList := null;      P_PARTITION := 'HS_20070131';      P_INTERVALID := null;      P_RESULT := NULL;       ARCHIVE_trash ( P_PARTITION, P_INTERVALID,p_accountIDList, P_RESULT );      DBMS_OUTPUT.PUT_LINE(P_RESULT);      COMMIT;    END;    or    DECLARE      P_PARTITION NVARCHAR2(200);      P_INTERVALID NUMBER;      p_accountIDList varchar2(2000);      P_RESULT VARCHAR2(200);    BEGIN      p_accountIDList := null;      P_PARTITION := null;      P_INTERVALID := 885653507;      P_RESULT := NULL;       ARCHIVE_trash ( P_PARTITION, P_INTERVALID,p_accountIDList, P_RESULT );      DBMS_OUTPUT.PUT_LINE(P_RESULT);      COMMIT;    END;    */
   v_sql1            VARCHAR2 (4000);
   v_tab1            NVARCHAR2 (1000);
   v_var1            NVARCHAR2 (1000);
   v_vartime         DATE;
   v_maxtime         DATE;
   v_dbname          NVARCHAR2 (100);
   v_count           NUMBER (10)      := 0;
   v_accountidlist   VARCHAR2 (4000)  := p_accountidlist;
   c1                sys_refcursor;
   c2                sys_refcursor;
   v_dummy3          VARCHAR2 (2000);
   dummy_cur         sys_refcursor;
   v_ind             NVARCHAR2 (2000);
   interval_id       sys_refcursor;
   v_cur             sys_refcursor;
   v_interval        INT;
   v_partname        VARCHAR2 (30);
   v_dummy           VARCHAR2 (1);
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate;
/*Checking the following Business rules */
              /* Either Partition or IntervalId/AccountId can be specified */

   IF (   (p_partition IS NOT NULL AND p_intervalid IS NOT NULL)
       OR (p_partition IS NULL AND p_intervalid IS NULL)
       OR (p_partition IS NOT NULL AND p_accountidlist IS NOT NULL)
      )
   THEN
      p_result :=
         '3000001-archive_trash operation failed-->Either Partition or Interval/AccountId should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN                /*partition should be already archived or Dearchived */
      SELECT COUNT (1)
        INTO v_count
        FROM t_archive_partition
       WHERE partition_name = p_partition
         AND status IN ('A', 'D')
         AND tt_end = v_maxtime;

      IF (v_count = 0)
      THEN
         p_result :=
            '3000002-trash operation failed-->partition is not already archived/dearchived';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;
             /* partition should have atleast 1 Interval that is dearchived */

      SELECT COUNT (*)
        INTO v_count
        FROM t_archive
       WHERE status = 'D'
         AND tt_end = v_maxtime
         AND id_interval IN (SELECT id_interval
                               FROM t_partition_interval_map MAP INNER JOIN t_partition part
                                    ON MAP.id_partition = part.id_partition
                              WHERE part.partition_name = p_partition);

      IF (v_count = 0)
      THEN
         p_result :=
            '3000002a-trash operation failed-->none of the intervals of partition is dearchived';
         ROLLBACK;
         RETURN;
      END IF;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN
      v_count := 0;
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition
				in (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;

      LOOP
         FETCH interval_id
          INTO v_interval;

         EXIT WHEN interval_id%NOTFOUND;

         OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                     || v_interval;

         IF table_exists ('tmp_id_view')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_id_view');
         END IF;

         INSERT INTO tmp_id_view
            SELECT DISTINCT id_view
                       FROM t_acc_usage
                      WHERE id_usage_interval = v_interval;

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;

            FOR i IN
               (SELECT nm_table_name
                  FROM t_prod_view
                 WHERE id_view = v_var1)
                                      /*and nm_table_name not like '%temp%'*/
            LOOP
               v_tab1 := i.nm_table_name;
            END LOOP;

            BEGIN                          /*Delete from product view tables*/
               v_sql1 :=
                     'select partition_name from user_tab_partitions where table_name = upper('''
                  || v_tab1
                  || ''')
                  and tablespace_name = '''
                  || p_partition
                  || '''';

               EXECUTE IMMEDIATE v_sql1
                            INTO v_dummy3;

               v_sql1 :=
                  'alter table ' || v_tab1 || ' truncate partition '
                  || v_dummy3;
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000003-archive trash operation failed-->Error in product view Delete operation';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;

            v_sql1 :=
                  'select index_name from user_indexes where table_name = upper('''
               || v_tab1
               || ''')
            AND partitioned = ''NO'' and status <> ''VALID''';

            OPEN dummy_cur FOR v_sql1;

            LOOP
               FETCH dummy_cur
                INTO v_ind;

               EXIT WHEN dummy_cur%NOTFOUND;

               BEGIN
                  v_sql1 := 'alter index ' || v_ind || ' rebuild';
                  exec_ddl (v_sql1);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_result :=
                        '3000003a-archive trash operation failed--->Error in product view index rebuild operation';
                     ROLLBACK;

                     CLOSE dummy_cur;

                     CLOSE c1;

                     RETURN;
               END;
            END LOOP;

            CLOSE dummy_cur;
         END LOOP;

         CLOSE c1;

         v_count := 0;

         IF table_exists ('tmp_adjustment')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_adjustment');
         END IF;

         OPEN c2 FOR 'select table_name from user_tables where
        upper(table_name) like ''T_AJ_%'' and table_name not in (''T_AJ_TEMPLATE_REASON_CODE_MAP'',''T_AJ_TYPE_APPLIC_MAP'')';

         LOOP
            FETCH c2
             INTO v_var1;

            EXIT WHEN c2%NOTFOUND;
            v_sql1 :=
                  'select count(1) from '
               || v_var1
               || ' where id_adjustment in
                (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
               || CAST (v_interval AS VARCHAR2)
               || ')';

            OPEN v_cur FOR v_sql1;

            FETCH v_cur
             INTO v_count;

            CLOSE v_cur;

            IF v_count > 0
            THEN
               INSERT INTO tmp_adjustment
                    VALUES (v_var1);
            END IF;
         END LOOP;

         CLOSE c2;

         IF table_exists ('tmp_t_adjustment_transaction')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_t_adjustment_transaction');
         END IF;

         v_sql1 :=
               'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM t_adjustment_transaction where id_usage_interval= '
            || CAST (v_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;

         OPEN c1 FOR 'select distinct name from tmp_adjustment';

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;               /*Delete from t_aj tables */

            BEGIN
               v_sql1 :=
                     'delete FROM '
                  || v_var1
                  || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp where aj.id_adjustment = tmp.id_adj_trx)';

               EXECUTE IMMEDIATE (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000004-archive operation failed-->Error in t_aj tables Delete operation';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE c1;              /*Delete from t_adjustment_transaction table*/

         BEGIN
            DELETE FROM t_adjustment_transaction
                  WHERE id_usage_interval = v_interval;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000005-Error in Delete from t_adjustment_transaction table';
               ROLLBACK;
               RETURN;
         END;
 /*Checking for post bill adjustments that have corresponding usage archived*/

         IF table_exists ('tmp_t_adjust_txn_temp')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_t_adjust_txn_temp');
         END IF;

         BEGIN
            INSERT INTO tmp_t_adjust_txn_temp
               SELECT id_sess
                 FROM t_adjustment_transaction
                WHERE n_adjustmenttype = 1
                  AND id_sess IN (SELECT id_sess
                                    FROM t_acc_usage
                                   WHERE id_usage_interval = v_interval);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000006-archive operation failed-->Error in create adjustment temp table operation';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (*)
           INTO v_count
           FROM tmp_t_adjust_txn_temp;

         IF (v_count > 0)
         THEN
            BEGIN
               UPDATE t_adjustment_transaction
                  SET archive_sess = id_sess,
                      id_sess = NULL
                WHERE id_sess IN (SELECT id_sess
                                    FROM tmp_t_adjust_txn_temp);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000007-archive operation failed-->Error in Update adjustment operation';
                  ROLLBACK;
                  RETURN;
            END;
         END IF;                             /*Delete from t_acc_usage table*/

         BEGIN
            v_dummy3 := '';
            v_sql1 :=
                  'select partition_name from user_tab_partitions where table_name = ''T_ACC_USAGE''
            and tablespace_name = '''
               || p_partition
               || '''';

            EXECUTE IMMEDIATE v_sql1
                         INTO v_dummy3;

            v_sql1 :=
                     'alter table t_acc_usage truncate partition ' || v_dummy3;
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000008-archive operation failed-->Error in Delete t_acc_usage operation';
               ROLLBACK;
               RETURN;
         END;

         v_sql1 :=
            'select index_name from user_indexes where table_name = ''T_ACC_USAGE''
        AND partitioned = ''NO'' and status <> ''VALID''';

         OPEN dummy_cur FOR v_sql1;

         LOOP
            FETCH dummy_cur
             INTO v_ind;

            EXIT WHEN dummy_cur%NOTFOUND;

            BEGIN
               v_sql1 := 'alter index ' || v_ind || ' rebuild';
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000008a-archive operation failed-->Error in Usage index rebuild operation';
                  ROLLBACK;

                  CLOSE dummy_cur;

                  RETURN;
            END;
         END LOOP;

         CLOSE dummy_cur;

         BEGIN
            UPDATE t_archive
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_interval = v_interval
               AND status = 'D'
               AND tt_end = v_maxtime;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000009-archive operation failed-->Error in update t_archive table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive
               SELECT v_interval, id_view, adj_name, 'A', v_vartime,
                      v_maxtime
                 FROM t_archive
                WHERE id_interval = v_interval
                  AND status = 'D'
                  AND tt_end = dbo.subtractsecond (v_vartime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000010-archive operation failed-->Error in insert t_archive table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            UPDATE t_acc_bucket_map
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_usage_interval = v_interval
               AND status = 'D'
               AND tt_end = dbo.mtmaxdate;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000011-archive operation failed-->Error in update t_acc_bucket_map table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            INSERT INTO t_acc_bucket_map
               SELECT v_interval, id_acc, bucket, 'A', v_vartime, v_maxtime
                 FROM t_acc_bucket_map
                WHERE id_usage_interval = v_interval
                  AND status = 'D'
                  AND tt_end = dbo.subtractsecond (v_vartime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000012-archive operation failed-->Error in insert into t_acc_bucket_map table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;
      END LOOP;

      CLOSE interval_id;

      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = p_partition
            AND tt_end = v_maxtime
            AND status = 'D';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012a-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (p_partition, 'A', v_vartime, v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012b-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'N'
          WHERE partition_name = p_partition;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012c-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   IF (p_intervalid IS NOT NULL)
   THEN
      v_count := 0;             /*      Interval should be already archived*/

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = p_intervalid
         AND status IN ('A', 'D')
         AND tt_end = dbo.mtmaxdate;

      IF v_count = 0
      THEN
         p_result :=
            '30000013-trash operation failed-->Interval is not already archived/dearchived';
         RETURN;
      END IF;

      IF table_exists ('tmp_accountidstable')
      THEN
         BEGIN
            EXECUTE IMMEDIATE ('delete from tmp_accountidstable');
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;
/* This is to populate the temp table with all the accounts that needs to be deleted */

      IF (v_accountidlist IS NOT NULL)
      THEN
         WHILE INSTR (v_accountidlist, ',') > 0
         LOOP
            INSERT INTO tmp_accountidstable
                        (ID)
               SELECT SUBSTR (v_accountidlist,
                              1,
                              (INSTR (v_accountidlist, ',') - 1)
                             )
                 FROM DUAL;

            v_accountidlist :=
               SUBSTR (v_accountidlist,
                       (INSTR (v_accountidlist, ',') + 1),
                       (  LENGTH (v_accountidlist)
                        - (INSTR (v_accountidlist, ','))
                       )
                      );
         END LOOP;

         INSERT INTO tmp_accountidstable
                     (ID
                     )
              VALUES (v_accountidlist
                     );
      ELSE
         v_sql1 :=
               'insert into tmp_AccountIDsTable(ID) select distinct id_acc from t_acc_usage where id_usage_interval = '
            || CAST (p_intervalid AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = p_intervalid
         AND status = 'D'
         AND tt_end = dbo.mtmaxdate;

      IF v_count = 0
      THEN
         p_result :=
            '3000014-trash operation failed-->account in the list is not dearchived';
         ROLLBACK;
         RETURN;
      END IF;

      IF table_exists ('tmp_t_acc_usage')
      THEN
         BEGIN
            EXECUTE IMMEDIATE 'delete from tmp_t_acc_usage';
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF table_exists ('tmp_t_adjustment_transaction')
      THEN
         BEGIN
            EXECUTE IMMEDIATE 'delete from tmp_t_adjustment_transaction';
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      EXECUTE IMMEDIATE    'insert into tmp_t_acc_usage
        SELECT id_sess,id_usage_interval,id_acc  FROM t_acc_usage where id_usage_interval='
                        || CAST (p_intervalid AS VARCHAR2)
                        || ' and id_acc in (select id from tmp_AccountIDsTable)';

      OPEN c1 FOR    'select distinct id_view from t_acc_usage
        where id_usage_interval = '
                  || p_intervalid;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1)
                                     /*and nm_table_name not like '%temp%' */
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;                         /*Delete from product view tables*/

         BEGIN
            v_sql1 :=
                  'delete '
               || v_tab1
               || ' pv where exists (select 1 from
                              tmp_t_acc_usage tmp where pv.id_sess = tmp.id_sess)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000015-trash operation failed-->Error in PV Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_usage
       WHERE id_usage_interval = p_intervalid
         AND id_acc NOT IN (SELECT ID
                              FROM tmp_accountidstable);

      IF (v_count = 0)
      THEN
         EXECUTE IMMEDIATE 'delete from tmp_id_view';

         INSERT INTO tmp_id_view
            SELECT DISTINCT id_view
                       FROM t_acc_usage
                      WHERE id_usage_interval = p_intervalid;

         EXECUTE IMMEDIATE    'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM
            t_adjustment_transaction where id_usage_interval='
                           || CAST (p_intervalid AS VARCHAR2);

         OPEN c1 FOR
            SELECT table_name
              FROM user_tables
             WHERE UPPER (table_name) LIKE 'T_AJ_%'
               AND table_name NOT IN
                      ('T_AJ_TEMPLATE_REASON_CODE_MAP',
                       'T_AJ_TYPE_APPLIC_MAP');

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;
             /*Get the name of t_aj tables that have usage in this interval*/
            v_count := 0;
            v_sql1 :=
                  'select count(1) from '
               || v_var1
               || ' where id_adjustment in (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
               || CAST (p_intervalid AS VARCHAR2)
               || ')';

            OPEN c2 FOR v_sql1;

            FETCH c2
             INTO v_count;

            CLOSE c2;

            IF v_count > 0
            THEN
               INSERT INTO tmp_adjustment
                    VALUES (v_var1);
            END IF;
         END LOOP;

         CLOSE c1;

         OPEN c1 FOR 'select distinct name from tmp_adjustment';

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;                /*Delete from t_aj tables*/
            v_sql1 :=
                  'delete '
               || v_var1
               || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp
                        where aj.id_adjustment = tmp.id_adj_trx)';

            BEGIN
               EXECUTE IMMEDIATE v_sql1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '30000016-trash operation failed-->Error in Delete from t_aj tables';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE c1;            /* Delete from t_adjustment_transaction table */

         BEGIN
            DELETE FROM t_adjustment_transaction
                  WHERE id_usage_interval = p_intervalid;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '30000017-Error in Delete from t_adjustment_transaction table';
               ROLLBACK;
               RETURN;
         END;
 /*Checking for post bill adjustments that have corresponding usage archived*/

         IF table_exists ('tmp_t_adjust_txn_temp')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_t_adjust_txn_temp');
         END IF;

         BEGIN
            INSERT INTO tmp_t_adjust_txn_temp
               SELECT id_sess
                 FROM t_adjustment_transaction
                WHERE n_adjustmenttype = 1
                  AND id_sess IN (SELECT id_sess
                                    FROM t_acc_usage
                                   WHERE id_usage_interval = p_intervalid);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '30000018-archive operation failed-->Error in create adjustment temp table operation';
               ROLLBACK;
               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_t_adjust_txn_temp;

         IF (v_count > 0)
         THEN
            BEGIN
               UPDATE t_adjustment_transaction
                  SET archive_sess = id_sess,
                      id_sess = NULL
                WHERE id_sess IN (SELECT id_sess
                                    FROM tmp_t_adjust_txn_temp);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000019-trash operation failed-->Error in Update adjustment operation';
                  ROLLBACK;
                  RETURN;
            END;
         END IF;

         BEGIN
            UPDATE t_archive
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_interval = p_intervalid
               AND status = 'D'
               AND tt_end = dbo.mtmaxdate;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000020-trash operation failed-->error in update t_acc_bucket_map';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive
               SELECT p_intervalid, id_view, NULL, 'A', v_vartime, v_maxtime
                 FROM tmp_id_view
               UNION ALL
               SELECT DISTINCT p_intervalid, NULL, NAME, 'A', v_vartime,
                               v_maxtime
                          FROM tmp_adjustment;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000021-trash operation failed-->error in insert into t_acc_bucket_map';
               ROLLBACK;
               RETURN;
         END;
      END IF;                              /* Delete from t_acc_usage table */

      BEGIN
         DELETE      t_acc_usage au
               WHERE EXISTS (SELECT 1
                               FROM tmp_t_acc_usage tmp
                              WHERE au.id_sess = tmp.id_sess);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000022-trash operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_acc_bucket_map
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_usage_interval = p_intervalid
            AND id_acc IN (SELECT ID
                             FROM tmp_accountidstable)
            AND status = 'D'
            AND tt_end = v_maxtime;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000023-trash operation failed-->error in update t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_acc_bucket_map
                     (id_usage_interval, id_acc, bucket, status, tt_start,
                      tt_end)
            SELECT p_intervalid, ID, bucket, 'A', v_vartime, v_maxtime
              FROM tmp_accountidstable tmp INNER JOIN t_acc_bucket_map act
                   ON tmp.ID = act.id_acc
                 AND act.id_usage_interval = p_intervalid
                 AND act.status = 'D'
                 AND tt_end = dbo.subtractsecond (v_vartime)
                   ;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
            p_result :=
               '3000024-trash operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;

      v_count := 0;

      SELECT b_partitioning_enabled
        INTO v_dummy
        FROM t_usage_server;

      IF (v_dummy = 'Y')
      THEN
         SELECT partition_name
           INTO v_partname
           FROM t_partition_interval_map MAP INNER JOIN t_partition part
                ON MAP.id_partition = part.id_partition
          WHERE id_interval = p_intervalid;

         SELECT COUNT (*)
           INTO v_count
           FROM t_partition part INNER JOIN t_partition_interval_map MAP
                ON part.id_partition = MAP.id_partition
              AND part.partition_name = v_partname
                INNER JOIN t_archive_partition back
                ON part.partition_name = back.partition_name
              AND back.status = 'D'
              AND tt_end = v_maxtime
              AND MAP.id_interval NOT IN (
                                    SELECT id_interval
                                      FROM t_archive
                                     WHERE status <> 'A'
                                           AND tt_end = v_maxtime)
                ;
      END IF;

      IF (v_count > 0)
      THEN
         BEGIN
            UPDATE t_archive_partition
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE partition_name = v_partname
               AND tt_end = v_maxtime
               AND status = 'D';
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000025-archive operation failed-->Error in update t_archive_partition table';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive_partition
                 VALUES (v_partname, 'A', v_vartime, v_maxtime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000026-archive operation failed-->Error in insert into t_archive_partition table';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            UPDATE t_partition
               SET b_active = 'N'
             WHERE partition_name = v_partname;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000027-archive operation failed-->Error in update t_partition table';
               ROLLBACK;
               RETURN;
         END;
      END IF;
   END IF;

   p_result := '0-archive_trash operation successful';
   COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE checkaccountcreationbusinessru (
   p_nm_space            NVARCHAR2,
   p_acc_type            VARCHAR2,
   p_id_ancestor         INT,
   status          OUT   INT
)
AS
   tx_typ_space   VARCHAR (40);
BEGIN
/* 1. check account and its ancestor business rules.    if the account being created belongs to a hierarchy, then it should not    have system_user or system_auth namespace      */
   FOR i IN (SELECT tx_typ_space
               INTO tx_typ_space
               FROM t_namespace
              WHERE nm_space = p_nm_space)
   LOOP
      tx_typ_space := i.tx_typ_space;
   END LOOP;

   IF (tx_typ_space IN
          ('system_user',
           'system_auth',
           'system_mcm',
           'system_ops',
           'system_rate',
           'system_csr'
          )
      )
   THEN
  /* An account with this account type and namespace cannot be       created*/
      IF (LOWER (p_acc_type) NOT IN ('systemaccount'))
      THEN   /* MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)*/
         status := -486604732;
         RETURN;
      END IF;
   END IF;
/* If an account is not a subscriber or an independent account    and its namespace is system_mps, that shouldnt be allowed either*/

   IF (LOWER (tx_typ_space) = 'system_mps')
   THEN
      IF (LOWER (p_acc_type) IN ('systemaccount'))
      THEN   /* MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)*/
         status := -486604732;
         RETURN;
      END IF;
   END IF;

   status := 1;
END;
/

CREATE OR REPLACE PROCEDURE filtersortquery_v2 (
   p_stagingdbname         VARCHAR2,
   p_tablename             VARCHAR2,
   p_innerquery            NCLOB,
   p_orderbytext           VARCHAR2,
   p_startrow              NUMBER,
   p_numrows               NUMBER,
   p_totalrows       OUT   sys_refcursor,
   p_rows            OUT   sys_refcursor
)
AUTHID CURRENT_USER
AS
   p_sql   VARCHAR2 (30000);
BEGIN /* Create a temp table with all the selected records after the filter */
   p_sql :=
         'create table '
      || p_stagingdbname
      || '.'
      || p_tablename
      || ' as '
      || '( '
      || p_innerquery
      || ')';
   exec_ddl (p_sql); /* Get the total number of records after the filter */
   p_sql :=
         'select count(*) as TotalRows from '
      || p_stagingdbname
      || '.'
      || p_tablename;

   OPEN p_totalrows FOR p_sql; /* If the results are to be paged, apply the page filter */

   IF p_numrows > 0
   THEN
      p_sql :=
            'select * from ( select rownum row_num, A.* from (select * from '
         || p_stagingdbname
         || '.'
         || p_tablename
         || ' '
         || p_orderbytext
         || ') A where rownum <= '
         || (p_startrow + p_numrows)
         || ') where row_num >= '
         || p_startrow;
   ELSE
      p_sql :=
            'select * from '
         || p_stagingdbname
         || '.'
         || p_tablename
         || ' '
         || p_orderbytext;
   END IF; /* Populate the results set */

   OPEN p_rows FOR p_sql; /* Drop the temp table to clean up */

   exec_ddl ('drop table ' || p_stagingdbname || '.' || p_tablename);
END;
/

CREATE OR REPLACE PROCEDURE updatedataforstringtoenum (
   p_table         VARCHAR2,
   p_column        VARCHAR2,
   p_enum_string   VARCHAR2
)
AS
   inclusion   VARCHAR2 (4000);
   upd         VARCHAR2 (4000);
   fqenumval   VARCHAR2 (4000);
   cnt         INT;
BEGIN
   fqenumval := '''' || p_enum_string || '/'' || ' || p_column;
       /* all values in the string column must be found in the t_enum_data */
   inclusion :=
         '
        select sum(case when mydata is null then 0 else 1 end)
        from (
          select distinct '
      || fqenumval
      || ' as mydata
          from '
      || p_table
      || '
          ) data
        where not exists  (
          select 1
          from t_enum_data
          where nm_enum_data = data.mydata
          )';

   EXECUTE IMMEDIATE inclusion
                INTO cnt;

   IF cnt > 0
   THEN
      raise_application_error (-20000,
                                  'Invalid enum values in table '
                               || p_table
                               || ', column '
                               || p_column
                              );
   END IF;

   upd :=
         '
      update '
      || p_table
      || ' set
        '
      || p_column
      || ' = (select id_enum_data
                from t_enum_data
                where nm_enum_data = '
      || fqenumval
      || ')
      where exists (
                select 1
                from t_enum_data
                where nm_enum_data = '
      || fqenumval
      || ')';

   EXECUTE IMMEDIATE upd;
END;
/

CREATE OR REPLACE PROCEDURE dearchive_account (
   p_interval              INT,
   p_accountidlist         VARCHAR2,
   p_path                  VARCHAR2,
   p_constraint            CHAR DEFAULT 'Y',
   p_result          OUT   VARCHAR2
)
AS
   v_change          VARCHAR2 (4000);
   v_c_id            NUMBER (10);
   v_count           NUMBER           := 0;
   v_sql1            VARCHAR2 (4000);
   v_sql2            VARCHAR2 (4000);
   v_tab1            VARCHAR2 (1000);
   v_tab2            VARCHAR2 (1000);
   v_var1            VARCHAR2 (100);
   v_var2            NUMBER (10);
   v_str1            VARCHAR2 (1000);
   v_str2            VARCHAR2 (2000);
   v_bucket          INT;
   v_dbname          VARCHAR2 (100);
   v_vartime         DATE             := SYSDATE;
   v_maxtime         DATE             := dbo.mtmaxdate;
   v_accountidlist   VARCHAR2 (4000)  := p_accountidlist;
   c1                sys_refcursor;
   c2                sys_refcursor;
   c3                sys_refcursor;
   v_filename        VARCHAR2 (128);
   v_i               NUMBER (10);
   v_file            VARCHAR2 (2000);
   vexists           BOOLEAN;
   vfile_length      INT;
   vblocksize        INT;
   v_table_name      VARCHAR2 (30);
   v_dir_name        VARCHAR2 (30);
   v_partition       NVARCHAR2 (2000);
   v_dummy           VARCHAR2 (1);
   v_dummy1          NUMBER (10)      := 0;
BEGIN
/*         how to run this procedure DECLARE    P_INTERVALID NUMBER;   p_accountIDList varchar2(2000);   P_PATH VARCHAR2(200);   p_constraint VARCHAR2(1);   P_RESULT VARCHAR2(200);  BEGIN    P_INTERVALID := 885653507;   p_accountIDList := null;   P_PATH := 'HS_DIR';   p_constraint := 'Y';   P_RESULT := NULL;    DEARCHIVE_ACCOUNT (  P_INTERVALID,p_accountIDList, P_PATH,p_constraint, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END;  */
/*Checking following Business rules :      Interval should be archived      Account is in archived state      Verify the database name  */
   SELECT table_name
     INTO v_tab2
     FROM user_tables
    WHERE UPPER (table_name) = 'T_ACC_USAGE';

   IF (v_tab2 IS NULL)
   THEN
      p_result :=
               '5000001-dearchive operation failed-->check the database name';
      ROLLBACK;
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO v_count
     FROM t_archive
    WHERE id_interval = p_interval AND status = 'A' AND tt_end = v_maxtime;

   IF v_count = 0
   THEN
      p_result :=
              '5000002-dearchive operation failed-->Interval is not archived';
      ROLLBACK;
      RETURN;
   END IF;                                         /*TO GET LIST OF ACCOUNT */

   BEGIN
      exec_ddl ('truncate table tmp_AccountBucketsTable');
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;
/* This is to populate the temp table with all the accounts that needs to be dearchived */

   IF (v_accountidlist IS NOT NULL)
   THEN
      WHILE INSTR (v_accountidlist, ',') > 0
      LOOP
         BEGIN
            INSERT INTO tmp_accountbucketstable
                        (ID
                        )
                 VALUES (SUBSTR (v_accountidlist,
                                 1,
                                 (INSTR (v_accountidlist, ',') - 1)
                                )
                        );

            v_accountidlist :=
               SUBSTR (v_accountidlist,
                       (INSTR (v_accountidlist, ',') + 1),
                       (  LENGTH (v_accountidlist)
                        - (INSTR (v_accountidlist, ','))
                       )
                      );
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '5000003-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      BEGIN
         INSERT INTO tmp_accountbucketstable
                     (ID
                     )
              VALUES (v_accountidlist
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000004-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE tmp_accountbucketstable tmp
            SET bucket =
                   (SELECT act.bucket
                      FROM t_acc_bucket_map act
                     WHERE tmp.ID = act.id_acc
                       AND act.id_usage_interval = p_interval
                       AND act.status = 'A'
                       AND act.tt_end = v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000005-dearchive operation failed-->error in update tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;
   ELSE
      BEGIN
         INSERT INTO tmp_accountbucketstable
                     (ID, bucket)
            SELECT id_acc, bucket
              FROM t_acc_bucket_map
             WHERE status = 'A'
               AND tt_end = v_maxtime
               AND id_acc NOT IN (
                      SELECT DISTINCT id_acc
                                 FROM t_acc_usage
                                WHERE id_usage_interval =
                                            CAST (p_interval AS VARCHAR2 (20)))
               AND id_usage_interval = CAST (p_interval AS VARCHAR2 (20));
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000006-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM t_acc_bucket_map
    WHERE id_usage_interval = p_interval
      AND status = 'D'
      AND tt_end = v_maxtime
      AND id_acc IN (SELECT ID
                       FROM tmp_accountbucketstable);

   IF v_count > 0
   THEN
      p_result :=
         '5000007-dearchive operation failed-->one of the account is already dearchived';
      ROLLBACK;
      RETURN;
   END IF;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM tmp_accountbucketstable
    WHERE bucket IS NULL;

   IF v_count > 0
   THEN
      p_result :=
         '5000008-dearchive operation failed-->one of the account does not have bucket mapping...check the accountid';
      ROLLBACK;
      RETURN;
   END IF;

   OPEN c2 FOR 'select distinct bucket from tmp_AccountBucketsTable';

   LOOP
      FETCH c2
       INTO v_bucket;

      EXIT WHEN c2%NOTFOUND;
                    /*Checking the existence of import files for each table*/
      v_filename :=
            't_acc_usage'
         || '_'
         || CAST (p_interval AS VARCHAR2)
         || '_'
         || CAST (v_bucket AS VARCHAR2)
         || '.txt';               /* v_File := p_path || '\' || v_filename; */
      UTL_FILE.fgetattr (UPPER (p_path),
                         v_filename,
                         vexists,
                         vfile_length,
                         vblocksize
                        );

      IF NOT vexists
      THEN
         p_result :=
            '5000009-dearchive operation failed-->bcp usage file does not exist';

         CLOSE c2;

         RETURN;
      END IF;

      v_count := 0;
      v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

      SELECT COUNT (*)
        INTO v_count
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_count = 0)
      THEN
         p_result :=
            '5000009a-dearchive operation failed-->bcp usage exported table does not exist, external table missing';

         CLOSE c2;

         ROLLBACK;
         RETURN;
      END IF;

      SELECT default_directory_name
        INTO v_dir_name
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_dir_name <> p_path)
      THEN
         v_sql2 :=
            'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY ' || p_path;
         exec_ddl (v_sql2);
      END IF;

      OPEN c1 FOR    'select
 distinct id_view from t_archive where id_interval = '
                  || p_interval
                  || ' and tt_end = dbo.mtmaxdate and id_view is not null';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_filename :=
               'pv_'
            || v_var1
            || '_'
            || CAST (p_interval AS VARCHAR2)
            || '_'
            || CAST (v_bucket AS VARCHAR2)
            || '.txt';          /*select @File = p_path || '\' || v_filename*/
         UTL_FILE.fgetattr (UPPER (p_path),
                            v_filename,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF NOT vexists
         THEN
            p_result :=
                  '5000010-dearchive operation failed-->bcp '
               || v_filename
               || ' file does not exist';

            CLOSE c1;

            CLOSE c2;

            ROLLBACK;
            RETURN;
         END IF;

         v_count := 0;
         v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

         SELECT COUNT (*)
           INTO v_count
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_count = 0)
         THEN
            p_result :=
               '50000010a-dearchive operation failed-->bcp pv exported table does not exist, external table missing';

            CLOSE c1;

            CLOSE c2;

            ROLLBACK;
            RETURN;
         END IF;

         SELECT default_directory_name
           INTO v_dir_name
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_dir_name <> p_path)
         THEN
            v_sql2 :=
               'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY '
               || p_path;
            exec_ddl (v_sql2);
         END IF;
      END LOOP;

      CLOSE c1;
   END LOOP;

   CLOSE c2;

   v_count := 0;

   SELECT COUNT (id_adj_trx)
     INTO v_count
     FROM t_adjustment_transaction
    WHERE id_usage_interval = p_interval;

   IF v_count = 0
   THEN
      v_filename :=
               't_adj_trans' || '_' || CAST (p_interval AS VARCHAR2)
               || '.txt';      /*select @File = p_path || '\' || v_filename*/
      UTL_FILE.fgetattr (UPPER (p_path),
                         v_filename,
                         vexists,
                         vfile_length,
                         vblocksize
                        );

      IF NOT vexists
      THEN
         p_result :=
            '5000011-dearchive operation failed-->bcp t_adjustment_transaction file does not exist';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;
      v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

      SELECT COUNT (*)
        INTO v_count
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_count = 0)
      THEN
         p_result :=
            '50000011a-dearchive operation failed-->bcp t_adjustment_transaction exported table does not exist, external table missing';
         ROLLBACK;
         RETURN;
      END IF;

      SELECT default_directory_name
        INTO v_dir_name
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_dir_name <> p_path)
      THEN
         v_sql2 :=
            'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY ' || p_path;
         exec_ddl (v_sql2);
      END IF;

      OPEN c1 FOR
         SELECT DISTINCT adj_name
                    FROM t_archive
                   WHERE id_interval = p_interval
                     AND tt_end = v_maxtime
                     AND adj_name IS NOT NULL
                     AND status = 'A';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_sql1 :=
               'select id_view from t_prod_view where upper(nm_table_name) = 
upper(replace('''
            || v_var1
            || ''',''AJ'',''PV''))';

         EXECUTE IMMEDIATE v_sql1
                      INTO v_var2;

         v_filename :=
              'aj_' || v_var2 || '_' || CAST (p_interval AS VARCHAR2)
              || '.txt';        /*select @File = p_path || '\' || v_filename*/
         UTL_FILE.fgetattr (UPPER (p_path),
                            v_filename,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF NOT vexists
         THEN
            p_result :=
                  '5000012-dearchive operation failed-->bcp '
               || v_filename
               || ' file does not exist';

            CLOSE c1;

            ROLLBACK;
            RETURN;
         END IF;

         v_count := 0;
         v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

         SELECT COUNT (*)
           INTO v_count
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_count = 0)
         THEN
            p_result :=
               '50000012a-dearchive operation failed-->bcp t_aj exported table does not exist, external table missing';

            CLOSE c1;

            ROLLBACK;
            RETURN;
         END IF;

         SELECT default_directory_name
           INTO v_dir_name
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_dir_name <> p_path)
         THEN
            v_sql2 :=
               'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY '
               || p_path;
            exec_ddl (v_sql2);
         END IF;
      END LOOP;

      CLOSE c1;
   END IF;                                  /* Insert data into t_acc_usage */

   OPEN c2 FOR 'select distinct bucket from tmp_AccountBucketsTable';

   LOOP
      FETCH c2
       INTO v_bucket;

      EXIT WHEN c2%NOTFOUND;

      BEGIN
         EXECUTE IMMEDIATE ('delete from tmp_tmp_t_acc_usage');
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000012b--dearchive operation failed-->error in dropping tmp_tmp_t_acc_usage';
            ROLLBACK;
            RETURN;
      END;
/*select * into tmp_tmp_t_acc_usage from t_acc_usage where 0=1       if (@@error <> 0)       begin           set p_result = '5000012b-dearchive operation failed-->error in creating tmp_tmp_t_acc_usage'           rollback tran           return       end*/

      BEGIN
         v_sql1 :=
               'insert into tmp_tmp_t_acc_usage select * from t_acc_usage'
            || '_'
            || CAST (p_interval AS VARCHAR2)
            || '_'
            || CAST (v_bucket AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000013-dearchive operation failed-->error in usage bulk insert operation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
      END;
/*create unique clustered index idx_tmp_t_acc_usage on #tmp_t_acc_usage(id_sess)       create index idx1_tmp_t_acc_usage on #tmp_t_acc_usage(id_acc)*/

      IF (p_constraint = 'Y')
      THEN
         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_pi_template NOT IN (SELECT id_template
                                         FROM t_pi_template);

         IF v_count > 0
         THEN
            p_result :=
               '5000014-dearchive operation failed-->id_pi_template key violation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
         END IF;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_pi_instance NOT IN (SELECT id_pi_instance
                                         FROM t_pl_map);

         IF v_count > 0
         THEN
            p_result :=
               '5000015-dearchive operation failed-->id
_pi_instance key violation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
         END IF;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_view NOT IN (SELECT id_view
                                  FROM t_prod_view);

         IF v_count > 0
         THEN
            p_result :=
                 '5000016-dearchive operation failed-->id_view key violation';
            ROLLBACK;
            RETURN;
         END IF;
      END IF;

      INSERT INTO t_acc_usage
         SELECT *
           FROM tmp_tmp_t_acc_usage
          WHERE id_acc IN (SELECT ID
                             FROM tmp_accountbucketstable);
                                      /*Insert data into product view tables*/

      OPEN c1 FOR 'select distinct id_view from tmp_tmp_t_acc_usage where id_acc in
        (select id from tmp_AccountBucketsTable)';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN (SELECT nm_table_name
                     FROM t_prod_view
                    WHERE id_view = v_var1)
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         v_sql2 := 'tmp_' || v_bucket || '_' || v_var1;

         IF table_exists (v_sql2)
         THEN
            v_sql1 := 'drop table ' || v_sql2;
            exec_ddl (v_sql1);
         END IF;

         v_count := 0;
/* We have to check for the schame changes since the archiving was done and then use the old schema to import the data and then apply all the schema changes that happened*/

         SELECT COUNT (1)
           INTO v_count
           FROM t_query_log pv INNER JOIN t_archive arc
                ON pv.c_id_view = arc.id_view
              AND pv.c_id_view = v_var1
              AND pv.c_timestamp > arc.tt_start
              AND arc.id_interval = p_interval
              AND arc.status = 'E'
              AND NOT EXISTS (
                     SELECT 1
                       FROM t_archive arc1
                      WHERE arc.id_interval = arc1.id_interval
                        AND arc.id_view = arc1.id_view
                        AND arc1.status = 'E'
                        AND arc1.tt_start > arc.tt_start)
                ;

         IF v_count > 0
         THEN
            FOR i IN (SELECT   c_old_schema
                          FROM t_query_log pv INNER JOIN t_archive arc
                               ON pv.c_id_view = arc.id_view
                             AND pv.c_id_view = v_var1
                             AND pv.c_timestamp > arc.tt_start
                             AND arc.id_interval = p_interval
                             AND arc.status = 'E'
                             AND pv.c_old_schema IS NOT NULL
                      ORDER BY pv.c_timestamp, c_id)
            LOOP
               v_sql1 := i.c_old_schema;
               EXIT;
            END LOOP;

            BEGIN
               v_sql1 := REPLACE (v_sql1, v_tab1, 'tmp_' || v_var1);
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                        '5000017-dearchive operation failed-->error in creating temp pv table'
                     || v_tab1;
                  ROLLBACK;
                  RETURN;
            END;

            v_sql2 :=
               'select distinct c_query,c_id from t_query_log pv inner join t_archive
                arc on pv.c_id_view = arc.id_view
                and pv.c_id_view = v_var1
                and pv.c_timestamp > arc.tt_start
                and arc.id_interval = p_interval
                and arc.status =''E''
                and pv.c_query is not null
                order by c_id';
         ELSE
            v_sql1 :=
                  'create table tmp_'
               || v_bucket
               || '_'
               || v_var1
               || ' as select * from '
               || v_tab1
               || ' where 0=1';
            exec_ddl (v_sql1);
         END IF;

         BEGIN
            v_sql1 :=
                  'insert into tmp_'
               || v_bucket
               || '_'
               || v_var1
               || ' select * from pv_'
               || v_var1
               || '_'
               || CAST (p_interval AS VARCHAR2)
               || '_'
               || CAST (v_bucket AS VARCHAR2);

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000019-dearchive operation failed-->error in bulk insert operation for table '
                  || v_tab1;
               ROLLBACK;
               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM t_query_log pv INNER JOIN t_archive arc
                ON pv.c_id_view = arc.id_view
              AND pv.c_id_view = v_var1
              AND pv.c_timestamp > arc.tt_start
              AND arc.id_interval = p_interval
              AND arc.status = 'E'
                ;

         IF v_count > 0
         THEN
            OPEN c3 FOR v_sql1;

            LOOP
               FETCH c3
                INTO v_change, v_c_id;

               EXIT WHEN c3%NOTFOUND;
               v_change := REPLACE (v_change, v_tab1, 'tmp_' || v_var1);
               exec_ddl (v_change);
            END LOOP;

            CLOSE c3;
         END IF;

         BEGIN
            v_sql1 :=
                  'insert into '
               || v_tab1
               || ' select * from tmp_'
               || v_bucket
               || '_'
               || v_var1
               || ' where id_sess
                        in (select id_sess from tmp_tmp_t_acc_usage where id_acc in (select id from tmp_AccountBucketsTable))';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000020-dearchive operation failed-->error in insert into pv table from temp table '
                  || v_tab1;
               ROLLBACK;

               CLOSE c1;

               CLOSE c2;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;
   END LOOP;

   CLOSE c2;

   v_count := 0;

   SELECT COUNT (id_adj_trx)
     INTO v_count
     FROM t_adjustment_transaction
    WHERE id_usage_interval = p_interval;

   IF v_count = 0
   THEN                         /*Insert data into t_adjustment_transaction */
      BEGIN
         IF table_exists ('tmp2_t_adjustment_transaction')
         THEN
            exec_ddl ('drop table tmp2_t_adjustment_transaction');
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         exec_ddl
            ('create table tmp2_t_adjustment_transaction as select * from t_adjustment_transaction where 0=1'
            );
         v_sql1 :=
               'insert into tmp2_t_adjustment_transaction select * from t_adj_trans'
            || '_'
            || CAST (p_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000021-dearchive operation failed-->error in adjustment bulk insert operation';
            ROLLBACK;
            RETURN;
      END;
/*update t_adjustment_transaction to copy data from archive_sess to id_sess if usage is already in t_acc_usage*/

      BEGIN
         v_sql1 :=
            'UPDATE tmp2_t_adjustment_transaction trans
            SET id_sess = archive_sess,
                archive_sess = NULL
          WHERE trans.id_sess IS NULL
            AND EXISTS (SELECT 1
                          FROM t_acc_usage au
                         WHERE trans.archive_sess = au.id_sess)';

         EXECUTE IMMEDIATE (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000022-dearchive operation failed-->error in update adjustment transaction';
            ROLLBACK;
            RETURN;
      END;
/*This update is to cover the scenario if post bill adjustments are archived before usage and now dearchive before usage interval */

      BEGIN
         v_sql1 :=
               'UPDATE tmp2_t_adjustment_transaction trans
            SET archive_sess = id_sess,
                id_sess = NULL
          WHERE NOT EXISTS (SELECT 1
                              FROM t_acc_usage au
                             WHERE au.id_sess = trans.id_sess)
            AND trans.archive_sess IS NULL /* and n_adjustmenttype = 1 */
            AND id_usage_interval = '
            || p_interval;

         EXECUTE IMMEDIATE (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
            p_result :=
               '5000023-dearchive operation failed-->error in update adjustment transaction';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
         'INSERT INTO t_adjustment_transaction
         SELECT *
           FROM tmp2_t_adjustment_transaction';
                                              /*Insert data into t_aj tables*/

      EXECUTE IMMEDIATE (v_sql1);

      v_sql1 :=
            'select distinct adj_name from t_archive
        where id_interval = '
         || p_interval
         || ' and tt_end = dbo.mtmaxdate and adj_name is not null and status=''A''';

      OPEN c1 FOR v_sql1;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_sql1 :=
               'insert into '
            || v_var1
            || ' select * from aj_'
            || v_var2
            || '_'
            || CAST (p_interval AS VARCHAR2);

         BEGIN
            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000024-dearchive operation failed-->error in bulk insert operation for table '
                  || v_var1;
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      CLOSE c1;
   END IF;

   BEGIN
      UPDATE t_acc_bucket_map act
         SET tt_end = dbo.subtractsecond (v_vartime)
       WHERE id_usage_interval = p_interval
         AND status = 'A'
         AND tt_end = v_maxtime
         AND EXISTS (SELECT 1
                       FROM tmp_accountbucketstable tmp
                      WHERE act.id_acc = tmp.ID);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000025-dearchive operation failed-->error in update t_acc_bucket_map';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      v_sql1 :=
            'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
        select '
         || p_interval
         || ' ,id,bucket,''D'','''
         || v_vartime
         || ''' , '''
         || v_maxtime
         || ''' from tmp_AccountBucketsTable';

      EXECUTE IMMEDIATE (v_sql1);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000026-dearchive operation failed-->error in insert into t_acc_bucket_map';
         ROLLBACK;
         RETURN;
   END;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM t_acc_bucket_map MAP LEFT OUTER JOIN t_acc_usage au
          ON MAP.id_acc = au.id_acc
        AND MAP.id_usage_interval = au.id_usage_interval
    WHERE MAP.status = 'A' AND tt_end = v_maxtime;

   IF v_count = 0
   THEN
      BEGIN
/*Update t_archive table to record the fact that interval is no longer archived*/
         UPDATE t_archive
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_interval = p_interval AND status = 'A'
                AND tt_end = v_maxtime;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000027-dearchive operation failed-->error in update t_archive';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive
            SELECT p_interval, id_view, NULL, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval
               AND status = 'A'
               AND tt_end = dbo.subtractsecond (v_vartime)
               AND id_view IS NOT NULL
            UNION ALL
            SELECT p_interval, NULL, adj_name, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval
               AND status = 'A'
               AND tt_end = dbo.subtractsecond (v_vartime)
               AND adj_name IS NOT NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000028-dearchive operation failed-->error in insert t_archive';
            ROLLBACK;
            RETURN;
      END;
   END IF;
/*Following update will be required for post bill adjustments that      are already in system when current usage is dearchived*/

   BEGIN
      UPDATE t_adjustment_transaction trans
         SET id_sess = archive_sess,
             archive_sess = NULL
       WHERE trans.id_sess IS NULL
         AND EXISTS (SELECT 1
                       FROM t_acc_usage au
                      WHERE trans.archive_sess = au.id_sess);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000029-dearchive operation failed-->error in update adjustment transaction';
         ROLLBACK;
         RETURN;
   END;

   v_count := 0;

   SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;

   IF (v_dummy = 'Y')
   THEN
      SELECT partition_name
        INTO v_partition
        FROM t_partition part INNER JOIN t_partition_interval_map MAP
             ON part.id_partition = MAP.id_partition
       WHERE MAP.id_interval = p_interval;
   END IF;

   SELECT COUNT (1)
     INTO v_dummy1
     FROM t_partition part INNER JOIN t_partition_interval_map MAP
          ON part.id_partition = MAP.id_partition
        AND part.partition_name = v_partition
          INNER JOIN t_archive_partition back
          ON part.partition_name = back.partition_name
        AND back.status = 'A'
        AND tt_end = v_maxtime
        AND MAP.id_interval NOT IN (
                                    SELECT id_interval
                                      FROM t_archive
                                     WHERE status <> 'D'
                                           AND tt_end = v_maxtime)
          ;

   IF (v_dummy1 > 0 AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = v_partition
            AND tt_end = v_maxtime
            AND status = 'A';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000030-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (v_partition, 'D', v_vartime, v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000031-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'Y'
          WHERE partition_name = v_partition;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000032-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-dearchive operation successful';
   COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE archive_delete (
   p_partition          NVARCHAR2 DEFAULT NULL,
   p_intervalid         INT DEFAULT NULL,
   p_result       OUT   NVARCHAR2
)
AS
/*How to run this stored procedure    DECLARE      P_PARTITION NVARCHAR2(200);      P_INTERVALID NUMBER;      P_RESULT VARCHAR2(200);    BEGIN      P_PARTITION := 'HS_20070131';      P_INTERVALID := null;      P_RESULT := NULL;       ARCHIVE_DELETE ( P_PARTITION, P_INTERVALID, P_RESULT );      DBMS_OUTPUT.PUT_LINE(P_RESULT);      COMMIT;    END;    OR    DECLARE      P_PARTITION NVARCHAR2(200);      P_INTERVALID NUMBER;      P_RESULT VARCHAR2(200);    BEGIN      P_PARTITION := null;      P_INTERVALID := 885653507;      P_RESULT := NULL;       ARCHIVE_DELETE ( P_PARTITION, P_INTERVALID, P_RESULT );      DBMS_OUTPUT.PUT_LINE(P_RESULT);      COMMIT;    END;     */
   v_sql1         VARCHAR2 (4000);
   v_tab1         VARCHAR2 (1000);
   v_var1         VARCHAR2 (1000);
   v_vartime      DATE;
   v_maxtime      DATE;
   v_acc          INT;
   v_count        NUMBER           := 0;
   v_count1       NUMBER           := 0;
   c1             sys_refcursor;
   c2             sys_refcursor;
   interval_id    sys_refcursor;
   v_cur          sys_refcursor;
   v_interval     INT;
   v_dummy        VARCHAR2 (1);
   v_dummy1       NUMBER (10)      := 0;
   v_dummy2       VARCHAR2 (1);
   v_partition1   NVARCHAR2 (2000);
   v_partition2   NVARCHAR2 (2000);
   v_dummy3       VARCHAR2 (2000);
   dummy_cur      sys_refcursor;
   v_ind          NVARCHAR2 (2000);
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate ();
/* Checking the following Business rules */
                   /* Check that either Interval or Partition is specified */

   IF (   (p_partition IS NOT NULL AND p_intervalid IS NOT NULL)
       OR (p_partition IS NULL AND p_intervalid IS NULL)
      )
   THEN
      p_result :=
         '2000001-archive_delete operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN
      SELECT COUNT (id_interval)
        INTO v_count
        FROM t_partition_interval_map MAP
       WHERE id_partition IN (SELECT id_partition
                                FROM t_partition
                               WHERE partition_name = p_partition);

      IF (v_count = 0)
      THEN
         p_result :=
            '2000002-archive_delete operation failed-->None of the Intervals in the Partition needs to be archived';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;             /* Partition should not already by archived */

      SELECT COUNT (*)
        INTO v_count
        FROM t_archive_partition
       WHERE partition_name = p_partition
         AND status = 'A'
         AND tt_end = v_maxtime;

      IF (v_count > 0)
      THEN
         p_result :=
            '2000003-archive_delete operation failed-->Partition already archived';
         ROLLBACK;
         RETURN;
      END IF;         /* Get the list of intervals that need to be archived */

      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition
        = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      SELECT b_partitioning_enabled
        INTO v_dummy
        FROM t_usage_server;

      IF (v_dummy = 'Y')
      THEN
         SELECT partition_name
           INTO v_partition1
           FROM t_partition part INNER JOIN t_partition_interval_map MAP
                ON part.id_partition = MAP.id_partition
              AND MAP.id_interval = p_intervalid
                ;
      END IF;

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND;
      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'A'
         AND tt_end = dbo.mtmaxdate ();

      IF v_count > 0
      THEN
         p_result :=
            '2000004-archive operation failed-->Interval is already archived';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'E'
         AND tt_end = dbo.mtmaxdate;

      SELECT COUNT (1)
        INTO v_count1
        FROM t_acc_usage
       WHERE id_usage_interval = v_interval;

      IF (v_count = 0 AND v_count1 > 0)
      THEN
         p_result :=
            '2000005-archive operation failed-->Interval is not exported..run the archive_export procedure';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'D'
         AND tt_end = dbo.mtmaxdate;

      IF v_count > 0
      THEN
         p_result :=
            '2000006-archive operation failed-->Interval is Dearchived..run the trash procedure';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;
   END LOOP;

   CLOSE interval_id;
/* Open a dynamic cursor to get the list of intervals that need to be archived */

   IF (p_partition IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition
        = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND;
/* Populate the temporary table with the records in t_adjustment_transaction that are going to be deleted */

      IF table_exists ('tmp_t_adjustment_transaction')
      THEN
         EXECUTE IMMEDIATE 'delete from tmp_t_adjustment_transaction';
      END IF;

      v_sql1 :=
            'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM t_adjustment_transaction where id_usage_interval= '
         || CAST (v_interval AS VARCHAR2);

      EXECUTE IMMEDIATE v_sql1;

      IF table_exists ('tmp_adjustment')
      THEN
         exec_ddl ('truncate table tmp_adjustment');
      END IF;

      OPEN c2 FOR 'select table_name from user_tables where
    upper(table_name) like ''T_AJ_%'' and table_name not in (''T_AJ_TEMPLATE_REASON_CODE_MAP'',''T_AJ_TYPE_APPLIC_MAP'')';

      LOOP
         FETCH c2
          INTO v_var1;

         EXIT WHEN c2%NOTFOUND;
             /*Get the name of t_aj tables that have usage in this interval*/
         v_count := 0;

         OPEN v_cur FOR    'select count(1) from '
                        || v_var1
                        || ' where id_adjustment in
                (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
                        || CAST (v_interval AS VARCHAR2)
                        || ')';

         FETCH v_cur
          INTO v_count;

         CLOSE v_cur;

         IF v_count > 0
         THEN
            INSERT INTO tmp_adjustment
                 VALUES (v_var1);
         END IF;
      END LOOP;

      CLOSE c2;

      OPEN c1 FOR 'select distinct name from tmp_adjustment';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;                  /*Delete from t_aj tables */

         BEGIN
            v_sql1 :=
                  'delete FROM '
               || v_var1
               || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp where aj.id_adjustment = tmp.id_adj_trx)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000007-archive operation failed-->Error in t_aj tables Delete operation';
               ROLLBACK;

               CLOSE c1;

               CLOSE interval_id;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;                 /*Delete from t_adjustment_transaction table*/

      BEGIN
         DELETE FROM t_adjustment_transaction
               WHERE id_usage_interval = v_interval;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
                '2000008-Error in Delete from t_adjustment_transaction table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;
 /*Checking for post bill adjustments that have corresponding usage archived*/

      IF table_exists ('tmp_t_adjust_txn_temp')
      THEN
         EXECUTE IMMEDIATE 'delete from tmp_t_adjust_txn_temp';
      END IF;

      BEGIN
         INSERT INTO tmp_t_adjust_txn_temp
            SELECT id_sess
              FROM t_adjustment_transaction
             WHERE n_adjustmenttype = 1
               AND id_sess IN (SELECT id_sess
                                 FROM t_acc_usage
                                WHERE id_usage_interval = v_interval);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000009-archive operation failed-->Error in populating adjustment temp table operation';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      v_count := 0;

      SELECT COUNT (*)
        INTO v_count
        FROM tmp_t_adjust_txn_temp;

      IF (v_count > 0)
      THEN
         BEGIN
            UPDATE t_adjustment_transaction
               SET archive_sess = id_sess,
                   id_sess = NULL
             WHERE id_sess IN (SELECT id_sess
                                 FROM tmp_t_adjust_txn_temp);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000010-archive operation failed-->Error in Update adjustment operation';
               ROLLBACK;
               RETURN;
         END;
      END IF;

      BEGIN
         UPDATE t_acc_bucket_map
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_usage_interval = v_interval
            AND status = 'E'
            AND tt_end = dbo.mtmaxdate;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000011-archive operation failed-->Error in update t_acc_bucket_map table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         INSERT INTO t_acc_bucket_map
            SELECT v_interval, id_acc, bucket, 'A', v_vartime, v_maxtime
              FROM t_acc_bucket_map
             WHERE id_usage_interval = v_interval
               AND status = 'E'
               AND tt_end = dbo.subtractsecond (v_vartime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000012-archive operation failed-->Error in insert into t_acc_bucket_map table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         UPDATE t_archive
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_interval = v_interval
            AND status = 'E'
            AND tt_end = dbo.mtmaxdate;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000013-archive operation failed-->Error in update t_archive table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive
            SELECT v_interval, id_view, adj_name, 'A', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = v_interval
               AND status = 'E'
               AND tt_end = dbo.subtractsecond (v_vartime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000014-archive operation failed-->Error in insert t_archive table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;
   END LOOP;

   CLOSE interval_id;
/* This step is just an optimization if the user specifis interval but that interval is the only interval in the partition then we can truncate the tables/partition instead of delete */

   IF (p_partition IS NULL)
   THEN
      v_dummy1 := 0;

      SELECT COUNT (*)
        INTO v_dummy1
        FROM t_partition_interval_map MAP
       WHERE id_partition = (SELECT id_partition
                               FROM t_partition_interval_map
                              WHERE id_interval = p_intervalid);

      SELECT b_partitioning_enabled
        INTO v_dummy2
        FROM t_usage_server;

      IF (v_dummy1 <= 1 AND v_dummy2 = 'Y')
      THEN
         v_partition2 := v_partition1;
      END IF;
   END IF;

   IF (NVL (p_partition, v_partition2) IS NOT NULL)
   THEN
      OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                  || v_interval;

      IF table_exists ('tmp_id_view')
      THEN
         exec_ddl ('truncate table tmp_id_view');
      END IF;

      INSERT INTO tmp_id_view
         SELECT DISTINCT id_view
                    FROM t_acc_usage
                   WHERE id_usage_interval = v_interval;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1) /*and nm_table_name not like '%temp%'*/
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         BEGIN                             /*Delete from product view tables*/
            v_sql1 :=
                  'select partition_name from user_tab_partitions where table_name = upper('''
               || v_tab1
               || ''')
                  and tablespace_name = '''
               || NVL (p_partition, v_partition2)
               || '''';

            EXECUTE IMMEDIATE v_sql1
                         INTO v_dummy3;

            v_sql1 :=
                'alter table ' || v_tab1 || ' truncate partition ' || v_dummy3;
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000015-archive operation failed-->Error in product view Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;

         v_sql1 :=
               'select index_name from user_indexes where table_name = upper('''
            || v_tab1
            || ''')
            AND partitioned = ''NO'' and status <> ''VALID''';

         OPEN dummy_cur FOR v_sql1;

         LOOP
            FETCH dummy_cur
             INTO v_ind;

            EXIT WHEN dummy_cur%NOTFOUND;

            BEGIN
               v_sql1 := 'alter index ' || v_ind || ' rebuild';
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '2000015a-archive operation failed-->Error in product view index rebuild operation';
                  ROLLBACK;

                  CLOSE dummy_cur;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE dummy_cur;
      END LOOP;

      CLOSE c1;                              /*Delete from t_acc_usage table*/

      BEGIN
         v_dummy3 := '';
         v_sql1 :=
               'select partition_name from user_tab_partitions where table_name = ''T_ACC_USAGE''
            and tablespace_name = '''
            || NVL (p_partition, v_partition2)
            || '''';

         EXECUTE IMMEDIATE v_sql1
                      INTO v_dummy3;

         v_sql1 := 'alter table t_acc_usage truncate partition ' || v_dummy3;
         exec_ddl (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000016-archive operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
         'select index_name from user_indexes where table_name = ''T_ACC_USAGE''
        AND partitioned = ''NO'' and status <> ''VALID''';

      OPEN dummy_cur FOR v_sql1;

      LOOP
         FETCH dummy_cur
          INTO v_ind;

         EXIT WHEN dummy_cur%NOTFOUND;

         BEGIN
            v_sql1 := 'alter index ' || v_ind || ' rebuild';
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000016a-archive operation failed-->Error in Usage index rebuild operation';
               ROLLBACK;

               CLOSE dummy_cur;

               RETURN;
         END;
      END LOOP;

      CLOSE dummy_cur;
   END IF;

   IF ((NVL (p_partition, v_partition2) IS NULL) AND p_intervalid IS NOT NULL
      )
   THEN
      OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                  || v_interval;

      IF table_exists ('tmp_id_view')
      THEN
         exec_ddl ('truncate table tmp_id_view');
      END IF;

      INSERT INTO tmp_id_view
         SELECT DISTINCT id_view
                    FROM t_acc_usage
                   WHERE id_usage_interval = v_interval;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1) /*and nm_table_name not like '%temp%'*/
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         BEGIN                             /*Delete from product view tables*/
            v_sql1 :=
                  'delete FROM '
               || v_tab1
               || ' where exists (select 1 from t_acc_usage au where '
               || v_tab1
               || '.id_sess = au.id_sess
                        and au.id_usage_interval = '
               || v_tab1
               || '.id_usage_interval)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000017-archive operation failed-->Error in product view Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;                              /*Delete from t_acc_usage table*/

      BEGIN
         v_sql1 :=
               'delete from t_acc_usage where id_usage_interval = '
            || p_intervalid;

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000018-archive operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   v_count := 0;

   SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;

   SELECT COUNT (1)
     INTO v_dummy1
     FROM t_partition_interval_map MAP INNER JOIN t_archive inte
          ON inte.id_interval = MAP.id_interval
        AND inte.tt_end = v_maxtime
        AND inte.status = 'A'
    WHERE MAP.id_partition = (SELECT id_partition
                                FROM t_partition_interval_map
                               WHERE id_interval = p_intervalid);

   SELECT COUNT (*)
     INTO v_count
     FROM t_partition_interval_map MAP
    WHERE id_partition = (SELECT id_partition
                            FROM t_partition_interval_map
                           WHERE id_interval = p_intervalid);
/* if all the intervals are archived, modify the status in t_archive_partition table */

   IF ((p_partition IS NOT NULL OR v_dummy1 = v_count) AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = NVL (p_partition, v_partition1)
            AND tt_end = v_maxtime
            AND status = 'E';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000021-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (NVL (p_partition, v_partition1), 'A', v_vartime,
                      v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000022-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'N'
          WHERE partition_name = NVL (p_partition, v_partition1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000023-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-archive_delete operation successful';
   COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE addnewaccount (
   p_id_acc_ext                 IN       VARCHAR2,
   p_acc_state                  IN       VARCHAR2,
   p_acc_status_ext             IN       INT,
   p_acc_vtstart                IN       DATE,
   p_acc_vtend                  IN       DATE,
   p_nm_login                   IN       NVARCHAR2,
   p_nm_space                   IN       NVARCHAR2,
   p_tx_password                IN       NVARCHAR2,
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
   profileid            INTEGER;
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
   INSERT INTO t_user_credentials
               (nm_login, nm_space, tx_password
               )
        VALUES (p_nm_login, LOWER (p_nm_space), p_tx_password
               );

   /* step : get the profile id and incr current_id counter*/
   SELECT id_current
     INTO profileid
     FROM t_current_id
    WHERE nm_current = 'id_profile';

   UPDATE t_current_id
      SET id_current = id_current + 1
    WHERE nm_current = 'id_profile';

   /* step : t_profile. This looks like it is only for timezone information */
   INSERT INTO t_profile
               (id_profile, nm_tag, val_tag, tx_desc
               )
        VALUES (profileid, 'timeZoneID', p_profile_timezone, 'System'
               );

   /* step : site user information*/
   getlocalizedsiteinfo (p_nm_space, p_langcode, siteid);

   INSERT INTO t_site_user
               (nm_login, id_site, id_profile
               )
        VALUES (p_nm_login, siteid, profileid
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

   IF (payerid <= 1)
   THEN
      /* MT_CANNOT_RESOLVE_PAYING_ACCOUNT*/
      status := -486604792;
      RETURN;
   END IF;
   
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
   /* if "Apply Default Policy" flag is set, then figure out    "ancestor" id based on account type in case the account is not    a subscriber*/

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
   END;                                      /* resolve accounts' corporation.
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
END addnewaccount;
/

CREATE OR REPLACE PROCEDURE deleteaccounts (
   v_accountidlist               NVARCHAR2,       /* accounts to be deleted */
   v_tablename                   NVARCHAR2, /* table containing id_acc to be deleted */
   v_linkedservername            VARCHAR2,
                                   /* linked server name for payment server */
   v_paymentserverdbname         VARCHAR2,  /* payment server database name */
   o_cur                   OUT   sys_refcursor
)
AS
   v_accountidlist_tmp   NVARCHAR2 (255) := v_accountidlist;
   v_sql                 VARCHAR2 (4000);

   CURSOR c1
   IS
      SELECT id_pt, id_pricelist
        FROM tmp_id_pt;

   v_name                VARCHAR2 (200);
   v_pt_name             VARCHAR2 (200);
   v_pl_name             VARCHAR2 (200);
   v_str                 VARCHAR2 (4000);
   v_hierarchyrule       NVARCHAR2 (10);
   seterror              EXCEPTION;
   v_count               NUMBER          := 0;

   CURSOR v_cur
   IS
      SELECT table_name
        FROM user_tables
       WHERE UPPER (table_name) LIKE 'T_AV_%';

   v_table_name          VARCHAR2 (30);
BEGIN
   /* Break down into simple account IDs */
   /* This block of SQL can be used as an example to get  */
   /* the account IDs from the list of account IDs that are */
   /* passed in */
   EXECUTE IMMEDIATE 'truncate TABLE tmp_AccountIDsTable';

   DBMS_OUTPUT.put_line ('------------------------------------------------');
   DBMS_OUTPUT.put_line ('-- Start of Account Deletion Stored Procedure --');
   DBMS_OUTPUT.put_line ('------------------------------------------------');

   IF (   (v_accountidlist IS NOT NULL AND v_tablename IS NOT NULL)
       OR (v_accountidlist IS NULL AND v_tablename IS NULL)
      )
   THEN
      DBMS_OUTPUT.put_line
         ('ERROR--Delete account operation failed-->Either accountIDList or tablename should be specified'
         );
      RETURN;
   END IF;

   IF (v_accountidlist IS NOT NULL)
   THEN
      DBMS_OUTPUT.put_line
            ('-- Parsing Account IDs passed in and inserting in tmp table --');

      WHILE INSTR (v_accountidlist_tmp, ',') > 0
      LOOP
         INSERT INTO tmp_accountidstable
                     (ID, status, MESSAGE)
            SELECT SUBSTR (v_accountidlist_tmp,
                           1,
                           (INSTR (v_accountidlist_tmp, ',') - 1)
                          ),
                   1, 'Okay to delete'
              FROM DUAL;

         v_accountidlist_tmp :=
            SUBSTR (v_accountidlist_tmp,
                    (INSTR (v_accountidlist_tmp, ',') + 1
                    ),
                    (  LENGTH (v_accountidlist_tmp)
                     - (INSTR (',', v_accountidlist_tmp))
                    )
                   );
      END LOOP;

      INSERT INTO tmp_accountidstable
                  (ID, status, MESSAGE)
         SELECT v_accountidlist_tmp, 1, 'Okay to delete'
           FROM DUAL;

       /*SELECT ID as one FROM tmp_AccountIDsTable*/
      /* Transitive Closure (check for folder/corporation)*/
      DBMS_OUTPUT.put_line
                       ('-- Inserting children (if any) into the tmp table --');

      INSERT INTO tmp_accountidstable
                  (ID, status, MESSAGE)
         SELECT DISTINCT aa.id_descendent, 1, 'Okay to delete'
                    FROM t_account_ancestor aa, tmp_accountidstable tmp
                   WHERE tmp.ID = aa.id_ancestor
                     AND aa.num_generations > 0
                     AND NOT EXISTS (SELECT ID
                                       FROM tmp_accountidstable tmp1
                                      WHERE tmp1.ID = aa.id_descendent);

      /*fix bug 11599*/
      INSERT INTO tmp_accountidstable
                  (ID, status, MESSAGE)
         SELECT DISTINCT aa.id_descendent, 1, 'Okay to delete'
                    FROM t_account_ancestor aa
                   WHERE id_ancestor IN (SELECT ID
                                           FROM tmp_accountidstable)
                     AND aa.num_generations > 0
                     AND NOT EXISTS (SELECT ID
                                       FROM tmp_accountidstable tmp1
                                      WHERE tmp1.ID = aa.id_descendent);
   ELSE
      v_sql :=
            'INSERT INTO tmp_AccountIDsTable (ID, status, message) SELECT id_acc, '
         || '1, ''Okay to delete'' from '
         || v_tablename;

      EXECUTE IMMEDIATE v_sql;

      INSERT INTO tmp_accountidstable
                  (ID, status, MESSAGE)
         SELECT DISTINCT aa.id_descendent, 1, 'Okay to delete'
                    FROM t_account_ancestor aa INNER JOIN tmp_accountidstable tmp ON tmp.ID =
                                                                                       aa.id_ancestor
                                                                                AND aa.num_generations >
                                                                                       0
                                                                                AND NOT EXISTS (
                                                                                       SELECT ID
                                                                                         FROM tmp_accountidstable tmp1
                                                                                        WHERE tmp1.ID =
                                                                                                 aa.id_descendent)
                         ;
   END IF;

   /* SELECT * from tmp_AccountIDsTable            */

   /*dbms_output.put_line( out the accounts with their login names
   SELECT
       ID as two,
       nm_login as two
   FROM
       tmp_AccountIDsTable a,
       t_account_mapper b
   WHERE
       a.ID = b.id_acc;
   */

   /*
    * Check for all the business rules.  We want to make sure
    * that we are checking the more restrictive rules first
    * 1. Check for usage in hard closed interval
    * 2. Check for invoices in hard closed interval
    * 3. Check if the account is a payer ever
    * 4. Check if the account is a receiver of per subscription Recurring
    *    Charge
    * 5. Check for usage in soft/open closed interval
    * 6. Check for invoices in soft/open closed interval
    * 7. Check if the account contributes to group discount
    */
   DBMS_OUTPUT.put_line ('-- Account does not exists check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account does not exists!'
    WHERE status <> 0 AND NOT EXISTS (SELECT 1
                                        FROM t_account acc
                                       WHERE acc.id_acc = tmp.ID);

   /* 1. Check for 'hard close' usage in any of these accounts*/
   DBMS_OUTPUT.put_line ('-- Usage in Hard closed interval check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account contains usage in hard interval!'
    WHERE status <> 0 AND EXISTS (SELECT au.id_acc
                                    FROM t_acc_usage au INNER JOIN t_acc_usage_interval ui ON ui.id_usage_interval =
                                                                                                au.id_usage_interval
                                                                                         AND ui.tx_status IN
                                                                                                ('H'
                                                                                                )
                                   WHERE au.id_acc = tmp.ID);

   /* 2. Check for invoices in hard closed interval usage in any of these  */
   /* accounts */
   DBMS_OUTPUT.put_line ('-- Invoices in Hard closed interval check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                            /* failure */
          MESSAGE = 'Account contains invoices for hard closed interval!'
    WHERE status <> 0 AND EXISTS (SELECT i.id_acc
                                    FROM t_invoice i INNER JOIN t_acc_usage_interval ui ON ui.id_usage_interval =
                                                                                             i.id_interval
                                                                                      AND ui.tx_status IN
                                                                                             ('H'
                                                                                             )
                                   WHERE i.id_acc = tmp.ID);

   /* 3. Check if this account has ever been a payer*/
   DBMS_OUTPUT.put_line ('-- Payer check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account is a payer!'
    WHERE status <> 0
      AND EXISTS (
             SELECT p.id_payer
               FROM t_payment_redir_history p
              WHERE p.id_payer = tmp.ID
                AND p.id_payee NOT IN (SELECT ID
                                         FROM tmp_accountidstable));

   /* 4. Check if this account is receiver of per subscription RC */
   DBMS_OUTPUT.put_line
                  ('-- Receiver of per subscription Recurring Charge check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account is receiver of per subscription RC!'
    WHERE status <> 0 AND EXISTS (SELECT gsrm.id_acc
                                    FROM t_gsub_recur_map gsrm
                                   WHERE gsrm.id_acc = tmp.ID);

   /* 5. Check for invoices in soft closed or open usage in any of these  */
   /* accounts */
   DBMS_OUTPUT.put_line ('-- Invoice in Soft closed/Open interval check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE =
             'Account contains invoices for soft closed interval.  Please backout invoice adapter first!'
    WHERE status <> 0 AND EXISTS (SELECT i.id_acc
                                    FROM t_invoice i INNER JOIN t_acc_usage_interval ui ON ui.id_usage_interval =
                                                                                             i.id_interval
                                                                                      AND ui.tx_status IN
                                                                                             ('C',
                                                                                              'O'
                                                                                             )
                                   WHERE i.id_acc = tmp.ID);

   /* 6. Check for 'soft close/open' usage in any of these accounts*/
   DBMS_OUTPUT.put_line ('-- Usage in Soft closed/Open interval check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE =
             'Account contains usage in soft closed or open interval.  Please backout first!'
    WHERE status <> 0 AND EXISTS (SELECT au.id_acc
                                    FROM t_acc_usage au INNER JOIN t_acc_usage_interval ui ON ui.id_usage_interval =
                                                                                                au.id_usage_interval
                                                                                         AND ui.tx_status IN
                                                                                                ('C',
                                                                                                 'O'
                                                                                                )
                                   WHERE au.id_acc = tmp.ID);

   /* 7. Check if this account contributes to group discount */
   DBMS_OUTPUT.put_line ('-- Contribution to Discount Distribution check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account is contributing to a discount!'
    WHERE status <> 0 AND EXISTS (SELECT gs.id_discountaccount
                                    FROM t_group_sub gs
                                   WHERE gs.id_discountaccount = tmp.ID);

   SELECT COUNT (*)
     INTO v_count
     FROM tmp_accountidstable
    WHERE status = 0;

   IF v_count > 0
   THEN
      DBMS_OUTPUT.put_line
                      ('Deletion of accounts cannot proceed. Fix the errors!');
      DBMS_OUTPUT.put_line ('-- Exiting --!');

      OPEN o_cur FOR
         SELECT *
           FROM tmp_accountidstable;

      RETURN;
   END IF;

   /* Start the deletes here*/
   DBMS_OUTPUT.put_line ('-- Beginning the transaction here --');
   /* Script to find ICB rates and delete from t_pt, t_rsched, */
   /* t_pricelist tables*/
   DBMS_OUTPUT.put_line ('-- Finding ICB rate and deleting for PC tables --');

   EXECUTE IMMEDIATE 'truncate table tmp_id_sub';

   INSERT INTO tmp_id_sub
      SELECT id_sub
        FROM t_sub
       WHERE id_acc IN (SELECT ID
                          FROM tmp_accountidstable);

   EXECUTE IMMEDIATE 'truncate table tmp_id_pt';

   INSERT INTO tmp_id_pt
      SELECT id_paramtable, id_pricelist
        FROM t_pl_map
       WHERE id_sub IN (SELECT *
                          FROM tmp_id_sub);

   OPEN c1;

	 loop
   FETCH c1
    INTO v_pt_name, v_pl_name;
	 exit when c1%notfound;

   FOR i IN (SELECT REVERSE (SUBSTR (REVERSE (nm_name),
                                     1,
                                     INSTR (REVERSE (nm_name), '/') - 1
                                    )
                            ) nm_name
               FROM t_base_props
              WHERE id_prop = v_pt_name)
   LOOP
      v_name := i.nm_name;
   END LOOP;

   v_str :=
         'DELETE t_pt_'
      || v_name
      || ' t_pt where exists (select 1 from t_rsched rsc, t_pl_map map where t_pt'
      || '.id_sched = rsc.id_sched AND
        map.id_paramtable = rsc.id_pt AND
        map.id_pi_template = rsc.id_pi_template AND
        map.id_pricelist = rsc.id_pricelist
        AND map.id_sub IN (SELECT id_sub FROM tmp_id_sub))';

   EXECUTE IMMEDIATE v_str;

   v_str := 'DELETE FROM t_rsched WHERE id_pricelist =' || v_pl_name;

   EXECUTE IMMEDIATE v_str;

   v_str := 'DELETE FROM t_pl_map WHERE id_pricelist =' || v_pl_name;

   EXECUTE IMMEDIATE v_str;

   v_str := 'DELETE FROM t_pricelist WHERE id_pricelist =' || v_pl_name;

   EXECUTE IMMEDIATE v_str;

	 end loop;
   CLOSE c1;

   /* t_billgroup_member */
   DBMS_OUTPUT.put_line ('-- Deleting from t_billgroup_member --');

   DELETE FROM t_billgroup_member
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_billgroup_member table');
      RAISE seterror;
   END IF;

   /* t_billgroup_member_history */
   DBMS_OUTPUT.put_line ('-- Deleting from t_billgroup_member_history --');

   DELETE FROM t_billgroup_member_history
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line
                       ('Cannot delete from t_billgroup_member_history table');
      RAISE seterror;
   END IF;

   /* t_billgroup_source_acc */
   DBMS_OUTPUT.put_line ('-- Deleting from t_billgroup_source_acc --');

   DELETE FROM t_billgroup_source_acc
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_billgroup_source_acc table');
      RAISE seterror;
   END IF;

   /* t_billgroup_constraint */
   DBMS_OUTPUT.put_line ('-- Deleting from t_billgroup_constraint --');

   DELETE FROM t_billgroup_constraint
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_billgroup_constraint table');
      RAISE seterror;
   END IF;

   /* t_billgroup_constraint_tmp */
   DBMS_OUTPUT.put_line ('-- Deleting from t_billgroup_constraint_tmp --');

   DELETE FROM t_billgroup_constraint_tmp
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line
                       ('Cannot delete from t_billgroup_constraint_tmp table');
      RAISE seterror;
   END IF;

   /* t_av_* tables*/
   EXECUTE IMMEDIATE 'truncate TABLE tmp_t_av_tables';

   OPEN v_cur;

   /* Delete from t_av_* tables*/
   LOOP
      FETCH v_cur
       INTO v_table_name;

      IF v_cur%NOTFOUND
      THEN
         EXIT;
      END IF;

      BEGIN
         EXECUTE IMMEDIATE    'DELETE FROM '
                           || v_table_name
                           || ' WHERE id_acc IN (SELECT ID FROM tmp_AccountIDsTable)';
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (   'Cannot delete from '
                                  || v_table_name
                                  || ' table'
                                 );
            RAISE seterror;
      END;
   END LOOP;

   CLOSE v_cur;

   /* t_account_state_history */
   DBMS_OUTPUT.put_line ('-- Deleting from t_account_state_history --');

   DELETE FROM t_account_state_history
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line
                          ('Cannot delete from t_account_state_history table');
      RAISE seterror;
   END IF;

   /* t_account_state*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_account_state --');

   DELETE FROM t_account_state
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_account_state table');
      RAISE seterror;
   END IF;

   /* t_acc_usage_interval */
   DBMS_OUTPUT.put_line ('-- Deleting from t_acc_usage_interval --');

   DELETE FROM t_acc_usage_interval
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_acc_usage_interval table');
      RAISE seterror;
   END IF;

   /* t_acc_usage_cycle*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_acc_usage_cycle --');

   DELETE FROM t_acc_usage_cycle
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_acc_usage_cycle table');
      RAISE seterror;
   END IF;

   /* t_acc_template_props */
   DBMS_OUTPUT.put_line ('-- Deleting from t_acc_template_props --');

   DELETE FROM t_acc_template_props
         WHERE id_acc_template IN (
                                 SELECT id_acc_template
                                   FROM t_acc_template
                                  WHERE id_folder IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_acc_template_props table');
      RAISE seterror;
   END IF;

   /* t_acc_template_subs*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_acc_template_subs --');

   DELETE FROM t_acc_template_subs
         WHERE id_acc_template IN (
                                 SELECT id_acc_template
                                   FROM t_acc_template
                                  WHERE id_folder IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_acc_template_subs table');
      RAISE seterror;
   END IF;

   /* t_acc_template*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_acc_template --');

   DELETE FROM t_acc_template
         WHERE id_folder IN (SELECT ID
                               FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_acc_template table');
      RAISE seterror;
   END IF;

   /* t_user_credentials */
   DBMS_OUTPUT.put_line ('-- Deleting from t_user_credentials --');

   DELETE FROM t_user_credentials
         WHERE nm_login IN (SELECT nm_login
                              FROM t_account_mapper
                             WHERE id_acc IN (SELECT ID
                                                FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_user_credentials table');
      RAISE seterror;
   END IF;

   /* t_profile*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_profile --');

   DELETE FROM t_profile
         WHERE id_profile IN (
                  SELECT id_profile
                    FROM t_site_user
                   WHERE nm_login IN (
                                    SELECT nm_login
                                      FROM t_account_mapper
                                     WHERE id_acc IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable)));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_profile table');
      RAISE seterror;
   END IF;

   /* t_site_user*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_site_user --');

   DELETE FROM t_site_user
         WHERE nm_login IN (SELECT nm_login
                              FROM t_account_mapper
                             WHERE id_acc IN (SELECT ID
                                                FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_site_user table');
      RAISE seterror;
   END IF;

   /* t_payment_redirection */
   DBMS_OUTPUT.put_line ('-- Deleting from t_payment_redirection --');

   DELETE FROM t_payment_redirection
         WHERE id_payee IN (SELECT ID
                              FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_payment_redirection table');
      RAISE seterror;
   END IF;

   /* t_payment_redir_history */
   DBMS_OUTPUT.put_line ('-- Deleting from t_payment_redir_history --');

   DELETE FROM t_payment_redir_history
         WHERE id_payee IN (SELECT ID
                              FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line
                          ('Cannot delete from t_payment_redir_history table');
      RAISE seterror;
   END IF;

   /* t_sub*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_sub --');

   DELETE FROM t_sub
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_sub table');
      RAISE seterror;
   END IF;

   /* t_sub_history*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_sub_history --');

   DELETE FROM t_sub_history
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_sub_history table');
      RAISE seterror;
   END IF;

   /* t_group_sub */
   DBMS_OUTPUT.put_line ('-- Deleting from t_group_sub --');

   DELETE FROM t_group_sub
         WHERE id_discountaccount IN (SELECT ID
                                        FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_group_sub table');
      RAISE seterror;
   END IF;

   /* t_gsubmember*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_gsubmember --');

   DELETE FROM t_gsubmember
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_gsubmember table');
      RAISE seterror;
   END IF;

   /* t_gsubmember_historical*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_gsubmember_historical --');

   DELETE FROM t_gsubmember_historical
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line
                          ('Cannot delete from t_gsubmember_historical table');
      RAISE seterror;
   END IF;

   /* t_gsub_recur_map */
   DBMS_OUTPUT.put_line ('-- Deleting from t_gsub_recur_map --');

   DELETE FROM t_gsub_recur_map
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_gsub_recur_map table');
      RAISE seterror;
   END IF;

   /* t_pl_map*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_pl_map --');

   DELETE FROM t_pl_map
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_pl_map table');
      RAISE seterror;
   END IF;

   /* t_path_capability */
   DBMS_OUTPUT.put_line ('-- Deleting from t_path_capability --');

   DELETE FROM t_path_capability
         WHERE id_cap_instance IN (
                  SELECT id_cap_instance
                    FROM t_capability_instance ci
                   WHERE ci.id_policy IN (
                                    SELECT id_policy
                                      FROM t_principal_policy
                                     WHERE id_acc IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable)));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_path_capability table');
      RAISE seterror;
   END IF;

   /* t_enum_capability*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_enum_capability --');

   DELETE FROM t_enum_capability
         WHERE id_cap_instance IN (
                  SELECT id_cap_instance
                    FROM t_capability_instance ci
                   WHERE ci.id_policy IN (
                                    SELECT id_policy
                                      FROM t_principal_policy
                                     WHERE id_acc IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable)));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_enum_capability table');
      RAISE seterror;
   END IF;

   /* t_decimal_capability*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_decimal_capability --');

   DELETE FROM t_decimal_capability
         WHERE id_cap_instance IN (
                  SELECT id_cap_instance
                    FROM t_capability_instance ci
                   WHERE ci.id_policy IN (
                                    SELECT id_policy
                                      FROM t_principal_policy
                                     WHERE id_acc IN (
                                                      SELECT ID
                                                        FROM tmp_accountidstable)));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_decimal_capability table');
      RAISE seterror;
   END IF;

   /* t_capability_instance*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_capability_instance --');

   DELETE FROM t_capability_instance
         WHERE id_policy IN (SELECT id_policy
                               FROM t_principal_policy
                              WHERE id_acc IN (SELECT ID
                                                 FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_capability_instance table');
      RAISE seterror;
   END IF;

   /* t_policy_role*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_policy_role --');

   DELETE FROM t_policy_role
         WHERE id_policy IN (SELECT id_policy
                               FROM t_principal_policy
                              WHERE id_acc IN (SELECT ID
                                                 FROM tmp_accountidstable));

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_policy_role table');
      RAISE seterror;
   END IF;

   /* t_principal_policy*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_principal_policy --');

   DELETE FROM t_principal_policy
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_principal_policy table');
      RAISE seterror;
   END IF;

   /* t_impersonate*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_impersonate --');

   DELETE FROM t_impersonate
         WHERE (   id_acc IN (SELECT ID
                                FROM tmp_accountidstable)
                OR id_owner IN (SELECT ID
                                  FROM tmp_accountidstable)
               );

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_impersonate table');
      RAISE seterror;
   END IF;

   /* t_account_mapper*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_account_mapper --');

   DELETE FROM t_account_mapper
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_account_mapper table');
      RAISE seterror;
   END IF;

   FOR i IN (SELECT VALUE
               FROM t_db_values
              WHERE parameter = 'Hierarchy_RestrictedOperations')
   LOOP
      v_hierarchyrule := i.VALUE;
   END LOOP;

   IF (v_hierarchyrule = 'True')
   THEN
      DELETE FROM t_group_sub
            WHERE id_corporate_account IN (SELECT ID
                                             FROM tmp_accountidstable);

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_group_sub table');
         RAISE seterror;
      END IF;
   END IF;

   /* t_account_ancestor*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_account_ancestor --');

   DELETE FROM t_account_ancestor
         WHERE id_descendent IN (SELECT ID
                                   FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_account_ancestor table');
      RAISE seterror;
   END IF;

   UPDATE t_account_ancestor aa1
      SET b_children = 'N'
    WHERE id_descendent IN (SELECT ID
                              FROM tmp_accountidstable)
      AND NOT EXISTS (
             SELECT 1
               FROM t_account_ancestor aa2
              WHERE aa2.id_ancestor = aa1.id_descendent
                AND num_generations <> 0);

   /* t_account*/
   DBMS_OUTPUT.put_line ('-- Deleting from t_account --');

   DELETE FROM t_account
         WHERE id_acc IN (SELECT ID
                            FROM tmp_accountidstable);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_account table');
      RAISE seterror;
   END IF;

		DELETE FROM t_dm_account_ancestor
		WHERE id_dm_descendent in
		(
		select id_dm_acc from t_dm_account where id_acc in
		(SELECT ID FROM tmp_accountidstable)
		);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_dm_account_ancestor table');
      RAISE seterror;
   END IF;

		DELETE FROM t_dm_account
		WHERE id_acc in
		(SELECT ID FROM tmp_accountidstable
		);

   IF (SQLCODE <> 0)
   THEN
      DBMS_OUTPUT.put_line ('Cannot delete from t_dm_account table');
      RAISE seterror;
   END IF;

   /* IF (v_linkedservername <> NULL)
    BEGIN
      Do payment server stuff here
    END*/

   /* If we are here, then all accounts should have been deleted   */
   IF (v_linkedservername IS NOT NULL AND v_paymentserverdbname IS NOT NULL)
   THEN
      v_sql :=
            'delete t_ps_creditcard@'
         || v_linkedservername
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';
      DBMS_OUTPUT.put_line (v_sql);

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_creditcard table');
         RAISE seterror;
      END IF;

      v_sql :=
            'delete from t_ps_ach@'
         || v_linkedservername
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_ach table');
         RAISE seterror;
      END IF;
   END IF;

   IF (v_linkedservername IS NULL AND v_paymentserverdbname IS NOT NULL)
   THEN
      v_sql :=
            'delete t_ps_creditcard@'
         || v_paymentserverdbname
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_creditcard table');
         RAISE seterror;
      END IF;

      v_sql :=
            'delete from t_ps_ach@'
         || v_paymentserverdbname
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_ach table');
         RAISE seterror;
      END IF;
   END IF;

   UPDATE tmp_accountidstable
      SET MESSAGE = 'This account no longer exists!';

   OPEN o_cur FOR
      SELECT *
        FROM tmp_accountidstable;

   /*WHERE
     status <> 0*/
   COMMIT;
   RETURN;
EXCEPTION
   WHEN seterror
   THEN
      ROLLBACK;
END deleteaccounts;
/

/*  returns all balances for account as of end of interval */
/*  return codes: */
/*  O = OK */
/*  1 = currency mismatch */
CREATE or replace PROCEDURE GetBalances(
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
  v_temp_bal number(18,6):=0;
  v_balance_date date;
  v_unbilled_prior_charges number(18, 6);  /* unbilled charges from interval after invoice and before this one */
  v_previous_charges number(18, 6);        /* payments, adjsutments for this interval */
  v_current_charges number(18, 6);         /* current charges for this interval */
  v_interval_start date;
  v_tmp_amount number(18, 6);
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
          SUM(nvl(au.Tax_Federal,0.0)) +
          SUM(nvl(au.Tax_State,0.0)) +
          SUM(nvl(au.Tax_County,0.0)) +
          SUM(nvl(au.Tax_Local,0.0)) +
          SUM(nvl(au.Tax_Other,0.0)) amt,
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
   SUM(nvl(au.Tax_Federal, 0.0)) +
   SUM(nvl(au.Tax_State, 0.0)) +
   SUM(nvl(au.Tax_County, 0.0)) +
   SUM(nvl(au.Tax_Local, 0.0)) +
   SUM(nvl(au.Tax_Other, 0.0)) amt,
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

    CREATE or replace PROCEDURE INSERTACCTUSAGEWITHUID(
        tx_UID 	            IN RAW,
        id_acc 	            IN int,
        id_view 	        IN int  ,
        id_usage_interval 	IN int  ,
        uid_parent_sess 	IN RAW  ,
        id_svc 	            IN int  ,
        dt_session 	        IN DATE ,
        amount 	            IN NUMBER  ,
        am_currency 	    IN nVARCHAR2,
        tax_federal 	    IN NUMBER  ,
        tax_state 	        IN NUMBER  ,
        tax_county 	        IN NUMBER  ,
        tax_local 	        IN NUMBER  ,
        tax_other 	        IN NUMBER  ,
        tx_batch 	        IN RAW  ,
        id_prod 	        IN int  ,
        id_pi_instance 	    IN int  ,
        id_pi_template 	    IN int  ,
        id_sess 	        IN OUT int)
    AS
        tx_UID_ 	        RAW(255)     := tx_UID;
        id_acc_ 	        NUMBER(10,0) := id_acc;
        id_view_ 	        NUMBER(10,0) := id_view;
        id_usage_interval_ 	NUMBER(10,0) := id_usage_interval;
        uid_parent_sess_ 	RAW(255)     := uid_parent_sess;
        id_svc_ 	        NUMBER(10,0) := id_svc;
        dt_session_ 	    DATE         := dt_session;
        amount_ 	        NUMBER(18,6) := amount;
        am_currency_ 	    VARCHAR2(6)  := am_currency;
        tax_federal_ 	    NUMBER(18,6) := tax_federal;
        tax_state_ 	        NUMBER(18,6) := tax_state;
        tax_county_ 	    NUMBER(18,6) := tax_county;
        tax_local_ 	        NUMBER(18,6) := tax_local;
        tax_other_ 	        NUMBER(18,6) := tax_other;
        tx_batch_ 	        RAW(255)     := tx_batch;
        id_prod_ 	        NUMBER(10,0) := id_prod;
        id_pi_instance_ 	NUMBER(10,0) := id_pi_instance;
        id_pi_template_ 	NUMBER(10,0) := id_pi_template;
        id_parent_sess 	    NUMBER(10,0);
    BEGIN

        INSERTACCTUSAGEWITHUID.id_parent_sess :=  -1;
        FOR rec IN ( SELECT   id_sess
                        FROM t_acc_usage
                        WHERE tx_UID = INSERTACCTUSAGEWITHUID.uid_parent_sess_)
        LOOP
           id_parent_sess := rec.id_sess ;

        END LOOP;
        IF  ( INSERTACCTUSAGEWITHUID.id_parent_sess = -1) THEN
            INSERTACCTUSAGEWITHUID.id_sess :=  -99;
        ELSE
            FOR rec IN ( SELECT   id_current
                            FROM t_current_id
                            WHERE nm_current = 'id_sess')
            LOOP
               id_sess := rec.id_current ;

            END LOOP;
            UPDATE t_current_id
            SET 	id_current = id_current + 1
                        WHERE nm_current = 'id_sess';
            BEGIN
                 INSERT INTO t_acc_usage (id_sess, tx_UID, id_acc, id_view, id_usage_interval, id_parent_sess,
                                          id_svc, dt_session, amount, am_currency, tax_federal, tax_state, tax_county,
                                          tax_local, tax_other, tx_batch, id_prod, id_pi_instance, id_pi_template)
                 VALUES (INSERTACCTUSAGEWITHUID.id_sess,INSERTACCTUSAGEWITHUID.tx_UID_,
                        INSERTACCTUSAGEWITHUID.id_acc_,INSERTACCTUSAGEWITHUID.id_view_,
                        INSERTACCTUSAGEWITHUID.id_usage_interval_,INSERTACCTUSAGEWITHUID.id_parent_sess,
                        INSERTACCTUSAGEWITHUID.id_svc_,INSERTACCTUSAGEWITHUID.dt_session_,
                        INSERTACCTUSAGEWITHUID.amount_,INSERTACCTUSAGEWITHUID.am_currency_,
                        INSERTACCTUSAGEWITHUID.tax_federal_,
                        INSERTACCTUSAGEWITHUID.tax_state_,
                        INSERTACCTUSAGEWITHUID.tax_county_,
                        INSERTACCTUSAGEWITHUID.tax_local_,
                        INSERTACCTUSAGEWITHUID.tax_other_,
                        INSERTACCTUSAGEWITHUID.tx_batch_,
                        INSERTACCTUSAGEWITHUID.id_prod_,
                        INSERTACCTUSAGEWITHUID.id_pi_instance_,
                        INSERTACCTUSAGEWITHUID.id_pi_template_);
                 IF SQL%ROWCOUNT != 1 THEN
                    INSERTACCTUSAGEWITHUID.id_sess :=  -99;
                 END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    INSERTACCTUSAGEWITHUID.id_sess :=  -99;
            END;

        END IF;
    END INSERTACCTUSAGEWITHUID;
/

call RecompileMetraTech();
