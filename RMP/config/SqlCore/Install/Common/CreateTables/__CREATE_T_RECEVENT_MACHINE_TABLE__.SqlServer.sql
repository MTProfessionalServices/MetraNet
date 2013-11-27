
CREATE TABLE t_recevent_machine
(
  /* Table stores recurring event machine rules that indicate which machines can run particular adapters */
	id_event int NOT NULL, /* Foreign key to t_recevent */
	tx_canrunonmachine nvarchar(128) NOT NULL, /* Machine identifier that can run this adapter */
  CONSTRAINT FK_t_recevent_machine FOREIGN KEY (id_event) REFERENCES t_recevent (id_event)
) 
			 