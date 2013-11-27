create sequence seq_t_billingserver_service start with 1 increment by 1 nocache order nocycle;
CREATE TABLE t_billingserver_service
(
    id_billingserver number(10) NOT NULL,
    id_svc number(10) NOT NULL,
    tt_start date NOT NULL,
    tt_end date,
    tt_lastheartbeat date,
    tt_nextheartbeatpromised date,
  CONSTRAINT PK_t_billingserver_service PRIMARY KEY 
(
    id_billingserver,
    id_svc,
    tt_start
)
);
 
