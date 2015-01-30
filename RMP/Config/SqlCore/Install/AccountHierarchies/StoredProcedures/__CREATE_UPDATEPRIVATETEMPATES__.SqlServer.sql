
CREATE PROCEDURE UpdatePrivateTempates
(
	@id_template INT,
	@p_systemdate  DATETIME
)    
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @id_account INT
	DECLARE @id_parent_account_template INT
	DECLARE @id_acc_type INT
	
	SELECT @id_acc_type = id_acc_type, @id_account = id_folder
	  FROM t_acc_template WHERE id_acc_template = @id_template
	
  /*delete old values for properties of private templates of current account and child accounts*/
  DELETE tp
    FROM t_acc_template_props tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)
  
  /*delete old values for subscriptions of private templates of current account and child accounts*/
  DELETE tp
    FROM t_acc_template_subs tp
   WHERE tp.id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)
  
  /*insert new values for private template from public template for all sub-tree of current account.*/
  INSERT INTO t_acc_template_props 
          (id_acc_template, nm_prop_class, nm_prop, nm_value)
   SELECT id_acc_template, nm_prop_class, nm_prop, nm_value
     FROM t_acc_template_props_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)

  INSERT INTO t_acc_template_subs
          (id_po, id_group, id_acc_template, vt_start, vt_end)
   SELECT id_po, id_group, id_acc_template, vt_start, vt_end
     FROM t_acc_template_subs_pub
    WHERE id_acc_template IN
        (SELECT t.id_acc_template
           FROM t_account_ancestor aa
                JOIN t_acc_template t on aa.id_descendent = t.id_folder AND t.id_acc_type = @id_acc_type
          WHERE aa.id_ancestor = @id_account)

    /*insert private template of an account's parent*/
    INSERT INTO t_acc_template_props
                (id_acc_template, nm_prop_class, nm_prop, nm_value)
    SELECT @id_template, nm_prop_class, nm_prop, nm_value 
      FROM t_acc_template_props tatpp
           JOIN (SELECT TOP 1 aa.num_generations, t.id_acc_template
                   FROM t_account_ancestor aa
                        JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = @id_acc_type
                  WHERE aa.id_descendent = @id_account AND aa.id_descendent <> aa.id_ancestor
                 ORDER BY aa.num_generations
                ) a ON tatpp.id_acc_template = a.id_acc_template
     WHERE NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = @id_template AND t.nm_prop = tatpp.nm_prop)

    INSERT INTO t_acc_template_subs
                (id_po, id_group, id_acc_template, vt_start, vt_end)
    SELECT id_po, id_group, @id_template, vt_start, vt_end
      FROM t_acc_template_subs tatps
           JOIN (SELECT TOP 1 aa.num_generations, t.id_acc_template
                   FROM t_account_ancestor aa
                        JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.id_acc_type = @id_acc_type
                  WHERE aa.id_descendent = @id_account AND aa.id_descendent <> aa.id_ancestor
                 ORDER BY aa.num_generations
                ) a ON tatps.id_acc_template = a.id_acc_template
     WHERE NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = @id_template AND t.id_po = tatps.id_po)

	--select hierarchy structure of account's tree.
	DECLARE @id_parent_acc_template INT
	DECLARE @current_id INT
	DECLARE db_cursor CURSOR FOR 
	        SELECT ISNULL(pa.id_acc_template, a1.id_acc_template) AS id_parent_acc_template, a2.id_acc_template AS current_id
			FROM   t_account_ancestor aa
					JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = @id_acc_type
					JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = @id_acc_type
					LEFT JOIN (
					SELECT t2.id_acc_template, a3.id_descendent
					FROM   t_account_ancestor a3
							JOIN t_acc_template t2 ON a3.id_ancestor = t2.id_folder AND t2.id_acc_type = @id_acc_type
					WHERE  num_generations =
							(SELECT MIN(num_generations)
							FROM   t_account_ancestor ac
									JOIN t_acc_template t3 ON ac.id_ancestor = t3.id_folder
							WHERE  ac.id_descendent = a3.id_descendent AND num_generations > 0)

					) pa ON pa.id_descendent = aa.id_descendent
			WHERE aa.id_ancestor = @id_account AND aa.num_generations > 0
			ORDER BY aa.num_generations ASC
	
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @id_parent_acc_template, @current_id
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		--recursive merge properties to private template of each level of child account from private template of current account 
		INSERT INTO t_acc_template_props
					(id_acc_template, nm_prop_class, nm_prop, nm_value)
		SELECT @current_id, nm_prop_class, nm_prop, nm_value 
		  FROM t_acc_template_props tatpp 
		 WHERE tatpp.id_acc_template = @id_parent_acc_template
		   AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = @current_id AND t.nm_prop = tatpp.nm_prop)
		
		INSERT INTO t_acc_template_subs
					(id_po, id_group, id_acc_template, vt_start, vt_end)
		SELECT id_po, id_group, @current_id, vt_start, vt_end
		  FROM t_acc_template_subs tatps
		 WHERE tatps.id_acc_template = @id_parent_acc_template
		   AND NOT EXISTS (SELECT 1 FROM t_acc_template_subs t WHERE t.id_acc_template = @current_id AND t.id_po = tatps.id_po)
		
		FETCH NEXT FROM db_cursor INTO @id_parent_acc_template, @current_id
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor
END
