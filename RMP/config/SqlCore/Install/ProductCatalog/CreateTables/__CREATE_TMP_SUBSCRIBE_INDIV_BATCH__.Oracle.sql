
		      CREATE TABLE tmp_subscribe_individual_batch
		      ( /* Input */
		        id_acc number(10) NOT NULL,
		        id_sub number(10) NOT NULL,
		        id_po number(10) NOT NULL,
		        dt_start date NOT NULL, 
		        dt_end date NULL,
		        next_cycle_after_startdate varchar2(1) NOT NULL, /* Y or N */
		        next_cycle_after_enddate varchar2(1) NOT NULL, /* Y or N */
		        sub_guid raw(16) NULL,
		        /* Audit Info */
		        id_audit number(10) NOT NULL,
		        id_event number(10) NOT NULL,
		        id_userid number(10) NOT NULL,
		        id_entitytype number(10) NOT NULL,
		        /* Temporary Variables */
		        dt_adj_start date NULL,
		        dt_adj_end date NULL,
		        count number(10) NULL,
		        tauc_id_cycle_type number(10) NULL,
		        po_id_cycle_type number(10) NULL,
		        nm_display_name nvarchar2(255) NULL,
		        /* Output */
		        status number(10) NULL,
		        date_modified varchar2(1) NULL /* Y or N */
		      );

          CREATE UNIQUE INDEX idx_id_sub ON tmp_subscribe_individual_batch(id_sub);

