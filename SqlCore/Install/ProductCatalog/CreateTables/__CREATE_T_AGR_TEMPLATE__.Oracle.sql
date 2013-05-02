
	   CREATE TABLE t_agr_template
  (
     id_agr_template         number(10) NOT NULL,
     n_template_name         number(10) NOT NULL,
     nm_template_name        VARCHAR(255) NOT NULL,
     n_template_description  number(10) NULL,
     nm_template_description VARCHAR(255) NULL,
     created_date            DATE,
     created_by              number(10) NOT NULL,
     updated_date            DATE NULL,
     updated_by              number(10) NULL,
     available_start_date    DATE DEFAULT sysdate NULL,
     available_end_date      DATE DEFAULT TO_DATE('2038-01-01', 'YYYY-MM-DD') NULL,
     CONSTRAINT PK_T_AGR_TEMPLATE PRIMARY KEY (id_agr_template),
     CONSTRAINT UK_T_AGR_TEMPLATE1 UNIQUE (n_template_name),
     CONSTRAINT UK_T_AGR_TEMPLATE2 UNIQUE (nm_template_name)
  )
			
