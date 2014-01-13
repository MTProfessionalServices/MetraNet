
begin
  if not table_exists('%%TABLE%%') then
     %%CREATE_STATEMENT%%
  end if;
end;
			