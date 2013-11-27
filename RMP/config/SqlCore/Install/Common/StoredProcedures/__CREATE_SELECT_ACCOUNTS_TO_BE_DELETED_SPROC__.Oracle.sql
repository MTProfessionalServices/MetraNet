
			CREATE OR REPLACE PROCEDURE SelectAccountsToBeDeleted
				(i_accountIDList varchar2,
                 o_cursor OUT sys_refcursor)
			IS
				/* Break down into simple account IDs */
				/* This block of SQL can be used as an example to get  */
				/* the account IDs from the list of account IDs that are */
				/* passed in */
                v_accountIDList_tmp varchar2(4000) :=i_accountIDList ;

            BEGIN
                execute immediate 'truncate TABLE tmp_AccountIDsTable';

				dbms_output.put_line ('----------------------------------------------');
				dbms_output.put_line ('-Start of Account Deletion Stored Procedure --');
				dbms_output.put_line ('----------------------------------------------');

				dbms_output.put_line (' Parsing Account IDs passed in and inserting in tmp table --');

                WHILE INSTR(v_accountIDList_tmp,',') > 0
                LOOP
                    INSERT INTO tmp_AccountIDsTable (ID, status, message)
                        SELECT SUBSTR(v_accountIDList_tmp,1,(INSTR(v_accountIDList_tmp,',')-1)), 1, 'Okay to delete' from dual;
                    v_accountIDList_tmp := SUBSTR (v_accountIDList_tmp, (INSTR( v_accountIDList_tmp , ',' )+1),
                                       (LENGTH(v_accountIDList_tmp) - (INSTR(',', v_accountIDList_tmp))));
                END LOOP;
                INSERT INTO tmp_AccountIDsTable (ID, status, message)
                SELECT v_accountIDList_tmp, 1, 'Okay to delete' from dual;

				/* SELECT ID as one FROM #AccountIDsTable */

				/* Transitive Closure (check for folder/corporation) */
				dbms_output.put_line (' Inserting children (if any) into the tmp table --');

                INSERT INTO tmp_AccountIDsTable (ID, status, message)
                SELECT DISTINCT
                  aa.id_descendent,
                    1,
                    'Okay to delete'
                FROM
                  t_account_ancestor aa, tmp_AccountIDsTable tmp
                WHERE
                    tmp.ID = aa.id_ancestor AND
                    aa.num_generations > 0 AND
                NOT EXISTS (
                  SELECT
                      ID
                    FROM
                      tmp_AccountIDsTable tmp1
                    WHERE
                      tmp1.ID = aa.id_descendent);

                INSERT INTO tmp_AccountIDsTable (ID, status, message)
                SELECT DISTINCT
                  aa.id_descendent,
                    1,
                    'Okay to delete'
                FROM
                  t_account_ancestor aa where id_ancestor in (select id from  tmp_AccountIDsTable)
                    AND
                    aa.num_generations > 0 AND
                NOT EXISTS (
                  SELECT
                      ID
                    FROM
                      tmp_AccountIDsTable tmp1
                    WHERE
                      tmp1.ID = aa.id_descendent);

                dbms_output.put_line( '-- Account does not exists check --');
                UPDATE
                    tmp_AccountIDsTable tmp
                SET
                    status = 0, /* failure*/
                    message = 'Account does not exists!'
                WHERE
                    not EXISTS (
                        SELECT
                            1
                        FROM
                            t_account acc
                        WHERE
                            acc.id_acc = tmp.ID );

				/* SELECT * from #AccountIDsTable			 */
				/* Print out the accounts with their login names */
                open o_cursor for
				SELECT
					ID as accountID,
					nm_login as LoginName,
					message
				FROM
					tmp_AccountIDsTable a left outer join
					t_account_mapper b
				on
					a.ID = b.id_acc;

            end;

    