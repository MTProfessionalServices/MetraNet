
    CREATE OR REPLACE PROCEDURE GetIdBlock (p_block_size number,
                                            p_sequence_name varchar2,
                                            p_block_start OUT number
    )
    AS
       /* Needs to be autonomous transaction to avoid error */
       /* ORA-08177: can't serialize access for this transaction */
       /* when isolation mode is SERIALIZABLE. */
       PRAGMA AUTONOMOUS_TRANSACTION;
       v_block_next   t_current_id.id_current%TYPE;
    BEGIN
       /* Note: Always throws exception on failure */

       /* Init with failure value */
       p_block_start   := -99;

       UPDATE t_current_id
       SET id_current    = id_current + p_block_size
       WHERE nm_current = p_sequence_name
       RETURNING id_current
       INTO v_block_next;

       IF sql%FOUND
       THEN
          p_block_start   := v_block_next - p_block_size;
          COMMIT;
       ELSE
          ROLLBACK;
          raise_application_error (-20001,
                                   'T_CURRENT_ID Update failed for '
                                   || p_sequence_name
          );
       END IF;
    END;
    