
create table t_message
(
  /* unique ID representing this unit of work*/
  id_message number(10),

  /* optional routing ID.  Allows pipeline to only request a subset of the work.*/
  id_route number(10),
  /* date/time message was received by listener */
  dt_crt timestamp not null,

  /* date/time message was metered by client*/
  dt_metered timestamp not null,

  /* date this message was pulled off (initially null)*/
  dt_assigned timestamp,

  /*listener who submitted this work.*/
  id_listener number(10),

  /* pipeline who received this work.  Initially null if no
     one owns the work.  A pipeline grabs work by setting this
     value to it's pipeline ID and locking the row*/
  id_pipeline number(10),

  /* date this work was completed.*/
  dt_completed timestamp,

  /* meter ID of the listener to route feedback back to if message was sent synchronously*/
  id_feedback number(10),
  
  /* other message level properties created by the listener
     To join a message into a DTC transaction */
  tx_TransactionID varchar2(256),
  
  /* Used to authenticate a user for secured operations. The field lengths are based on the t_account_mapper table*/
  tx_sc_username varchar2(510),
  
  tx_sc_password varchar2(128),
  
  tx_sc_namespace varchar2(80),
  
  /* serialized session context */
  tx_sc_serialized clob,
  
  /* IP address of the sender of this message*/
  tx_ip_address VARCHAR2(15) NOT NULL,
  
  /* Uses for archive_queue functionality */
  id_partition number(10) DEFAULT 1 NOT NULL
)
			