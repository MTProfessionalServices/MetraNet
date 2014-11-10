
				create or replace function SubtractSecond(RefDate date) return date 
				as
				begin
				 return RefDate + numtodsinterval(-1,'second');
				end;
				