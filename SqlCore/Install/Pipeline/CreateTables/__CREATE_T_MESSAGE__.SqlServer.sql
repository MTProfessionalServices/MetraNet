
create table t_message
(
  -- unique ID representing this unit of work
  id_message int constraint pk_t_message PRIMARY KEY,

  -- optional routing ID.  Allows pipeline to only request a subset of the work.
  id_route int,

  -- date/time message was received by listener
  dt_crt datetime not null,

  -- date/time message was metered by client
  dt_metered datetime not null,

  -- date this message was pulled off (initially null)
  dt_assigned datetime,

  -- listener who submitted this work.
  id_listener int,

  -- pipeline who received this work.  Initially null if no
  -- one owns the work.  A pipeline grabs work by setting this
  -- value to it's pipeline ID and locking the row
  id_pipeline int,

  -- date this work was completed.
  dt_completed datetime,

	-- meter ID of the listener to route feedback back to if message was sent synchronously
  id_feedback int,
  
  -- other message level properties created by the listener
  -- To join a message into a DTC transaction
  tx_TransactionID varchar(256),
  
  -- Used to authenticate a user for secured operations. The field lengths are based on the t_account_mapper table
  tx_sc_username varchar(510),
  
  tx_sc_password varchar(128),
  
  tx_sc_namespace varchar(80),
  
  -- serialized session context
  tx_sc_serialized TEXT,

  -- IP address of the sender of this message
  tx_ip_address VARCHAR(15) NOT NULL,
  
  id_partition INT NOT NULL DEFAULT 1
)
			