
CREATE TABLE t_recevent_scheduled
(
	id_event integer  NOT NULL ,
	interval_type varchar(20) NOT NULL ,
	start_date datetime  NULL ,
	interval integer  NULL ,
	execution_times varchar(2000)  NULL ,
	days_of_week varchar(2000)  NULL ,
	days_of_month varchar(2000)  NULL ,
	is_paused char(1) NOT NULL DEFAULT 'N',
	override_date datetime  NULL ,
	update_date datetime  NOT NULL ,
	CONSTRAINT PK_t_recevent_scheduled PRIMARY KEY  CLUSTERED (id_event ASC),
	CONSTRAINT FK1_t_recevent_scheduled FOREIGN KEY (id_event) REFERENCES t_recevent(id_event),
	CONSTRAINT [CK1_t_recevent_scheduled] CHECK (interval_type in ('Monthly', 'Weekly', 'Daily', 'Minutely', 'Manual')),
	CONSTRAINT [CK2_t_recevent_scheduled] CHECK (is_paused in ('Y', 'N'))
)
			 