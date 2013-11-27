
			       CREATE TABLE t_payment_instrument_xref (
	            temp_acc_id number(10) NOT NULL,
	            nm_login nvarchar2(255) NOT NULL,
	            nm_space nvarchar2(40) NOT NULL,
	            dt_created timestamp NOT NULL,
              PRIMARY KEY (temp_acc_id, nm_login, nm_space))        
				