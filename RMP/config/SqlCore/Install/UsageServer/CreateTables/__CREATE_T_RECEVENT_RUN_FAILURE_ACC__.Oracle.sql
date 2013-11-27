
CREATE TABLE t_recevent_run_failure_acc
(
  id_run number(10) NOT NULL,
  id_acc number(10) NOT NULL, 
  CONSTRAINT FK1_t_recevent_run_failure_acc FOREIGN KEY (id_run) REFERENCES t_recevent_run (id_run),
  CONSTRAINT FK2_t_recevent_run_failure_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
 )
	 