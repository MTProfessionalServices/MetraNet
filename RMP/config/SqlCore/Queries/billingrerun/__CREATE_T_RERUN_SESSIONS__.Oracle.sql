
      begin
        execute immediate 'Create Table %%TABLE_NAME%%
		    (id number(10) NOT NULL,
			  id_source_sess raw(16) NOT NULL ,
			  tx_batch raw(16) NULL,
			  id_sess number(20),
			  id_parent_sess number(20),
			  root number(20),
			  id_interval number(10),
			  id_view number(10),
			  tx_state varchar2(2) NOT NULL ,
			  id_svc number(10) NOT NULL,
			  id_parent_source_sess raw (16),
			  id_payer number(10) NULL,
			  amount number(22,10) NULL,
			  currency nvarchar2(6) NULL,
			  CONSTRAINT PK_%%TABLE_NAME%% PRIMARY KEY  (id_source_sess)
		    )';
  	
	      execute immediate '	CREATE SEQUENCE seq_%%TABLE_NAME%%
         MINVALUE 1
         START WITH 1
         INCREMENT BY 1
         NOCACHE ORDER NOCYCLE';
     end;
		
		 