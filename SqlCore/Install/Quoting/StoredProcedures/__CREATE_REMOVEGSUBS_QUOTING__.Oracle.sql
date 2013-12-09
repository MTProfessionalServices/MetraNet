
CREATE OR REPLACE PROCEDURE REMOVEGSUBS_QUOTING (
   p_id_sub             INT,
   p_systemdate         DATE,
   p_status       OUT   INT
)
AS
   v_groupid    INT;
   v_maxdate    DATE;
   v_nmembers   INT;
   v_icbid      INT;
BEGIN
   p_status := 0;

   FOR i IN (SELECT id_group, dbo.mtmaxdate () mtmaxdate
               FROM t_sub
              WHERE id_sub = p_id_sub)
   LOOP
      v_groupid := i.id_group;
      v_maxdate := i.mtmaxdate;
   END LOOP;

   FOR i IN (SELECT DISTINCT id_pricelist
                        FROM t_pl_map
                       WHERE id_sub = p_id_sub)
   LOOP
      v_icbid := i.id_pricelist;
   END LOOP;

   DELETE FROM t_recur_window rw
         WHERE rw.C__SUBSCRIPTIONID = p_id_sub;

   DELETE FROM t_gsub_recur_map
         WHERE id_group = v_groupid;

   DELETE FROM t_recur_value
         WHERE id_sub = p_id_sub;

   /* id_po is overloaded.  If b_group == Y then id_po is */
   /* the group id otherwise id_po is the product offering id. */
   DELETE FROM t_acc_template_subs
         WHERE id_group = v_groupid AND id_po IS NULL;

   /* Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables */
   DELETE FROM t_pl_map
         WHERE id_sub = p_id_sub;

   UPDATE t_recur_value
      SET tt_end = p_systemdate
    WHERE id_sub = p_id_sub AND tt_end = v_maxdate;

   UPDATE t_sub_history
      SET tt_end = p_systemdate
    WHERE tt_end = v_maxdate AND id_sub = p_id_sub;

   DELETE FROM t_sub
         WHERE id_sub = p_id_sub;
         
   DELETE FROM t_char_values 
         WHERE id_entity = p_id_sub;

   IF (v_icbid IS NOT NULL)
   THEN
      sp_deletepricelist (v_icbid, p_status);

      IF p_status <> 0
      THEN
         RETURN;
      END IF;
   END IF;

   UPDATE t_group_sub
      SET tx_name =
             CAST ('[DELETED ' || CAST (SYSDATE AS NVARCHAR2 (22)) || ']'
                   || tx_name AS NVARCHAR2 (255)
                  )
    WHERE id_group = v_groupid;
END;
    
