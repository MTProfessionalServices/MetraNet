
ALTER TABLE t_acc_template_session_detail add constraint fk1_template_session_detail FOREIGN KEY (id_session) REFERENCES t_acc_template_session (id_session)
