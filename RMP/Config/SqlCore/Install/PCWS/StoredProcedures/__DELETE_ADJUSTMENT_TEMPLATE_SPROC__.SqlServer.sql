
			Create procedure DeleteAdjustmentTemplate(@adjTemplId int, @status int output) as
			BEGIN
				If exists (select id_adj_trx from t_adjustment_transaction where id_aj_template = @adjTemplID)
				BEGIN
					Set @status = -10;
					Return
				End
	
				Delete from t_aj_template_reason_code_map where id_adjustment = @adjTemplId
				Delete from t_adjustment where id_prop = @adjTemplId
				
				SET @status = 0;
				
			END
			