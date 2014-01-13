
        create table t_rerun_history
        (
          id_rerun number(10) ,
          dt_action timestamp not null,
          tx_action varchar2(50) not null,
          id_acc number(10),
          tx_comment nvarchar2(255),
          constraint fk1_t_rerun_history foreign key(id_rerun) REFERENCES t_rerun(id_rerun)
        )
        