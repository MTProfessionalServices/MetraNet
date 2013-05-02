
create or replace function getutcdate
   return date
as
begin
   return sys_extract_utc(systimestamp);
end;
			