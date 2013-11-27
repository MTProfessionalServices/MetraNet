
if object_id( '%%TEMPDEBUG%%tmp_account_state_rules' ) is not null
BEGIN
  DROP TABLE %%DEBUG%%tmp_account_state_rules;
END;
BEGIN
CREATE TABLE %%DEBUG%%tmp_account_state_rules(state char(2), can_subscribe int);
CREATE CLUSTERED INDEX idx_state ON  %%DEBUG%%tmp_account_state_rules(state)
END;
		