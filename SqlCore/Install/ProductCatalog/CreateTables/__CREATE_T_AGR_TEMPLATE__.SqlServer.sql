
	   CREATE TABLE t_agr_template
  (
     id_agr_template         INT identity NOT NULL,
     n_template_name         INT NOT NULL,
     nm_template_name        NVARCHAR(255) NOT NULL,
     n_template_description  INT NULL,
     nm_template_description NVARCHAR(255) NULL,
     created_date            DATETIME,
     created_by              INT NOT NULL,
     updated_date            DATETIME NULL,
     updated_by              INT NULL,
     available_start_date    DATETIME DEFAULT Getdate() NULL,
     available_end_date      DATETIME DEFAULT '2038-01-01' NULL,
     CONSTRAINT PK_T_AGR_TEMPLATE PRIMARY KEY (id_agr_template),
     CONSTRAINT UK_T_AGR_TEMPLATE1 UNIQUE (n_template_name),
     CONSTRAINT UK_T_AGR_TEMPLATE2 UNIQUE (nm_template_name)
  )
			
