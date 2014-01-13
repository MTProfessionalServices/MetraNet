
        CREATE TABLE t_recevent
        (
          id_event number(10) NOT NULL,			   /* unique ID of this event */
          tx_name nvarchar2(255) NOT NULL,         /* unique name of the event instance (used in dependency references) */
          tx_type VARCHAR2(11) NOT NULL,           /* event type: Root, Scheduled, EndOfPeriod, Checkpoint */
          tx_reverse_mode VARCHAR2(14) NOT NULL,   /* reverse mode: NotImplemented, NotNeeded, Auto, Custom */
          b_multiinstance VARCHAR2(1) NOT NULL,    /* whether the adapter can run concurrently with other instances of itself */
          tx_billgroup_support VARCHAR2(15) NOT NULL,
				  b_has_billgroup_constraints VARCHAR2(1) NULL,
          tx_class_name VARCHAR2(255) NULL,        /* Adapter class name or Prog ID. (null for checkpoints) */
          tx_extension_name VARCHAR2(255) NULL,    /* name of extension holding adapter */
          tx_config_file VARCHAR2(255) NULL,       /* Configuration file used by the adapter. */
          dt_activated DATE NOT NULL,              /* date of activation */
          dt_deactivated DATE NULL,                /* if null, event is considered active.  Otherwise date of deactivation */
          tx_display_name nvarchar2(255) NOT NULL, /* Display name of the adapter instance (GUI) */
          tx_desc nvarchar2(2000) NULL,            /* description of the adapter (GUI) */
          CONSTRAINT PK_t_recevent PRIMARY KEY (id_event),
          CONSTRAINT CK1_t_recevent CHECK (tx_type IN ('Root', 'Scheduled', 'EndOfPeriod', 'Checkpoint')),
          CONSTRAINT CK2_t_recevent CHECK (tx_reverse_mode IN ('NotImplemented', 'NotNeeded', 'Auto', 'Custom')),
          CONSTRAINT CK3_t_recevent CHECK (tx_billgroup_support IN ('Interval', 'BillingGroup', 'Account'))
        )
			 