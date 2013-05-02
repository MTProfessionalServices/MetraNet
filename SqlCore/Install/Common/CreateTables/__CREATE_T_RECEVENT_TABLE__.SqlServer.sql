
CREATE TABLE t_recevent
(
  id_event INT NOT NULL,			-- unique ID of this event
  tx_name nvarchar(255) NOT NULL, -- unique name of the event instance (used in dependency references)
  tx_type VARCHAR(11) NOT NULL,  -- event type: Root, Scheduled, EndOfPeriod, Checkpoint
  tx_reverse_mode VARCHAR(14) NOT NULL, -- reverse mode: NotImplemented, NotNeeded, Auto, Custom
  b_multiinstance VARCHAR(1) NOT NULL, -- whether the adapter can run concurrently with other instances of itself
  tx_billgroup_support VARCHAR(15) NOT NULL, -- determines if this is an interval-only adapter or a billing group-only adapter or an account-only adapter
  b_has_billgroup_constraints VARCHAR(1) NULL, -- determines if this is adapter has any billing group constraints
  tx_class_name VARCHAR(255) NULL, -- Adapter class name or Prog ID. (null for checkpoints)
  tx_extension_name VARCHAR(255) NULL, -- name of extension holding adapter
  tx_config_file VARCHAR(255) NULL, -- Configuration file used by the adapter.
  dt_activated DATETIME NOT NULL,  -- date of activation
  dt_deactivated DATETIME NULL,  -- if null, event is considered active.  Otherwise date of deactivation
  tx_display_name nvarchar(255) NOT NULL, -- Display name of the adapter instance (GUI)
  tx_desc nvarchar(2048) NULL, -- description of the adapter (GUI)
  CONSTRAINT PK_t_recevent PRIMARY KEY (id_event),
  CONSTRAINT CK1_t_recevent CHECK (tx_type IN ('Root', 'Scheduled', 'EndOfPeriod', 'Checkpoint')),
  CONSTRAINT CK2_t_recevent CHECK (tx_reverse_mode IN ('NotImplemented', 'NotNeeded', 'Auto', 'Custom')),
  CONSTRAINT CK3_t_recevent CHECK (tx_billgroup_support IN ('Interval', 'BillingGroup', 'Account'))
)
			 