CREATE TABLE t_sch_email_entity_mapping
(
  id_sch_email_entity_mapping NUMBER(10) NOT NULL,
  column_name NVARCHAR2(50) NOT NULL,
  tx_desc NVARCHAR2(200) NULL,
  CONSTRAINT PK_t_sch_email_entity_mapping PRIMARY KEY (id_sch_email_entity_mapping)
)