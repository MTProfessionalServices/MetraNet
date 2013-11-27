
					CREATE OR REPLACE PROCEDURE RemoveAdjustmentTypeProps(p_id_prop int)
							  AS
							  BEGIN
								 execute immediate 'DELETE FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type = ' || to_char(RemoveAdjustmentTypeProps.p_id_prop);
								 FOR CursorVar IN (
												  SELECT id_prop as id_prop FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type = RemoveAdjustmentTypeProps.p_id_prop)
								 loop
									DeleteBaseProps(CursorVar.id_prop);
								 end loop;
							  END;
			