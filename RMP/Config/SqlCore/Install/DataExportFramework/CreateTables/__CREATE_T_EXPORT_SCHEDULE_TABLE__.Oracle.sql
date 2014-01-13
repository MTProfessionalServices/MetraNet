
              CREATE TABLE t_export_schedule
              (
                id_rp_schedule NUMBER(10,0)  NOT NULL,
                id_rep_instance_id NUMBER(10,0)  NOT NULL,
                id_schedule NUMBER(10,0)  NOT NULL,
                c_sch_type VARCHAR2(10)  NOT NULL,
                dt_crt DATE NOT NULL,
                CONSTRAINT PK_t_export_Schedule PRIMARY KEY( id_rp_schedule )
              )
			 