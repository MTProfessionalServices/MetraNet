
				create function IsAccountFolder(@id_acc int) 
				returns varchar
				as
				begin 
				declare @folderFlag char(1)
				select @folderFlag = c_folder  from t_av_internal where 
				id_acc = @id_acc
				if (@folderFlag is NULL)
					begin
					select @folderFlag = '0'
					end  
				return @folderFlag
				end
				