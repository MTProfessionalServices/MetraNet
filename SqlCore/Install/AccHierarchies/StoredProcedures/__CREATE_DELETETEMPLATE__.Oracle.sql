
			CREATE or replace procedure DeleteTemplate(
				p_id_template int, 
				p_status out int )
 			as
	 		begin
				p_status := 1; /*success*/

				/* delete the subscriptions in this template*/
		 		delete from t_acc_template_subs 
					where id_acc_template = p_id_template;
				/* delete public properties for this template*/
		 		delete from t_acc_template_props_pub
					where id_acc_template = p_id_template;
				/* delete private properties for this template*/
		 		delete from t_acc_template_props
					where id_acc_template = p_id_template;
				/* delete the template itself*/
		 		delete from t_acc_template
					where id_acc_template = p_id_template;
		 		if (SQL%ROWCOUNT <> 1) then
					p_status := -486604725; /* create an error MT_NO_TEMPLATE_FOUND*/
		   		end if;
			 end;
				