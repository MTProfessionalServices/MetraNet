
        CREATE OR REPLACE PROCEDURE SeqInsertGsubRecurInitialize(
            p_id_group_sub INT,
            p_id_prop INT,
            p_id_acc INT,
            p_tt_current DATE,
            p_tt_max DATE,
            p_status OUT INT )
        AS
            v_cnt   INT;
            v_id_po INT;
        BEGIN
            p_status := 0;

            FOR i IN
            (SELECT id_po 
            FROM T_SUB sub
            INNER JOIN T_GROUP_SUB gsub
            ON sub.id_group = gsub.id_group
            WHERE gsub.id_group = p_id_group_sub)
            LOOP
                v_id_po := i.id_po;
            END LOOP;

            /* Check that both account and PO have the same currency */
            IF (Dbo.IsAccountAndPOSameCurrency(p_id_acc, v_id_po) = '0') THEN
                /* MT_ACCOUNT_PO_CURRENCY_MISMATCH */
                p_status := -486604729;
                RETURN;
            END	IF;
               
               
            /* I admit this is a bit wierd, but what I am doing is detecting */
            /* a referential integrity failure without generating an error. */
            /* This is needed because SQL Server won't let one suppress the */
            /* RI failure (and this causes an exception up in ADO land). */
            /* This is a little more concise (and perhaps more performant) */
            /* than multiple queries up front. */
            INSERT INTO T_GSUB_RECUR_MAP(id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end) 
            SELECT s.id_group, r.id_prop, a.id_acc, vt_start, vt_end, p_tt_current, p_tt_max
            FROM T_SUB s
            CROSS JOIN T_ACCOUNT a
            CROSS JOIN T_RECUR r
            WHERE 
            s.id_group=p_id_group_sub
            AND
            a.id_acc=p_id_acc
            AND
            r.id_prop=p_id_prop;

            /* only one row is expected */
            IF SQL%rowcount <> 1
            THEN

                /* No row, look for specific RI failure to give better message */
                SELECT COUNT(1) INTO v_cnt FROM T_RECUR WHERE id_prop = p_id_prop;
                IF v_cnt = 0 THEN
                    /* MTPC_CHARGE_ACCOUNT_ONLY_ON_RC */
                    p_status := -490799065;
                    RETURN;
                END IF;

                SELECT COUNT(1) INTO v_cnt FROM T_ACCOUNT WHERE id_acc = p_id_acc;
                IF v_cnt = 0 THEN
                    /* KIOSK_ERR_ACCOUNT_NOT_FOUND */
                    p_status := -515899365;
                    RETURN;
                END IF;

                SELECT COUNT(1) INTO v_cnt FROM T_SUB WHERE id_group = p_id_group_sub;
                IF v_cnt = 0 THEN
                    /* Return E_FAIL absent better info */
                    p_status := -2147483607;
                    RETURN;
                END IF;

                /* Return E_FAIL absent better info */
                p_status := -2147483607;
            END IF;

            /* post-operation business rule check (relies on rollback of work done up until this point) */
            /* checks to make sure the receiver's payer's do not violate EBCR cycle constraints */
            p_status := Dbo.CheckGroupReceiverEBCRCons(p_tt_current, p_id_group_sub);
            IF (p_status = 1) THEN/* careful... success values between the function and the sproc differ */
                p_status := 0;
            END IF;

        END;
		