
create or replace function hextonum (hexstr varchar2)
   return number
as
	x varchar2(200);
begin

 	/* remove any leading hex literal chars */
 	x := ltrim(hexstr, '0Xx');

   /* convert and return */
	return nvl(to_number (x, rpad ('x', length (x), 'x')), 0);
end;
			