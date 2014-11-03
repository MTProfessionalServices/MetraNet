
				CREATE or REPLACE PROCEDURE CheckForNotArchivedDescendents (
					p_id_acc IN INTEGER,
					p_ref_date IN DATE,
					status OUT INTEGER)
				AS
				BEGIN
				  status := 1;

						/* select accounts that have status as closed or archived*/
						SELECT 
							count(*) into status 
						FROM 
				  		t_account_ancestor aa
							/* join between t_account_state and t_account_ancestor*/
							INNER JOIN t_account_state astate ON aa.id_descendent = astate.id_acc 
						WHERE
							aa.id_ancestor = p_id_acc AND
				  		astate.status <> 'AR' AND
				  		p_ref_date between astate.vt_start and astate.vt_end AND
				  		p_ref_date between aa.vt_start and aa.vt_end;
				  		/* success is when no rows found*/
                    IF status=0 THEN
         					status := 1;
         					return;
                    END IF;
				END;
				