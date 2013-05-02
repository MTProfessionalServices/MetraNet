
 CREATE TABLE t_contact_info (
    id_acc int NOT NULL,
		c_firstname varchar (40) NULL, 
		c_lastname varchar (40) NULL, 
		c_email varchar (40) NULL, 
		c_phonenumber varchar (40) NULL,
		c_contacttype int NOT NULL, 
		c_company varchar (40) NULL, 
		c_address1 varchar (40) NULL, 
		c_address2 varchar (40) NULL,
		c_address3 varchar (40) NULL, 
		c_city varchar (40) NULL, 
		c_state varchar (40) NULL, 
		c_zip varchar (40) NULL,
		c_country varchar (40) NULL, 
		c_fax varchar (40) NULL, 
		c_middleinitial varchar (1) NULL,
		CONSTRAINT PK_t_contact_info PRIMARY KEY  (id_acc, c_contacttype)  ) 
	     