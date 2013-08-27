
/* Calculates public ICB rates for all subscribed accounts */
CREATE PROCEDURE recursive_inherit_sub_to_accs(
    @v_id_sub int
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @id_acc int
	DECLARE @id_group int
	DECLARE accounts CURSOR LOCAL FOR
		SELECT s.id_acc, s.id_group
        FROM   t_sub s
        WHERE  s.id_sub = @v_id_sub AND s.id_group IS NULL
        UNION ALL
        SELECT gm.id_acc, gm.id_group
        FROM   t_sub s
                INNER JOIN t_gsubmember gm ON gm.id_group = s.id_group
        WHERE  s.id_sub = @v_id_sub

	OPEN accounts
	FETCH NEXT FROM accounts INTO @id_acc, @id_group

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC recursive_inherit_sub
            @v_id_audit = NULL,
            @v_id_acc   = @id_acc,
            @v_id_sub   = NULL,
            @v_id_group = @id_group

		FETCH NEXT FROM accounts INTO @id_acc, @id_group
	END

	CLOSE accounts
	DEALLOCATE accounts
END
