
CREATE TABLE t_recevent_inst_audit
(
  id_audit INT IDENTITY(1000,1) NOT NULL,
  id_instance INT NOT NULL,
  id_acc INT NOT NULL,            -- the user who requested the action
  tx_action nvarchar(18) NOT NULL, -- the action
  b_ignore_deps VARCHAR(1) NULL,  -- whether the instance submited should ignore dependencies
  dt_effective DATETIME NULL,    --
  tx_detail nvarchar(2048) NULL,   -- any details/comments specified by the actor
  dt_crt DATETIME NOT NULL,
  CONSTRAINT PK1_t_recevent_inst_audit PRIMARY KEY (id_audit),
  CONSTRAINT FK1_t_recevent_inst_audit FOREIGN KEY (id_instance) REFERENCES t_recevent_inst (id_instance),
  CONSTRAINT CK1_t_recevent_inst_audit CHECK (tx_action IN ('SubmitForExecution', 'SubmitForReversal',
                                                            'Acknowledge', 'Unacknowledge',
                                                            'Cancel', 'MarkAsSucceeded', 'MarkAsFailed',
                                                            'MarkAsNotYetRun'))
)
			 