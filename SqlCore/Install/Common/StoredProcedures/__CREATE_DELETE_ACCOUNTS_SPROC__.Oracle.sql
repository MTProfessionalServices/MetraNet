
CREATE OR REPLACE PROCEDURE deleteaccounts (
   p_account_id_list               NVARCHAR2, /* accounts to be deleted */
   p_table_name                   NVARCHAR2, /* table containing id_acc to be deleted */
   p_linked_server_name            VARCHAR2, /* linked server name for payment server */
   p_payment_server_dbname         VARCHAR2,  /* payment server database name */
   p_cur                   OUT   sys_refcursor
)
AS
   p_account_id_list_tmp   NVARCHAR2 (255) := p_account_id_list;
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

   p_table_name          VARCHAR2 (30);
BEGIN
   /* Break down into simple account IDs */
   /* This block of SQL can be used as an example to get  */
   /* the account IDs from the list of account IDs that are */
   /* passed in */
   EXECUTE IMMEDIATE 'truncate TABLE tmp_AccountIDsTable';

   DBMS_OUTPUT.put_line ('------------------------------------------------');
   DBMS_OUTPUT.put_line ('-- Start of Account Deletion Stored Procedure --');
   DBMS_OUTPUT.put_line ('------------------------------------------------');

   IF (   (p_account_id_list IS NOT NULL AND p_table_name IS NOT NULL)
       OR (p_account_id_list IS NULL AND p_table_name IS NULL)
      )
   THEN
      DBMS_OUTPUT.put_line
         ('ERROR--Delete account operation failed-->Either accountIDList or tablename should be specified'
         );
      RETURN;
   END IF;

   IF (p_account_id_list IS NOT NULL)
   THEN
      DBMS_OUTPUT.put_line
            ('-- Parsing Account IDs passed in and inserting in tmp table --');

      WHILE INSTR (p_account_id_list_tmp, ',') > 0
      LOOP
         INSERT INTO tmp_accountidstable
                     (ID, status, MESSAGE)
            SELECT SUBSTR (p_account_id_list_tmp,
                           1,
                           (INSTR (p_account_id_list_tmp, ',') - 1)
                          ),
                   1, 'Okay to delete'
              FROM DUAL;

         p_account_id_list_tmp :=
            SUBSTR (p_account_id_list_tmp,
                    (INSTR (p_account_id_list_tmp, ',') + 1
                    ),
                    (  LENGTH (p_account_id_list_tmp)
                     - (INSTR (',', p_account_id_list_tmp))
                    )
                   );
      END LOOP;

      INSERT INTO tmp_accountidstable
                  (ID, status, MESSAGE)
         SELECT p_account_id_list_tmp, 1, 'Okay to delete'
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
         || p_table_name;

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
    * 4. Check if the account is a payee for usage that exists in the system
    * 5. Check if the account is a receiver of per subscription Recurring
    *    Charge
    * 6. Check for usage in soft/open closed interval
    * 7. Check for invoices in soft/open closed interval
    * 8. Check if the account contributes to group discount
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
																		       AND au.id_acc = ui.id_acc
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

    /* 4. Check if the account is a payee for usage that exists in the system */
	DBMS_OUTPUT.put_line ('-- Payee usage check --');
	
	UPDATE tmp_accountidstable tmp
		SET status = 0, 										/* failure */
			MESSAGE = 'Account is a payee with usage in the system!'				
	    WHERE status <> 0 
		    AND EXISTS (
				SELECT *							
					FROM t_acc_usage accU
					WHERE accU.id_payee = tmp.ID
					AND ROWNUM < 2);
					
   /* 5. Check if this account is receiver of per subscription RC */
   DBMS_OUTPUT.put_line
                  ('-- Receiver of per subscription Recurring Charge check --');

   UPDATE tmp_accountidstable tmp
      SET status = 0,                                             /* failure*/
          MESSAGE = 'Account is receiver of per subscription RC!'
    WHERE status <> 0 AND EXISTS (SELECT gsrm.id_acc
                                    FROM t_gsub_recur_map gsrm
                                   WHERE gsrm.id_acc = tmp.ID);

   /* 6. Check for invoices in soft closed or open usage in any of these  */
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

   /* 7. Check for 'soft close/open' usage in any of these accounts*/
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
																			  AND au.id_acc = ui.id_acc
                                   WHERE au.id_acc = tmp.ID);

   /* 8. Check if this account contributes to group discount */
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

      OPEN p_cur FOR
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
       INTO p_table_name;

      IF v_cur%NOTFOUND
      THEN
         EXIT;
      END IF;

      BEGIN
         EXECUTE IMMEDIATE    'DELETE FROM '
                           || p_table_name
                           || ' WHERE id_acc IN (SELECT ID FROM tmp_AccountIDsTable)';
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (   'Cannot delete from '
                                  || p_table_name
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

   /* IF (p_linked_server_name <> NULL)
    BEGIN
      Do payment server stuff here
    END*/

   /* If we are here, then all accounts should have been deleted   */
   IF (p_linked_server_name IS NOT NULL AND p_payment_server_dbname IS NOT NULL)
   THEN
      v_sql :=
            'delete t_ps_creditcard@'
         || p_linked_server_name
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
         || p_linked_server_name
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_ach table');
         RAISE seterror;
      END IF;
   END IF;

   IF (p_linked_server_name IS NULL AND p_payment_server_dbname IS NOT NULL)
   THEN
      v_sql :=
            'delete t_ps_creditcard@'
         || p_payment_server_dbname
         || ' WHERE id_acc in (SELECT ID FROM tmp_AccountIDsTable)';

      EXECUTE IMMEDIATE v_sql;

      IF (SQLCODE <> 0)
      THEN
         DBMS_OUTPUT.put_line ('Cannot delete from t_ps_creditcard table');
         RAISE seterror;
      END IF;

      v_sql :=
            'delete from t_ps_ach@'
         || p_payment_server_dbname
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

   OPEN p_cur FOR
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
            