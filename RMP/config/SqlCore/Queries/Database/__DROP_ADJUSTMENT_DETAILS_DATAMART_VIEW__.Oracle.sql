
   		begin
			if (object_exists('VW_ADJUSTMENT_DETAILS_DATAMART')) then
				execute immediate 'drop view VW_ADJUSTMENT_DETAILS_DATAMART';
			end if;
		end;
    