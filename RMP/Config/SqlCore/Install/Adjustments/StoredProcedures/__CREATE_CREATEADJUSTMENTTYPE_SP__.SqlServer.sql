
						create procedure CreateAdjustmentType
						(@p_id_prop INT, 
						 @p_tx_guid VARBINARY(16), 
						 @p_id_pi_type INT, 
             @p_n_AdjustmentType INT, 
             @p_b_supportBulk VARCHAR,
             @p_tx_defaultdesc NTEXT,
             @p_id_formula INT
             )
						as
						begin
            	INSERT INTO t_adjustment_type
            	(id_prop, tx_guid,id_pi_type,n_AdjustmentType,b_supportBulk,id_formula, tx_default_desc
            	 ) VALUES (
							@p_id_prop, @p_tx_guid, @p_id_pi_type, @p_n_AdjustmentType, @p_b_supportBulk, @p_id_formula,
							@p_tx_defaultdesc)
        		END
				