
        	CREATE TABLE t_counter_param_predicate
          (
             id_prop number(10) not null constraint t_counter_param_predicate_PK primary key,
             id_counter_param number(10),
             id_pv_prop number(10),
             nm_op NVARCHAR2(2),
             nm_value NVARCHAR2(255)
          )
       