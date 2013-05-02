
      create table t_prod_view (
        id_prod_view number(10) not null primary key,
        id_view number(10) not null,
        dt_modified date,
        nm_name nvarchar2(255),
        nm_table_name varchar2(255),
		  b_can_resubmit_from char(1) not null,
        constraint t_prod_view_view_IDX unique (id_view)
      )
   