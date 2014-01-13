
                CREATE TABLE t_wf_instancestate (
	              id_instance NVARCHAR2(36) NOT NULL ,
	              state BLOB NULL ,
	              n_status number(10) NULL ,
	              n_unlocked number(10) NULL ,
	              n_blocked number(10) NULL ,
	              tx_info NCLOB NULL,
	              dt_modified DATE NOT NULL,
	              id_owner nvarchar2(36) NULL ,
	              dt_ownedUntil date NULL,
	              dt_nextTimer date NULL
                );              
                CREATE  UNIQUE INDEX idx_instancestate_id_instance ON t_wf_InstanceState(id_instance);

