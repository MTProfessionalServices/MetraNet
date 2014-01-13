
		CREATE OR REPLACE PROCEDURE CreateCompositeAdjustmentType
							(p_id_prop INT,
							p_tx_guid BLOB,
							p_id_pi_type INT,
							p_n_AdjustmentType INT,
							p_b_supportBulk VARCHAR2,
							p_tx_defaultdesc NVARCHAR2,
							p_id_formula INT,
							p_n_composite_adjustment INT
							)
							as
							begin
									INSERT INTO t_adjustment_type
									(id_prop, tx_guid,id_pi_type,n_AdjustmentType,b_supportBulk,id_formula, tx_default_desc,  n_composite_adjustment
									) VALUES ( p_id_prop, p_tx_guid, p_id_pi_type, p_n_AdjustmentType, p_b_supportBulk, p_id_formula,
									p_tx_defaultdesc, p_n_composite_adjustment);
							END;
			