
CREATE PROCEDURE UpdatePrivateTempates
(
	@id_template INT
)    
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @id_account INT;
	DECLARE @id_parent_account_template INT;
	DECLARE @id_acc_type INT;
	
	SELECT @id_acc_type = id_acc_type, @id_account = id_folder
	  FROM t_acc_template WHERE id_acc_template = @id_template;
	
  /*delete old values for properties of private templates of current account and child accounts*/
  DELETE tp
    FROM t_acc_template_props tp
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

	--select hierarchy structure of account's tree.
	DECLARE @id_parent_acc_template INT
	DECLARE @current_id INT
	DECLARE db_cursor CURSOR FOR 
	          SELECT a1.id_acc_template AS id_parent_acc_template, a2.id_acc_template AS current_id
                FROM t_account_ancestor aa
                     JOIN t_acc_template a1 on aa.id_ancestor = a1.id_folder AND a1.id_acc_type = @id_acc_type
                     JOIN t_acc_template a2 on aa.id_descendent = a2.id_folder AND a2.id_acc_type = @id_acc_type
               WHERE aa.id_ancestor = @id_account
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
		   AND NOT EXISTS (SELECT 1 FROM t_acc_template_props t WHERE t.id_acc_template = @current_id AND t.nm_prop = tatpp.nm_prop);
			
		FETCH NEXT FROM db_cursor INTO @id_parent_acc_template, @current_id
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor
END
