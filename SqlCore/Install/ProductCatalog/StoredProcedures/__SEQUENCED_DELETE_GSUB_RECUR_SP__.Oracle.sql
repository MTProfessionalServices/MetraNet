
        CREATE OR REPLACE PROCEDURE SequencedDeleteGsubRecur (
            p_id_group_sub INT,
            p_id_prop INT,
            p_vt_start DATE,
            p_vt_end DATE,
            p_tt_current DATE,
            p_tt_max DATE,
            p_status OUT INT )
        AS
        BEGIN
            p_status := 0;

            INSERT INTO T_GSUB_RECUR_MAP(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
            SELECT id_prop, id_group, id_acc, Dbo.Addsecond(p_vt_end) vt_start, vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end
            FROM T_GSUB_RECUR_MAP 
            WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start < p_vt_start AND vt_end > p_vt_end AND tt_end = p_tt_max;

            /* Valid time update becomes bi-temporal insert and update */
            INSERT INTO T_GSUB_RECUR_MAP(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
            SELECT id_prop, id_group, id_acc, vt_start, Dbo.Subtractsecond(p_vt_start) AS vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end 
            FROM T_GSUB_RECUR_MAP WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;
            UPDATE T_GSUB_RECUR_MAP SET tt_end = Dbo.Subtractsecond( p_tt_current) WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start < p_vt_start AND vt_end >= p_vt_start AND tt_end = p_tt_max;


            /* Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history) */
            INSERT INTO T_GSUB_RECUR_MAP(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
            SELECT id_prop, id_group, id_acc, Dbo.Addsecond(p_vt_end) AS vt_start, vt_end, p_tt_current AS tt_start, p_tt_max AS tt_end 
            FROM T_GSUB_RECUR_MAP WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;
            UPDATE T_GSUB_RECUR_MAP SET tt_end = Dbo.Subtractsecond(p_tt_current) WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start <= p_vt_end AND vt_end > p_vt_end AND tt_end = p_tt_max;

            /* Now we delete any interval contained entirely in the interval we are deleting. */
            /* Transaction table delete is really an update of the tt_end */
            /*   [----------------]                 (interval that is being modified) */
            /* [------------------------]           (interval we are deleting) */
            UPDATE T_GSUB_RECUR_MAP SET tt_end = Dbo.Subtractsecond(p_tt_current)
            WHERE id_prop = p_id_prop AND id_group = p_id_group_sub AND vt_start >= p_vt_start AND vt_end <= p_vt_end AND tt_end = p_tt_max;

        EXCEPTION
            WHEN OTHERS THEN
            p_status := SQLCODE;
        END;
        