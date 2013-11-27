
        CREATE TABLE t_recevent_inst
        (
            id_instance number(10) NOT NULL,
            id_event number(10) NOT NULL,
            id_arg_interval number(10) NULL,   /* usage interval that an end-of-period adapter is to operate on */
						id_arg_billgroup number(10) NULL,
						id_arg_root_billgroup number(10) NULL,
            dt_arg_start DATE NULL, /* start date that a scheduled adapter is to operate on */
            dt_arg_end DATE NULL,   /* end date that a scheduled adapter is to operate on */
            b_ignore_deps VARCHAR2(1) NOT NULL, /* whether to ignore dependencies for this instance */
            dt_effective DATE NULL, /* this instance can only run after this date, not before */
            tx_status VARCHAR2(14) NOT NULL, /* the status of the instance based on the latest run */
            CONSTRAINT PK_t_recevent_inst PRIMARY KEY (id_instance),
            CONSTRAINT FK1_t_recevent_inst FOREIGN KEY (id_event) REFERENCES t_recevent (id_event),
            /*  CONSTRAINT FK2_t_recevent_inst FOREIGN KEY (id_arg_interval) REFERENCES t_pc_interval (id_interval), */
            CONSTRAINT CK1_t_recevent_inst CHECK ((dt_arg_start IS NULL AND dt_arg_end IS NULL) OR
                                    (dt_arg_start IS NOT NULL AND dt_arg_end IS NOT NULL)),
            CONSTRAINT CK2_t_recevent_inst CHECK (b_ignore_deps IN ('N' , 'Y')),
            CONSTRAINT CK3_t_recevent_inst CHECK (tx_status IN ('NotYetRun', 'ReadyToRun', 'ReadyToReverse',
                                                  'Running', 'Reversing', 'Succeeded', 'Failed'))
        )
        