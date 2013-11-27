
create function MTHexFormat(@value integer) returns varchar(255)
as
begin
 declare @binvalue varbinary(255)
	      ,@charvalue varchar(255)
        ,@i int
        ,@length int
        ,@hexstring char(16)
 select @charvalue = ''
       ,@i=1
       ,@binvalue = cast(@value as varbinary(4))
       ,@length=datalength(@binvalue)
       ,@hexstring = '0123456789abcdef'
 WHILE (@i<=@length)
   begin
     declare @tempint int
            ,@firstint int
            ,@secondint int
     select @tempint=CONVERT(int, SUBSTRING(@binvalue,@i,1))
     select @firstint=FLOOR(@tempint/16)
     select @secondint=@tempint - (@firstint*16)
     select @charvalue=@charvalue
           +SUBSTRING(@hexstring,@firstint+1,1)
           +SUBSTRING(@hexstring, @secondint+1, 1)
    select @i=@i+1
   end
 return @charvalue
end	