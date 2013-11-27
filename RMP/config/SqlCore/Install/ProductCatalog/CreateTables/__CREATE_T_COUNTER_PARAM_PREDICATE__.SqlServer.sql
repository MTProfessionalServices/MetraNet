
        	CREATE TABLE t_counter_param_predicate
          (
             id_prop int identity (1,1) not null,
             id_counter_param INT,
             id_pv_prop INT,
             nm_op NVARCHAR(2),
             nm_value NVARCHAR(255),
             constraint t_counter_param_predicate_PK primary key (id_prop)
           )		
       