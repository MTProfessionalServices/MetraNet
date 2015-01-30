
				create function AddSecond(@RefDate datetime) returns datetime 
				as
				begin
				 return (dateadd(s,1,@RefDate))
				end
				