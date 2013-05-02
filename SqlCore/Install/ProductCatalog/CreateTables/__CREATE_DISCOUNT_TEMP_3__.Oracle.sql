
CREATE GLOBAL TEMPORARY TABLE tmp_discount_3
( 
  id_interval     NUMBER(10) NOT NULL,             /* discount interval */
  id_group        NUMBER(10) NOT NULL, 
  id_acc          NUMBER(10) NOT NULL, 
  id_pi_instance  NUMBER(10) NOT NULL, 
  proportion      NUMBER(38, 20) NOT NULL
) ON COMMIT PRESERVE ROWS
