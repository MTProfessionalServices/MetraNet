
				CREATE OR REPLACE PROCEDURE Addcountertype (
				id_lang_code INT,	n_kind INT,
				nm_name NVARCHAR2,
				nm_desc NVARCHAR2,			
				nm_formula_template VARCHAR2,
				valid_for_dist CHAR,
				id_prop OUT INT) 		
				AS				
				t_count INT;					
				temp_nm_name VARCHAR2(255);
				temp_id_lang_code INT;				
				identity_value INT;
				t_base_props_count INT;
				id_display_name INT;
				id_display_desc INT;
				BEGIN						
					id_prop := -1;
					temp_nm_name := nm_name;			
					temp_id_lang_code := id_lang_code;			
					/* need to know if any records are there */
					SELECT COUNT(*) INTO t_base_props_count FROM T_BASE_PROPS				
					WHERE T_BASE_PROPS.nm_name = temp_nm_name;
					SELECT COUNT(*) INTO t_count FROM t_vw_base_props				
					WHERE t_vw_base_props.nm_name = temp_nm_name
					AND t_vw_base_props.id_lang_code = temp_id_lang_code;
					IF t_base_props_count != 0 THEN
 						id_prop := -1;
					END IF;			
					IF t_count = 0 
						THEN			
						Insertbaseprops(id_lang_code, n_kind, 'N', 'N', nm_name, nm_desc, NULL, identity_value, id_display_name, id_display_desc);		   
						INSERT INTO T_COUNTER_METADATA (id_prop, FormulaTemplate, b_valid_for_dist) 
						VALUES (identity_value, 				    nm_formula_template, valid_for_dist);				
						id_prop := identity_value;			
					END IF;			
				END;
      