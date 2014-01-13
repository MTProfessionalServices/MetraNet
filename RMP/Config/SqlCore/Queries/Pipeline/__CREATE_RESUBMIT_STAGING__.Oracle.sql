
begin
  if not table_exists('%%NETMETERSTAGE%%.t_resubmit_transaction_stage') then
      execute immediate 'create table %%NETMETERSTAGE%%.t_resubmit_transaction_stage (id_sess raw(16) NOT NULL, id_svc number(10) NOT NULL)';
  end if;
end;
			