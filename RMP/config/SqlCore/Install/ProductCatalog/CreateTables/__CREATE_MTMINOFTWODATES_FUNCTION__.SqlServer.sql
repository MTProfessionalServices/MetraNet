
	-- Function returns the minimum of two dates.  A null date is considered
	-- to be infinitely large.
	create function MTMinOfTwoDates(@chargeIntervalLeft datetime, @subIntervalLeft datetime) returns datetime
	as
	begin
	return case when @subIntervalLeft is null or @chargeIntervalLeft < @subIntervalLeft then @chargeIntervalLeft else @subIntervalLeft end
	end		
	