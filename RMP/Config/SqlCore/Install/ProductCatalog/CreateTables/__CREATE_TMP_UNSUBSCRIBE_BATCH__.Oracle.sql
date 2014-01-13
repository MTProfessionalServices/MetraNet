
        CREATE TABLE tmp_unsubscribe_batch
			      (id_acc number(10), 
			      id_po number(10), 
			      id_group number(10), 
			      vt_start date, 
			      vt_end date, 
			      uncorrected_vt_start date, 
			      uncorrected_vt_end date, 
			      tt_now date, 
			      id_gsub_corp_account number(10), 
			      status number(10),
      	
			      /*  audit info */
			      id_audit number(10) NOT NULL,
			      id_event number(10) NOT NULL,
			      id_userid number(10) NOT NULL,
			      id_entitytype number(10) NOT NULL,
      	
			      /*  Values set by the SQL execution. */
			      nm_display_name nvarchar2(255) NULL
			      )
			  