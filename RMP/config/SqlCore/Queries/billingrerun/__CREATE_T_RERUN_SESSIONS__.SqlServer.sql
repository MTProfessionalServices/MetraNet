
		  Create Table %%TABLE_NAME%%
		  (	id int identity(1,1),
			id_source_sess binary (16) NOT NULL ,
			tx_batch varbinary (16),
			id_sess bigint,
			id_parent_sess bigint,
			root int,
			id_interval int,
			id_view int,
			tx_state varchar(2) NOT NULL ,
			id_svc int NOT NULL,
			id_parent_source_sess binary(16),
			id_payer int NULL,
			amount numeric(22,10) NULL,
			currency nvarchar(6) NULL,
			CONSTRAINT PK_%%TABLE_NAME%% PRIMARY KEY CLUSTERED (id_source_sess)
		  )
		  