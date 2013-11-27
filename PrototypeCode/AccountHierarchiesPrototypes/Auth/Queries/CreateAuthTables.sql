
IF EXISTS (SELECT * FROM sysobjects where name = 't_policy_role') DROP TABLE t_policy_role

IF EXISTS (SELECT * FROM sysobjects where name = 't_path_capability') DROP TABLE t_path_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_account_extension_capability') DROP TABLE t_account_extension_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_condition_capability') DROP TABLE t_condition_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_access_type_capability') DROP TABLE t_access_type_capability
IF EXISTS (SELECT * FROM sysobjects where name = 't_capability_instance') DROP TABLE t_capability_instance
IF EXISTS (SELECT * FROM sysobjects where name = 't_compositor') DROP TABLE t_compositor
IF EXISTS (SELECT * FROM sysobjects where name = 't_atomic_capability_type') DROP TABLE t_atomic_capability_type
IF EXISTS (SELECT * FROM sysobjects where name = 't_composite_capability_type') DROP TABLE t_composite_capability_type

IF EXISTS (SELECT * FROM sysobjects where name = 't_principal_policy') DROP TABLE t_principal_policy
IF EXISTS (SELECT * FROM sysobjects where name = 't_role') DROP TABLE t_role

-- IF EXISTS (SELECT * FROM sysobjects where name = 't_dsp') DROP TABLE t_dsp
-- IF EXISTS (SELECT * FROM sysobjects where name = 't_dsp_role') DROP TABLE t_dsp_role
-- IF EXISTS (SELECT * FROM sysobjects where name = 't_account_role') DROP TABLE t_account_role


-- IF EXISTS (SELECT * FROM sysobjects where name = 't_composite_capability_type') DROP TABLE t_composite_capability_type




/*
Probably need to add support for localizable name and description
*/

CREATE TABLE t_role (	id_role int NOT NULL identity(1, 1), 
			tx_name VARCHAR(255), 
			tx_desc VARCHAR(255),  
			csr_assignable VARCHAR(1) NULL,
			subscriber_assignable VARCHAR(1) NULL
			CONSTRAINT PK_t_role PRIMARY KEY CLUSTERED (
				 id_role))

CREATE TABLE t_principal_policy (id_policy int NOT NULL identity(1, 1), 
			id_acc int NULL,
			id_role int NULL,
			policy_type VARCHAR(1),
			tx_name VARCHAR(255), 
			tx_desc VARCHAR(255)  
			CONSTRAINT PK_t_principal_policy PRIMARY KEY CLUSTERED (
				 id_policy),
			FOREIGN KEY (id_acc) REFERENCES 
				 t_account,
			FOREIGN KEY (id_role) REFERENCES 
				 t_role,
			CHECK(id_acc IS NULL OR id_role IS NULL)

			)


CREATE TABLE t_policy_role (	id_policy int NOT NULL, 
				id_role int NOT NULL CONSTRAINT PK_t_policy_role PRIMARY KEY CLUSTERED (
				id_policy, id_role), FOREIGN KEY (id_policy) REFERENCES 
				 t_principal_policy, FOREIGN KEY (id_role) REFERENCES 
				 t_role)




CREATE TABLE t_atomic_capability_type (id_cap_type int NOT 
				 NULL identity(1,1) CONSTRAINT PK_t_atomic_capability_type PRIMARY KEY CLUSTERED, 
				tx_name VARCHAR(2000) NOT NULL,
				tx_desc VARCHAR(2000) NOT NULL,
				tx_progid VARCHAR(255) NOT NULL,

				/*
				if editor is null then default editor is invoked
				*/
				tx_editor VARCHAR(255) NULL)

CREATE TABLE t_composite_capability_type (id_cap_type int NOT 
				 NULL identity(1,1) CONSTRAINT PK_t_composite_capability_type PRIMARY KEY CLUSTERED, 
				tx_name VARCHAR(2000) NOT NULL,
				tx_desc VARCHAR(2000) NOT NULL,
				tx_progid VARCHAR(255) NOT NULL,

				/*
				if editor is null then default editor is invoked
				*/
				tx_editor VARCHAR(255) NULL,
				csr_assignable VARCHAR(1) NULL,
				subscriber_assignable VARCHAR(1) NULL,
				multiple_instances VARCHAR(1) NOT NULL)

CREATE TABLE t_compositor 	(
				id_atomic int NOT NULL,
				id_composite int NOT NULL,
				tx_description VARCHAR(255) NOT NULL,

				CONSTRAINT PK_t_compositor PRIMARY KEY CLUSTERED(id_atomic, id_composite), 
				FOREIGN KEY (id_atomic) REFERENCES t_atomic_capability_type, 
				FOREIGN KEY (id_composite) REFERENCES t_composite_capability_type)



CREATE TABLE t_capability_instance (id_cap_instance int NOT 
				 NULL identity(1,1), 
				id_parent_cap_instance int NULL,
				id_policy int NOT NULL,
				id_cap_type int NOT NULL
				 CONSTRAINT PK_t_capability_instance PRIMARY KEY CLUSTERED(id_cap_instance), 
				-- FOREIGN KEY (id_cap_type) REFERENCES t_capability_type,
				FOREIGN KEY (id_policy) REFERENCES t_principal_policy
				)

CREATE TABLE t_access_type_capability (
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_path_capability (
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_account_extension_capability (
				id_cap_instance int NOT NULL,
				tx_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)

CREATE TABLE t_condition_capability (
				id_cap_instance int NOT NULL,
				tx_param_name varchar(255),
				tx_param_operator varchar(255),
				n_param_value varchar(255),
				FOREIGN KEY (id_cap_instance) REFERENCES t_capability_instance)




insert into t_account_mapper values('jcsr', 'mt', 127)
insert into t_account_mapper values('scsr', 'mt', 128)
insert into t_account_mapper values('su', 'mt', 126)
