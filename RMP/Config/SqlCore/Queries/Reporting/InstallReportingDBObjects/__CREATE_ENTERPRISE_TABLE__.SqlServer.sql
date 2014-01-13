
	   CREATE TABLE t_enterprise (
	   	nm_space varchar (100) NOT NULL,
	   	c_name varchar (40) NULL,
	   	c_company varchar (40) NULL,
	   	c_address1 varchar (40) NULL,
	   	c_address2 varchar (40) NULL,
	   	c_address3 varchar (40) NULL,
	   	c_city varchar (40) NULL,
	   	c_state varchar (40) NULL,
	   	c_zip varchar (40) NULL,
	   	c_country varchar (40) NULL,
	   	c_phonenumber varchar (40) NULL,
	   	c_fax varchar (40) NULL,
	   	c_website varchar (100) NULL,
	   	c_billQues_phone varchar (40) NULL,
	   	c_remit_name varchar (40) NULL,
	   	c_remit_company varchar (40) NULL,
	   	c_remit_address1 varchar (40) NULL,
	   	c_remit_address2 varchar (40) NULL,
	   	c_remit_address3 varchar (40) NULL,
	   	c_remit_city varchar (40) NULL,
	   	c_remit_state varchar (40) NULL,
	   	c_remit_zip varchar (40) NULL,
	   	c_remit_country varchar (40) NULL 
		CONSTRAINT PK_t_enterprise PRIMARY KEY NONCLUSTERED (nm_space)) 
	     