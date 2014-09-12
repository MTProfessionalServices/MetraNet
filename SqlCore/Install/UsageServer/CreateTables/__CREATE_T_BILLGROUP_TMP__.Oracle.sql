
CREATE TABLE t_billgroup_tmp
(
  id_materialization number(10) NOT NULL,
  tx_name NVARCHAR2(50) NOT NULL,
  tx_description NVARCHAR2(255) NULL,
  id_billgroup number(10) NOT NULL,  
  id_partition number(10) NULL,
  CONSTRAINT FK1_t_billgroup_tmp 
    FOREIGN KEY (id_materialization) 
    REFERENCES t_billgroup_materialization (id_materialization)
 )
	 