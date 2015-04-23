CREATE TABLE t_sch_email_adapter_status
(
  id_sch_email_adapter_status NUMBER(10) NOT NULL,
  id_entity_guid RAW(16) NULL,
  id_entity_int NUMBER(10) NULL,
  id_sch_email_entity_mapping NUMBER(10) NOT NULL,
  id_event NUMBER(10) NOT NULL,
  email_status NVARCHAR2(20) NOT NULL,
  id_last_run NUMBER(10) NOT NULL,
  retry_counter NUMBER(10) NOT NULL,
  tx_detail NVARCHAR2(2000) NULL,
  CONSTRAINT PK_t_sch_email_adapter_status PRIMARY KEY (id_sch_email_adapter_status),
  CONSTRAINT FK1_t_sch_email_adapter_status FOREIGN KEY (id_sch_email_entity_mapping) REFERENCES t_sch_email_entity_mapping (id_sch_email_entity_mapping),
  CONSTRAINT FK2_t_sch_email_adapter_status FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
  CONSTRAINT FK3_t_sch_email_adapter_status FOREIGN KEY (id_last_run) REFERENCES t_recevent_run (id_run)
);

CREATE SEQUENCE seq_t_sch_email_adapter_status;
        