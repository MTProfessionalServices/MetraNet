
			create proc AddCounterParamPredicate
									@id_counter_param int,
									@id_pv_prop int,
                  @nm_op nvarchar(2),
									@nm_value nvarchar(255),
									@ap_id_prop int OUTPUT
			AS
			BEGIN TRAN
			INSERT INTO t_counter_param_predicate
				(id_counter_param, id_pv_prop, nm_op, nm_value) 
			VALUES 
				(@id_counter_param, @id_pv_prop, @nm_op, @nm_value)
			SELECT 
				@ap_id_prop = @@identity
			COMMIT TRAN
		