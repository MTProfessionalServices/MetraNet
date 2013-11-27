
CREATE GLOBAL TEMPORARY TABLE tmp_discount_4
( 
  id_interval     NUMBER(10) NOT NULL,             /* discount interval */
  id_group        NUMBER(36, 0) NOT NULL, 
  id_acc          NUMBER(36, 0) NOT NULL, 
  id_pi_instance  NUMBER(10) NOT NULL, 
  amount          NUMBER(22,10) NOT NULL 
) ON COMMIT PRESERVE ROWS
