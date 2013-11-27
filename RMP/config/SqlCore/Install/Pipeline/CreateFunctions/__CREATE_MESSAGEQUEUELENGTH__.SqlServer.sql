
create function MessageQueueLength()
returns int
as
begin
  declare @queueLength int
  SELECT @queueLength = count(*) from t_message with (READPAST) where dt_assigned is null
  return @queueLength
end
			