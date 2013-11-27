
IF EXISTS (SELECT * FROM sysobjects where name = 't_account_role') DROP TABLE t_account_role
IF EXISTS (SELECT * FROM sysobjects where name = 't_path_capability') DROP TABLE t_path_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_account_extension_capability') DROP TABLE t_account_extension_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_condition_capability') DROP TABLE t_condition_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_access_type_capability') DROP TABLE t_access_type_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_capability_instance') DROP TABLE t_capability_instance

IF EXISTS (SELECT * FROM sysobjects where name = 't_capability_class') DROP TABLE t_capability_class
IF EXISTS (SELECT * FROM sysobjects where name = 't_ID_principal') DROP TABLE t_ID_principal
IF EXISTS (SELECT * FROM sysobjects where name = 't_role') DROP TABLE t_role


-- IF EXISTS (SELECT * FROM sysobjects where name = 't_composite_capability_class') DROP TABLE t_composite_capability_class



CREATE TABLE t_ID_principal (id_principal int identity (1,1) NOT NULL, CONSTRAINT 
			PK_t_ID_principal PRIMARY KEY CLUSTERED (id_principal))


/*
Probably need to add support for localizable name and description
*/

CREATE TABLE t_role (	id_role int NOT NULL identity(1, 1), 
			tx_name VARCHAR(255), 
			tx_desc VARCHAR(255)  CONSTRAINT PK_t_role PRIMARY KEY CLUSTERED (
				 id_role))


/*
ISSUE: There is no way to know whether a principal is associated with account or role
*/
CREATE TABLE t_account_role (	id_acc int NOT 
				 NULL, 
				id_role int NOT NULL CONSTRAINT PK_t_account_role PRIMARY KEY CLUSTERED (
				 id_acc, id_role), FOREIGN KEY (id_acc) REFERENCES 
				 t_account, FOREIGN KEY (id_role) REFERENCES 
				 t_role)


/*
ISSUE: composite capabilities don't have just one editor, rather a separate editor for every contained capability
how do we express that?

Solved below: A composite capability will have entries in t_composite_capability_class for every contained capability class

*/

CREATE TABLE t_capability_class (id_cap_class int NOT 
				 NULL identity(1,1) CONSTRAINT PK_t_capability_class PRIMARY KEY CLUSTERED, 
				tx_guid VARCHAR(255) NOT NULL,
				tx_desc VARCHAR(2000) NOT NULL,
				/*
				if editor is null then default editor is invoked
				*/
				tx_editor VARCHAR(255) NULL)

/*
CREATE TABLE t_composite_capability_class (id_composite_cap_class int NOT 
				 NULL, 
				id_contained_cap_class int NOT 
				 NULL, 
				tx_guid VARCHAR(255) NOT NULL,
				CONSTRAINT PK_t_composite_capability_class PRIMARY KEY CLUSTERED(id_composite_cap_class, id_contained_cap_class),
				FOREIGN KEY (id_composite_cap_class) REFERENCES t_capability_class,
				FOREIGN KEY (id_contained_cap_class) REFERENCES t_capability_class)
*/

CREATE TABLE t_capability_instance (id_cap_instance int NOT 
				 NULL identity(1,1), 
				id_parent_cap_instance int NULL,
				id_acc int NULL,
				id_role int NULL,
				id_cap_class int NOT NULL
				 CONSTRAINT PK_t_capability_instance PRIMARY KEY CLUSTERED(id_cap_instance), 
				-- FOREIGN KEY (id_cap_class) REFERENCES t_capability_class,
				FOREIGN KEY (id_acc) REFERENCES t_account,
				FOREIGN KEY (id_role) REFERENCES t_role,
				CHECK(id_acc IS NULL OR id_role IS NULL))

CREATE TABLE t_access_type_capability (
				id_param int NOT 
					 NULL identity(1,1),				
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_path_capability (
				id_param int NOT 
				 NULL identity(1,1),				
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_account_extension_capability (
				id_param int NOT 
				NULL identity(1,1),				
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_condition_capability (
				id_param int NOT 
				 NULL identity(1,1),				
				id_cap_instance int NOT NULL,
				tx_param_name varchar(255),
				tx_param_operator varchar(255),
				n_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)



