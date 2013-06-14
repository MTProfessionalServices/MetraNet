
CREATE OR REPLACE
PROCEDURE UpdatePrivateTempates
(
  id_template int
)    
AS
  id_account int;
  id_parent_account_template int;
  id_acc_type int;
BEGIN
    SELECT id_acc_type, id_folder
    INTO UpdatePrivateTempates.id_acc_type, UpdatePrivateTempates.id_account
    FROM t_acc_template WHERE id_acc_template = id_template;
  
  /*delete old values for properties of private templates of current account and child accounts*/
  DELETE
    FROM t_acc_template_props tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);
  
  /*delete old values for subscriptions of private templates of current account and child accounts*/
  DELETE
    FROM t_acc_template_subs tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);
  
  /*insert new values for private template from public template for all sub-tree of current account.*/
  INSERT INTO t_acc_template_props
          (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
   SELECT seq_t_acc_template_props.NextVal, id_acc_template, nm_prop_class, nm_prop, nm_value
     FROM t_acc_template_props_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);

  INSERT INTO t_acc_template_subs
          (id_po, id_group, id_acc_template, vt_start, vt_end)
   SELECT id_po, id_group, id_acc_template, vt_start, vt_end
     FROM t_acc_template_subs_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
          WHERE aa.id_ancestor = UpdatePrivateTempates.id_account);

/*  INSERT INTO t_acc_template_props 
          (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
        SELECT
          seq_t_acc_template_props.NextVal, id_acc_template, nm_prop_class, nm_prop, nm_value
        FROM 
          t_acc_template_props_pub
        WHERE
          id_acc_template IN
        (SELECT t.id_acc_template
           FROM vw_account_ancestor aa
                LEFT JOIN t_acc_template t on aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
           START WITH aa.id_ancestor = id_account
           CONNECT BY PRIOR aa.id_descendent = aa.id_ancestor
         UNION ALL
         SELECT id_template FROM DUAL);*/

    /*insert private template of an account's parent*/
    INSERT INTO t_acc_template_props
                (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT seq_t_acc_template_props.NextVal, UpdatePrivateTempates.id_template, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp
           JOIN (SELECT ROWNUM AS rownumber, b.*
                   FROM (SELECT aa.num_generations, t.id_acc_template
                           FROM t_account_ancestor aa
                                JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
                          WHERE aa.id_descendent = id_account AND aa.id_descendent <> aa.id_ancestor
                        ORDER BY aa.num_generations) b
                ) a ON tatpp.id_acc_template = a.id_acc_template
     WHERE a.rownumber = 1
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = UpdatePrivateTempates.id_template AND t.nm_prop = tatpp.nm_prop);

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, UpdatePrivateTempates.id_template, vt_start, vt_end
      FROM t_acc_template_subs tatps
           JOIN (SELECT ROWNUM AS rownumber, b.*
                   FROM (SELECT aa.num_generations, t.id_acc_template
                           FROM t_account_ancestor aa
                                JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = UpdatePrivateTempates.id_acc_type
                          WHERE aa.id_descendent = id_account AND aa.id_descendent <> aa.id_ancestor
                        ORDER BY aa.num_generations) b
                ) a ON tatps.id_acc_template = a.id_acc_template
     WHERE a.rownumber = 1
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = UpdatePrivateTempates.id_template AND t.id_po = tatps.id_po);

   /*insert new values from parent private templates*/
   FOR rec IN (SELECT aa.id_ancestor, aa.id_descendent, a1.id_acc_template AS id_parent_acc_template, a2.id_acc_template AS current_id, aa.num_generations
                FROM t_account_ancestor aa
                     JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = UpdatePrivateTempates.id_acc_type
                     JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = UpdatePrivateTempates.id_acc_type
               WHERE aa.id_ancestor = id_account
              ORDER BY aa.num_generations ASC
             ) LOOP
    /*recursive merge properties to private template of each level of child account from private template of current account */
    INSERT INTO t_acc_template_props
                (id_prop, id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT seq_t_acc_template_props.NextVal, rec.current_id, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp 
     WHERE tatpp.id_acc_template = rec.id_parent_acc_template
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = rec.current_id AND t.nm_prop = tatpp.nm_prop);

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, rec.current_id, vt_start, vt_end
      FROM t_acc_template_subs tatps
     WHERE tatps.id_acc_template = rec.id_parent_acc_template
       AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = rec.current_id AND t.id_po = tatps.id_po);

   END LOOP;
END;
