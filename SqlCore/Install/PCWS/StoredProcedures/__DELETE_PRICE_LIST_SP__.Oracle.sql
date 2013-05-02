
        CREATE OR REPLACE PROCEDURE sp_DeletePricelist 
        (
            p_a_plID INT,
            p_status OUT INT 
        )
        AS

            v_n_pl_maps INT;
            v_n_def_acc INT;
            TYPE CursorVar IS REF CURSOR;
            v_CursorVar CursorVar;
            v_id_rs INT;

        BEGIN
            
            SELECT COUNT(1) INTO v_n_pl_maps FROM T_PL_MAP WHERE id_pricelist = p_a_plID;
            IF (v_n_pl_maps > 0) THEN
                p_status := 1;
                RETURN;
            END IF;

            SELECT COUNT(1) INTO v_n_def_acc FROM T_AV_INTERNAL WHERE c_pricelist = p_a_plID;
            IF (v_n_def_acc > 0) THEN
                p_status := 2;
                RETURN;
            END IF;
            
            OPEN v_CursorVar FOR SELECT id_sched FROM T_RSCHED
            WHERE id_pricelist = p_a_plID;

            LOOP
                FETCH v_CursorVar INTO v_id_rs;
                EXIT WHEN v_CursorVar%NOTFOUND;
                sp_DeleteRateSchedule (v_id_rs);
            END LOOP;

            CLOSE v_CursorVar;

            DELETE FROM T_PRICELIST WHERE id_pricelist = p_a_plID;
			DELETE FROM T_EP_PRICELIST WHERE id_prop = p_a_plID;
            Deletebaseprops (p_a_plID);
            
            p_status := 0;
            RETURN;
        END;
		