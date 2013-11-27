
CREATE PROCEDURE UpsertListener @tx_machine NVARCHAR(128), @id_listener INT OUTPUT
AS
BEGIN
  UPDATE t_listener 
	SET b_online = '1'
	WHERE tx_machine = @tx_machine

  IF (@@ROWCOUNT = 0)
	  INSERT INTO t_listener (tx_machine, b_online) VALUES (@tx_machine, '1')

  SELECT @id_listener = id_listener 
  FROM t_listener
  WHERE tx_machine = @tx_machine
END
			