
    create procedure SequencedInsertAccOwnership
		@p_id_owner	int,
		@p_id_owned	int,
		@p_id_relation_type	int,
		@p_percent int,
		@p_vt_start	datetime,
		@p_vt_end	datetime,
		@p_tt_current	datetime,
		@p_tt_max	datetime,
		@p_status	int	OUTPUT
    as
    begin
    DECLARE	@cnt INTEGER
    SET	@p_status	=	0
    -- Check referential integrity upfront without
    -- running multiple	select queries.	I	just took
    -- this	appoach	from SequencedInsertGsubRecur	stored proc
    INSERT INTO	t_acc_ownership(id_owner,	id_owned,	id_relation_type,	n_percent,	vt_start,	vt_end,	tt_start,	tt_end)	
    SELECT owner.id_acc, owned.id_acc, ed.id_enum_data,	@p_percent,	@p_vt_start, @p_vt_end,	@p_tt_current, @p_tt_max
    FROM t_account owner
    CROSS	JOIN t_account owned
    CROSS	JOIN t_enum_data ed
    WHERE	
    owner.id_acc=@p_id_owner
    AND
    owned.id_acc=@p_id_owned
    AND
    ed.id_enum_data=@p_id_relation_type
    IF @@rowcount	<> 1 
    BEGIN
    -- No	row, look	for	specific RI	failure	to give	better message
    SELECT @cnt	=	COUNT(*) FROM	t_account	where	id_acc = @p_id_owner
    IF @cnt	=	0
    BEGIN
    -- KIOSK_ERR_ACCOUNT_NOT_FOUND
    SET	@p_status	=	-515899365
    RETURN
    END
    SELECT @cnt	=	COUNT(*) FROM	t_account	where	id_acc = @p_id_owned
    IF @cnt	=	0
    BEGIN
    -- KIOSK_ERR_ACCOUNT_NOT_FOUND
    SET	@p_status	=	-515899365
    RETURN
    END
    SELECT @cnt	=	COUNT(*) FROM	t_enum_data	where	id_enum_data = @p_id_relation_type
    IF @cnt	=	0
    BEGIN
    -- E_FAIL
    SET	@p_status	=	-2147483607
    RETURN
    END
    END
    END
        