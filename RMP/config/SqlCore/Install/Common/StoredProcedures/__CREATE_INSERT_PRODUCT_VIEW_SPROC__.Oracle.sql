
      create or replace procedure InsertProductView
      (p_a_id_view int,
      p_a_nm_name nvarchar2,
      p_a_dt_modified date,
      p_a_nm_table_name nvarchar2,
      a_b_can_resubmit_from char,
      p_a_id_prod_view out int)
      as
      begin
      insert into t_prod_view
      (
      id_prod_view,
      id_view,
      dt_modified,
      nm_name,
      nm_table_name,
      b_can_resubmit_from
      )
      values
      (
      seq_t_prod_view.nextval,
      p_a_id_view,
      p_a_dt_modified,
      p_a_nm_name,
      p_a_nm_table_name,
      a_b_can_resubmit_from
      );
      select seq_t_prod_view.currval into p_a_id_prod_view from dual;
      end;
  