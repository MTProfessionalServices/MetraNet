
CREATE TRIGGER trg_gsubmember_icb_rates ON t_gsubmember
AFTER INSERT, UPDATE 
AS
BEGIN
	DECLARE @id_acc int
	DECLARE @id_group int
	DECLARE new_members CURSOR LOCAL FOR
		SELECT id_acc, id_group
		FROM   inserted

	OPEN new_members
	FETCH NEXT FROM new_members INTO @id_acc, @id_group

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC recursive_inherit_sub
			@v_id_audit = NULL,
			@v_id_acc   = @id_acc,
			@v_id_sub   = NULL,
			@v_id_group = @id_group

		FETCH NEXT FROM new_members INTO @id_acc, @id_group
    END

	CLOSE new_members
	DEALLOCATE new_members
END;
