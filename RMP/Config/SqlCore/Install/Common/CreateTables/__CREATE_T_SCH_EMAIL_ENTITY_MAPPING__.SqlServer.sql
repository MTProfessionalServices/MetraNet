CREATE TABLE t_sch_email_entity_mapping
(
  id_sch_email_entity_mapping INT NOT NULL,
  column_name NVARCHAR(50) NOT NULL,
  tx_desc NVARCHAR(200)
  CONSTRAINT PK_t_sch_email_entity_mapping PRIMARY KEY CLUSTERED (id_sch_email_entity_mapping ASC)
)
        