
			CREATE OR REPLACE PROCEDURE RemoveCounterPropDef
				(temp_id_prop int)
           	AS
				id_locale int;
			BEGIN 
				DELETE FROM t_counter_map 
							WHERE id_cpd = temp_id_prop; 
				DELETE FROM t_counterpropdef WHERE id_prop = temp_id_prop;
        /* CR 14459 */
        DeleteBaseProps(temp_id_prop);
			END;
     