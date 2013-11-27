
     CREATE OR REPLACE PROCEDURE UpdateCounterPropDef(
        id_lang_code int,
        temp_id_prop int,
        nm_name nvarchar2,
        nm_display_name nvarchar2,
        id_pi int,
        nm_servicedefprop nvarchar2,
        nm_preferredcountertype nvarchar2,
        n_order int)
      AS
        identity_value int;
        id_locale int;
        id_dummy int;
      BEGIN
		UpdateBaseProps(temp_id_prop, id_lang_code, nm_name, NULL, nm_display_name);
        UPDATE t_counterpropdef
		SET nm_servicedefprop = nm_servicedefprop,
		n_order = n_order,
		nm_preferredcountertype = nm_preferredcountertype
		WHERE id_prop = temp_id_prop;
      END;
        