
					create or replace function IsAccountFolder(p_id_acc IN integer) 
					return varchar2
					as
					 folderFlag char(1);
					begin
					 begin
						for i in (select c_folder from t_av_internal where 
						id_acc = p_id_acc)
                  loop
                     folderFlag := i.c_folder;
                  end loop;
					 end;

				 	 if folderFlag is NULL then
							folderFlag := '0';
				 	 end if; 

					 return folderFlag;
					end;
				