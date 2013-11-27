
create or replace function MessageQueueLength
return int
is
    l_queueLength int;
begin
  SELECT count(*) into l_queueLength from t_message where dt_assigned is null;
  return l_queueLength;
end;
			