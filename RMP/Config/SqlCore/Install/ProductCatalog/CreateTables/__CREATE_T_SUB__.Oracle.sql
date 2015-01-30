
					create table T_SUB (
					ID_SUB NUMBER(10) not null,
					id_sub_ext raw(16) not null,
					ID_ACC NUMBER(10) null,
					id_group number(10) null,
					ID_PO NUMBER(10) not null,
					DT_CRT DATE NULL,
					vt_start date not null,
					vt_end date not null,
          			tx_quoting_batch raw(16) NULL,
					CONSTRAINT pk_t_sub PRIMARY KEY (id_sub),
					CONSTRAINT date_sub_check1 check ( vt_start <= vt_end)
					)
					