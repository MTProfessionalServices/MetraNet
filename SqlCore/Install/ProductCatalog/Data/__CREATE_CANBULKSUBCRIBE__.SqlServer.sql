
			create proc CanBulkSubscribe(@id_old_po as int,
										 @id_new_po as int,
										 @subdate as datetime,
										 @status as int output)
			as
			declare @conflictcount as int
			set @conflictcount = 0
			set @status = 0 -- success
			declare @countvar as int
			declare @totalnum as int

			-- step 1: are there any subscriptions that are already subscribed to the new product offering
			set @conflictcount = (select count(t_sub.id_sub) --t_sub.id_acc,t_subnew.id_acc
			from t_sub where t_sub.id_po = @id_new_po AND
			t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate
			and t_sub.id_acc in (
				select sub2.id_acc from t_sub sub2 where sub2.id_po = @id_old_po AND
				sub2.vt_start <= @subdate AND sub2.vt_end >= @subdate
				)
			)
			if(@conflictcount > 0) begin
				set @status = 1
				return
			end

			-- step 2: does the destination product offering conflict with  
			select @countvar = count(id_pi_template),@totalnum = (select count(id_pi_template) from t_pl_map where id_po = @id_new_po)
			 from t_pl_map where id_po = @id_new_po AND id_pi_template in 
			(
			select id_pi_template from t_pl_map map where id_pi_template not in 
				-- find all templates from subscribed product offerings
				(select DISTINCT(id_pi_template) from t_pl_map where t_pl_map.id_po in 
					-- match all product offerings
					(select id_po from t_sub where 
					t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate 
					-- get all of the accounts where they are currently subscribed to the original
					-- product offering
					AND t_sub.id_acc in (
						select id_acc from t_sub where id_po = @id_old_po AND
						t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate
						)
					)
				)
			UNION
				select DISTINCT(id_pi_template) from t_pl_map where id_po = @id_old_po
			)

			if(@countvar <> @totalnum) begin
				set @status = 2
			end
		