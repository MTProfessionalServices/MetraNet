
create or replace procedure ReRunCreate(p_tx_filter nvarchar2,
      p_id_acc int,
      p_tx_comment nvarchar2,
      p_dt_system_date timestamp,
      p_id_rerun OUT int)
as
begin

  insert into t_rerun (id_rerun,tx_filter, tx_tag) values(seq_t_rerun_history.nextval,p_tx_filter, null);

  insert into t_rerun_history (id_rerun, dt_action, tx_action,
    id_acc, tx_comment)
  values (seq_t_rerun_history.currval, p_dt_system_date, 'CREATE', p_id_acc,
    p_tx_comment);

  select   seq_t_rerun_history.currval into p_id_rerun from dual;
end;
            