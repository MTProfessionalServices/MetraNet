
begin
    if not table_exists('%%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage') then
        execute immediate 'CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%t_failed_session_state_stage (tx_FailureID RAW(16) NOT NULL, dt_FailureTime date NOT NULL)';
    end if;
end;
			