
				create table t_account_state (
				id_acc NUMBER(10) not null,
				status char(2) not null,
				vt_start date not null,
				vt_end date not null,
        CONSTRAINT t_account_state_check CHECK (status = 'PA' OR status = 'AC' 
				OR status = 'SU' or status = 'PF' or status = 'CL' or status = 'AR'),
				CONSTRAINT date_state_check1 check ( vt_start <= vt_end)
				)
				