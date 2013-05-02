
CREATE or replace PROCEDURE UpsertListener( p_tx_machine NVARCHAR2, p_id_listener OUT INT)
AS
BEGIN
  UPDATE t_listener 
	SET b_online = '1'
	WHERE tx_machine = p_tx_machine;

  IF (SQL%ROWCOUNT = 0) then
	  INSERT INTO t_listener (id_listener,tx_machine, b_online) VALUES (seq_t_listener.nextval,p_tx_machine, '1');
  END IF;

  for i in (SELECT id_listener 
  FROM t_listener
  WHERE tx_machine = p_tx_machine)
  loop
    p_id_listener := i.id_listener ;
  end loop;
END;


			