
create sequence seq_t_listener start with 1 increment by 1 nocache order nocycle;
create table t_listener
(
  /* unique listener ID*/
  id_listener number(10) not null PRIMARY KEY ,
  /* machine name*/
  tx_machine varchar2(256),
  /* flag indicating if this listener is online or not*/
  b_online char(1) not null
);
ALTER TABLE t_listener ADD CONSTRAINT uk_t_listener_tx_machine UNIQUE (tx_machine);

