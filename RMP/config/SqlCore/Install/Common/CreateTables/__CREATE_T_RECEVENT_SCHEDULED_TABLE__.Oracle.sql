
CREATE TABLE t_recevent_scheduled
(
    id_event number(10)  NOT NULL ,
    interval_type varchar2(20) NOT NULL ,
    start_date DATE  NULL ,
    interval number(10)  NULL ,
    execution_times varchar2(2000)  NULL ,
    days_of_week varchar2(2000)  NULL ,
    days_of_month varchar2(2000)  NULL ,
    is_paused char(1) DEFAULT ('N') NOT NULL,
    override_date DATE  NULL ,
    update_date DATE  NOT NULL ,
    CONSTRAINT PK_t_recevent_scheduled PRIMARY KEY (id_event),
    CONSTRAINT FK1_t_recevent_scheduled FOREIGN KEY (id_event) REFERENCES t_recevent(id_event),
    CONSTRAINT CK1_t_recevent_scheduled CHECK (interval_type in ('Monthly', 'Weekly', 'Daily', 'Minutely', 'Manual')),
    CONSTRAINT CK2_t_recevent_scheduled CHECK (is_paused in ('Y', 'N'))
)
        