
					create table t_sub_history (
					id_sub NUMBER(10) not null,
					id_sub_ext  raw(16) not null,
					id_acc NUMBER(10) null,
					id_po NUMBER(10) not null,
					dt_crt date not null,
					id_group NUMBER(10) null,
					vt_start date not null,
					vt_end date not null,
					tt_start date not null,
					tt_end date not null,
          			tx_quoting_batch raw(16) NULL,
					CONSTRAINT date_sub_hist_check1 check ( vt_start <= vt_end)
					)
					