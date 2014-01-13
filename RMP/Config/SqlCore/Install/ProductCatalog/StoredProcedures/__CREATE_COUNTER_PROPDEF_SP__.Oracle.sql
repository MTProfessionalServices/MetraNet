
		CREATE OR REPLACE PROCEDURE CreateCounterPropDef(
			temp_id_lang_code int,
			n_kind int,
			nm_name nvarchar2,
			nm_display_name nvarchar2,
			temp_id_pi t_counterpropdef.id_pi%type,
			nm_servicedefprop t_counterpropdef.nm_servicedefprop%type,
			nm_preferredcountertype t_counterpropdef.nm_preferredcountertype%type,
			n_order t_counterpropdef.n_order%type,
			id_prop OUT int)
		AS
			identity_value 	t_counterpropdef.id_prop%type;
			id_locale int;
		BEGIN
			InsertBaseProps(temp_id_lang_code, n_kind, 'N', 'N', nm_name, NULL, nm_display_name, identity_value);

			INSERT INTO t_counterpropdef
				(id_prop, id_pi, nm_servicedefprop, n_order,
				nm_preferredcountertype)
			VALUES
				(identity_value, temp_id_pi, nm_servicedefprop, n_order, nm_preferredcountertype);
			id_prop := identity_value;
		END;
      