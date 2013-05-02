CREATE OR REPLACE PROCEDURE AdapterConcurrencyInitialize 
(
 p_status OUT number
)
IS  
  BEGIN 
  delete from t_recevent_concurrent;
  p_status := 0;
  END;