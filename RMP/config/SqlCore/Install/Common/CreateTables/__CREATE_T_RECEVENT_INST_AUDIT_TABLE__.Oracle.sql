
        CREATE TABLE t_recevent_inst_audit
        (
            id_audit number(10) NOT NULL,
            id_instance number(10) NOT NULL,
            id_acc number(10) NOT NULL,            /* the user who requested the action */
            tx_action nvarchar2(18) NOT NULL, /* the action */
            b_ignore_deps VARCHAR2(1) NULL,  /* whether the instance submited should ignore dependencies */
            dt_effective DATE NULL,    /*  */
            tx_detail nVARCHAR2(2000) NULL,   /* any details/comments specified by the actor */
            dt_crt DATE NOT NULL,
            CONSTRAINT PK1_t_recevent_inst_audit PRIMARY KEY (id_audit),
            CONSTRAINT FK1_t_recevent_inst_audit FOREIGN KEY (id_instance) REFERENCES t_recevent_inst (id_instance),
            CONSTRAINT CK1_t_recevent_inst_audit CHECK (tx_action IN ('SubmitForExecution', 'SubmitForReversal',
                                                        'Acknowledge', 'Unacknowledge',
                                                        'Cancel', 'MarkAsSucceeded', 'MarkAsFailed',
                                                        'MarkAsNotYetRun'))
        )
        