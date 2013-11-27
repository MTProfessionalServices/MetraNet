
IF OBJECT_ID('%%NETMETERSTAGE%%..t_resubmit_transaction_stage') IS NULL 
    CREATE TABLE %%NETMETERSTAGE%%..t_resubmit_transaction_stage (id_sess BINARY(16) NOT NULL, id_svc INT NOT NULL);
			