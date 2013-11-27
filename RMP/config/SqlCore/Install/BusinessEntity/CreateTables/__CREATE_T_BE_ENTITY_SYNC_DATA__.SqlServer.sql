
	  create table [t_be_entity_sync_data] 
    (
      id [uniqueidentifier] NOT NULL,
		  [tx_entity_name] [nvarchar](255) not null,
      [tx_hbm_checksum] [nvarchar](255) not null,
      [dt_sync_date] [datetime] not null,
      primary key (id)
    )
	