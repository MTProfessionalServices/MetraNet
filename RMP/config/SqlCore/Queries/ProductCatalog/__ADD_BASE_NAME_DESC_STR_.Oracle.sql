
				begin
					declare temp_id int; id int;
                	begin
					sp_InsertBaseProps(%%TYPE%%,NULL,NULL,'N',
					'N','%%NAME_STR%%','%%DESC_STR%%',temp_id);
					id := temp_id;
                	end;
               	end;
			