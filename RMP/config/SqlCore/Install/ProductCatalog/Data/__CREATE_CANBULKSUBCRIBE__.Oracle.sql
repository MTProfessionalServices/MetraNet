
				create or replace procedure CanBulkSubscribe(
				id_old_po IN int,
				id_new_po IN int,
				subdate IN date,
				status OUT int)
				as
				conflictcount int;
				countvar int;
				totalnum int;
				begin
					status := 0;	/*	success */
					conflictcount := 0;
					/* step 1: are there any subscriptions that are already subscribed to the new product offering */
					select count(t_sub.id_sub) into conflictcount
					from t_sub where t_sub.id_po = id_new_po AND
					t_sub.vt_start <= subdate AND t_sub.vt_end >= subdate
					and t_sub.id_acc in (
					select sub2.id_acc from t_sub sub2 where sub2.id_po = id_old_po AND
					sub2.vt_start <= subdate AND sub2.vt_end >= subdate
					);
					if(conflictcount > 0) then
						status := 1;
						return;
					end if;
					/* step 2: does the destination product offering conflict with   */
					select count(id_pi_template) into totalnum from t_pl_map where id_po = id_new_po;
					select count(id_pi_template) into countvar
					from t_pl_map where id_po = id_new_po AND id_pi_template in 
					(
					select id_pi_template from  t_pl_map where id_pi_template not in 
					/* find all templates from subscribed product offerings */
					(select DISTINCT(id_pi_template) from t_pl_map where t_pl_map.id_po in 
					/* match all product offerings */
					(select id_po from t_sub where t_sub.vt_start <= subdate AND t_sub.vt_end >= subdate
					/* get all of the accounts where they are currently subscribed to the original */
					/* product offering */
					AND t_sub.id_acc in (
						select id_acc from t_sub where id_po = id_old_po AND
						t_sub.vt_start <= subdate AND t_sub.vt_end >= subdate
						)
						)
					)
					UNION
					select DISTINCT(id_pi_template) from t_pl_map where id_po = id_old_po
					);
					if(countvar <> totalnum) then
					status := 2;
					end if;
				end;
			