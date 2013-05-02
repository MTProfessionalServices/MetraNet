
CREATE TABLE t_recevent_concurrent
(
  /* Table stores recurring event concurrency rules that indicate which adapters can run at the
  same time as other adapters */
	tx_eventname nvarchar2(255) NOT NULL,
	tx_compatible_eventname nvarchar2(255) NULL
  /*CONSTRAINT FK_t_recevent_concurrent FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
  CONSTRAINT FK_t_recevent_concurrent2 FOREIGN KEY (id_compatible_concurrent_event) REFERENCES t_recevent (id_event)*/
) 
			 