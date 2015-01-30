
CREATE TABLE t_billgroup_tmp
(
  id_materialization INT NOT NULL,          -- the materialization which created this billing group.
  tx_name NVARCHAR(255) NOT NULL,      -- name of this billing group. Must be unique
  tx_description NVARCHAR(2048) NULL,    -- description for this billing group
  id_billgroup INT IDENTITY(1000,1) NOT NULL,  -- identity 
  id_partition INT Null
  
  CONSTRAINT FK1_t_billgroup_tmp FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
 )
create clustered index idx_billgroup_tmp on t_billgroup_tmp(id_materialization)
	 