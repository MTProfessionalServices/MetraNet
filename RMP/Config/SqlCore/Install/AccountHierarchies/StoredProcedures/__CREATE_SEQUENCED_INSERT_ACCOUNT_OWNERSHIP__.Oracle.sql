
    create or replace procedure SequencedInsertAccOwnership
		(p_id_owner	int,
		p_id_owned	int,
		p_id_relation_type	int,
		p_percent int,
		p_vt_start	date,
		p_vt_end	date,
		p_tt_current	TIMESTAMP,
		p_tt_max	TIMESTAMP,
		p_status OUT int)
    as
    p_cnt INT;
    begin
    p_status	:=	0;
    INSERT INTO	t_acc_ownership(id_owner,	id_owned,	id_relation_type,	n_percent,	vt_start,	vt_end,	tt_start,	tt_end)	
    SELECT owner.id_acc, owned.id_acc, ed.id_enum_data,	p_percent,	p_vt_start, p_vt_end,	p_tt_current, p_tt_max
    FROM t_account owner
    CROSS	JOIN t_account owned
    CROSS	JOIN t_enum_data ed
    WHERE	
    owner.id_acc=p_id_owner
    AND
    owned.id_acc=p_id_owned
    AND
    ed.id_enum_data=p_id_relation_type;
    IF (SQL%rowcount	<> 1) then
			SELECT COUNT(*) into p_cnt FROM	t_account	where	id_acc = p_id_owner;
			IF (p_cnt	=	0) then
				p_status	:=	-515899365;
			else
			SELECT COUNT(*) into p_cnt FROM	t_account	where	id_acc = p_id_owned;
			IF (p_cnt	=	0) then
			p_status	:=	-515899365;
			ELSE
			SELECT COUNT(*) into p_cnt FROM	t_enum_data	where	id_enum_data = p_id_relation_type;
			IF (p_cnt	=	0) then
			p_status	:=	-2147483607;
			END if;
			END if;
			END if;
		end IF;
    END;
        