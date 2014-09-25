
if object_id('%%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage') is null 
    CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage (tx_FailureID BINARY(16) NOT NULL, dt_FailureTime datetime NOT NULL);
			