
       create sequence seq_t_pipeline start with 1 increment by 1 nocache order nocycle;
        create table t_pipeline
        (
          /* unique pipeline ID*/
          id_pipeline number(10) not null PRIMARY KEY,
          /* machine name */
          tx_machine nvarchar2(128) not null,
          /* flag indicating if this pipeline is online or not */
          b_online char(1) not null,
          /* flag indicating if this pipeline is currently enabled for routing */
          b_paused char(1) not null,
          /* flag indicating if this pipeline is currently processing (detected by sessions in shared memory) */
          b_processing char(1) not null
        );
        alter table t_pipeline add constraint UK_tx_machine UNIQUE (tx_machine);

