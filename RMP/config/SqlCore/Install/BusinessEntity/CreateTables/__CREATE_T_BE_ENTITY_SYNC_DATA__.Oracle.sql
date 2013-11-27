
create table t_be_entity_sync_data
(
      id RAW(16) NOT NULL,
      tx_entity_name nvarchar2(255) not null,
      tx_hbm_checksum nvarchar2(255) not null,
      dt_sync_date date not null,
      primary key (id)
)
	    