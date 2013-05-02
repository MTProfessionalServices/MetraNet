
CREATE TABLE t_recevent_run_failure_acc
(
  id_run INT NOT NULL,    -- the run which created the failed account
  id_acc INT NOT NULL,    -- the account which failed
 
  CONSTRAINT FK1_t_recevent_run_failure_acc FOREIGN KEY (id_run) REFERENCES t_recevent_run (id_run),
  CONSTRAINT FK2_t_recevent_run_failure_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
 )
create clustered index idx_recevent_run_failure_acc on t_recevent_run_failure_acc(id_run)
	 