
      create global temporary table tmp_unsubscribe_indiv_batch
				(id_acc number(10), 
				id_po number(10), 
				id_sub number(10), 
				vt_start date, vt_end date, 
				uncorrected_vt_start date, 
				uncorrected_vt_end date, 
				tt_now date, 
				status number(10),	
				/*  audit info */
				id_audit number(10) NOT NULL,
				id_event number(10) NOT NULL,
				id_userid number(10) NOT NULL,
				id_entitytype number(10) NOT NULL,				
				/*  Values set by the SQL execution. */
				nm_display_name nvarchar2(255) NULL
		  ) on commit delete rows;

      create index idx_tmp_unsub_indiv_batch on tmp_unsubscribe_indiv_batch(id_acc, id_sub);

