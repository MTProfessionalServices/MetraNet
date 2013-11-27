
		declare %%MV_EXISTS_VAR%% number(10);
        begin
			%%MV_EXISTS_VAR%% := %%MV_EXISTS_VALUE%%;
            if not table_exists('%%MV_TABLE_NAME%%') then
				%%CREATE_MV_QUERY%%
            elsif (%%MV_EXISTS_VAR%% = 0) then
				raise_application_error(-20101, 'Table [%%MV_TABLE_NAME%%] already exists.');
			end if;
        end;
		