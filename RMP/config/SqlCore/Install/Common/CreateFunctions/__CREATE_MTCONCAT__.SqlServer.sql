
create function mtconcat(@str1 varchar(4000),@str2 varchar(4000)) returns varchar(4000)
as
begin
return @str1 + @str2
end
	