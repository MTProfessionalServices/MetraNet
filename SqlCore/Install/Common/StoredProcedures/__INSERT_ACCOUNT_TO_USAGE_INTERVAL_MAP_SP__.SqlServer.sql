
				 CREATE PROC InsertAcctToIntervalMapping @id_acc int, @id_interval int
         as
				 SET NOCOUNT ON
				 if not exists (select * from t_acc_usage_interval where id_acc = @id_acc
          and id_usage_interval = @id_interval)
				 begin
          insert into t_acc_usage_interval (id_acc, id_usage_interval, tx_status)
          select @id_acc, @id_interval, ISNULL(tx_interval_status, 'O')
          from t_usage_interval
          where id_interval = @id_interval and
                tx_interval_status != 'B'
         end
			 