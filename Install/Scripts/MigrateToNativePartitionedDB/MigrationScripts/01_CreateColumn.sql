IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = 't_prod_view' AND column_name = 'b_migrated')	
		ALTER TABLE t_prod_view 
		ADD b_migrated BIT NOT NULL DEFAULT 0