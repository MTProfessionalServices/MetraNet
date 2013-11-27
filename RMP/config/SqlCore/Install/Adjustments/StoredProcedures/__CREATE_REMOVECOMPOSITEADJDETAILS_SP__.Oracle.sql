
			CREATE OR REPLACE PROCEDURE RemoveCompositeAdjDetails
			(p_id_prop int)
            AS
			BEGIN
				DELETE FROM T_COMPOSITE_ADJUSTMENT WHERE id_prop =RemoveCompositeAdjDetails.p_id_prop;
			END;
			