
				create proc AddCounterType
					  		  @id_lang_code int,
									@n_kind int,
									@nm_name nvarchar(255),
									@nm_desc nvarchar(255),
									@nm_formula_template varchar(1000),
									@valid_for_dist char(1),
									@id_prop int OUTPUT 
			AS
			begin
			declare @t_count int	
			declare @temp_nm_name nvarchar(255)
			declare @temp_id_lang_code int
			declare @identity_value int
			declare @t_base_props_count int
			declare @id_display_name int
			declare @id_display_desc int
				  
			select @id_prop = -1
      select @temp_nm_name = @nm_name
			select @temp_id_lang_code = @id_lang_code

      SELECT @t_base_props_count = COUNT(*) FROM T_BASE_PROPS				
      WHERE T_BASE_PROPS.nm_name = @nm_name
			SELECT @t_count = COUNT(*) FROM t_vw_base_props
				WHERE t_vw_base_props.nm_name = @temp_nm_name and t_vw_base_props.id_lang_code = @temp_id_lang_code
      IF (@t_base_props_count <> 0)
				begin	
 				select @id_prop = -1
				end			

			IF (@t_count = 0)
			  begin
				exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, @nm_desc, null, @identity_value OUTPUT, @id_display_name OUTPUT, @id_display_desc OUTPUT
		    INSERT INTO t_counter_metadata (id_prop, FormulaTemplate, b_valid_for_dist) values (@identity_value, 
				    @nm_formula_template, @valid_for_dist)
				select @id_prop = @identity_value
			  end
       end
			