
			create proc InsertChargeProperty
			@a_id_charge int,
			@a_id_prod_view_prop int,
			@a_id_charge_prop int OUTPUT
			as
			insert into t_charge_prop
      (
			id_charge,
			id_prod_view_prop
      )
      values
      (
			@a_id_charge,
			@a_id_prod_view_prop
      )
			select @a_id_charge_prop =@@identity
	