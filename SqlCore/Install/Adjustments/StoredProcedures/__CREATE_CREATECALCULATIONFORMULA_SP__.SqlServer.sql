
						create procedure CreateCalculationFormula
						(@p_tx_formula ntext,
             @p_id_engine INT,
             @op_id_prop int OUTPUT)
						as
						begin
            	INSERT INTO t_calc_formula
            	(tx_formula,id_engine) VALUES (
							@p_tx_formula, @p_id_engine)
							if (@@error <> 0) 
                  begin
                  select @op_id_prop = -99
                  end
                  else
                  begin
                  select @op_id_prop = @@identity
                  end
        		END
				