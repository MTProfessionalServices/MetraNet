
        CREATE OR REPLACE PROCEDURE SequencedUpsertGsubRecur( 
            p_id_group_sub INT,
            p_id_prop INT,
            p_id_acc INT,
            p_vt_start DATE,
            p_vt_end DATE,
            p_tt_current DATE,
            p_tt_max DATE,
			p_allow_acc_po_curr_mismatch INTEGER default 0,
            p_status OUT INT )
        AS
            v_id_po INT;
        BEGIN
            p_status := 0;

            FOR i IN (SELECT id_po 
            FROM T_SUB sub
            INNER JOIN T_GROUP_SUB gsub
            ON sub.id_group = gsub.id_group
            WHERE gsub.id_group = p_id_group_sub) LOOP
                v_id_po := i.id_po;
            END LOOP;

            /* Check that both account and PO have the same currency only when @p_allow_acc_po_curr_mismatch flag is 0 */
            IF (NVL(p_allow_acc_po_curr_mismatch,0) = 0)
			THEN 
				IF (Dbo.IsAccountAndPOSameCurrency(p_id_acc, v_id_po) = '0')
				THEN
					/* MT_ACCOUNT_PO_CURRENCY_MISMATCH */
					p_status := -486604729;
					RETURN;
				END	IF;
			END IF;

            SequencedDeleteGsubRecur (p_id_group_sub, p_id_prop, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
            IF p_status <> 0 THEN 
                RETURN;
            END IF;
            SequencedInsertGsubRecur (p_id_group_sub, p_id_prop, p_id_acc, p_vt_start, p_vt_end, p_tt_current, p_tt_max, p_status);
        END;
        