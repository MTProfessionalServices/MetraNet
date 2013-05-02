
           CREATE TABLE t_site_user (nm_login nvarchar2(255) NOT NULL,
         id_site NUMBER(10) NOT NULL, id_profile NUMBER(10) NULL, CONSTRAINT
         PK_t_site_user PRIMARY KEY (nm_login, id_site))
       