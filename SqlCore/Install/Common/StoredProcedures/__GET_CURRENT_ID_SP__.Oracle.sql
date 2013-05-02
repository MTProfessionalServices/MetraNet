
       CREATE OR REPLACE PROCEDURE GetCurrentID (p_nm_current IN varchar2,
                                                 p_id_current OUT int
       )
       AS
          /* Needs to be autonomous transaction to avoid error */
          /* ORA-08177: can't serialize access for this transaction */
          /* when isolation mode is SERIALIZABLE. */
          PRAGMA AUTONOMOUS_TRANSACTION;
          v_id_next   t_current_id.id_current%TYPE;
       BEGIN
          /* Note: Always throws exception on failure */

          /* Init with failure value */
          p_id_current   := -99;

          UPDATE t_current_id
          SET id_current    = id_current + 1
          WHERE nm_current = p_nm_current
          RETURNING id_current
          INTO v_id_next;

          IF sql%FOUND
          THEN
             p_id_current   := v_id_next - 1;
             COMMIT;
          ELSE
             ROLLBACK;
             raise_application_error (-20001,
                                      'T_CURRENT_ID Update failed for '
                                      || p_nm_current
             );
          END IF;
       END;
       