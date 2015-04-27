-- upgrade script for esr-5770
IF  NOT EXISTS (SELECT * FROM sys.objects 
 WHERE object_id = OBJECT_ID(N'[dbo].[t_sch_email_entity_mapping]') AND type in (N'U')) 
BEGIN
CREATE TABLE t_sch_email_entity_mapping
(
  id_sch_email_entity_mapping INT NOT NULL,
  column_name NVARCHAR(50) NOT NULL,
  tx_desc NVARCHAR(200)
  CONSTRAINT PK_t_sch_email_entity_mapping PRIMARY KEY CLUSTERED (id_sch_email_entity_mapping ASC)
)
END
GO

IF  NOT EXISTS (SELECT * from t_sch_email_entity_mapping)
  INSERT INTO t_sch_email_entity_mapping (id_sch_email_entity_mapping, column_name, tx_desc) VALUES (1, 'c_CreditNote_Id', 'Refers to t_be_cor_cre_creditnote.c_CreditNote_Id')
GO

IF  NOT EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[t_sch_email_adapter_status]') AND type in (N'U')) 
BEGIN
CREATE TABLE t_sch_email_adapter_status
(
  id_sch_email_adapter_status INT IDENTITY(1,1) NOT NULL,
  id_entity_guid UNIQUEIDENTIFIER NULL,
  id_entity_int INT NULL,
  id_sch_email_entity_mapping INT NOT NULL,
  id_event INT NOT NULL,
  email_status NVARCHAR(20) NOT NULL,
  id_last_run INT NOT NULL,
  retry_counter INT NOT NULL,
  tx_detail NVARCHAR(2000) NULL
  CONSTRAINT PK_t_sch_email_adapter_status PRIMARY KEY CLUSTERED (id_sch_email_adapter_status ASC),
  CONSTRAINT FK1_t_sch_email_adapter_status FOREIGN KEY (id_sch_email_entity_mapping) REFERENCES t_sch_email_entity_mapping (id_sch_email_entity_mapping),
  CONSTRAINT FK2_t_sch_email_adapter_status FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
  CONSTRAINT FK3_t_sch_email_adapter_status FOREIGN KEY (id_last_run) REFERENCES t_recevent_run (id_run)
)
END
GO