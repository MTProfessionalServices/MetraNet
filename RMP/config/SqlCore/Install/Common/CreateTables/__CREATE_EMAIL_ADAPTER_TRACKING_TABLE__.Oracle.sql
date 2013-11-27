
   CREATE TABLE t_email_adapter_tracking
(
  id_acc INT not null,
  email_sent char(1) NOT NULL,
  n_failed_attempts int default 0 not null,
  id_instance INT not null,
  CONSTRAINT PK_t_email_adapter_tracking PRIMARY KEY (id_instance, id_acc),
  CONSTRAINT FK1_t_email_adapter_tracking FOREIGN KEY (id_instance) REFERENCES t_recevent_inst(id_instance),
  CONSTRAINT CK1_t_email_adapter_tracking CHECK (email_sent in ('Y', 'N'))
)

