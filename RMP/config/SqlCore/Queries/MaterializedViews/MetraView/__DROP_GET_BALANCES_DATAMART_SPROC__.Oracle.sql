
		begin
			if (object_exists('GetBalances_Datamart')) then
				execute immediate 'drop procedure GetBalances_Datamart';
			end if;
		end;
        