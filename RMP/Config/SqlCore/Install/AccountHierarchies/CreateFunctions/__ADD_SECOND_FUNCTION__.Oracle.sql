
				create or replace function AddSecond(RefDate date) return date 
				as
				begin
				 return RefDate + numtodsinterval(1,'second');
				end;
				