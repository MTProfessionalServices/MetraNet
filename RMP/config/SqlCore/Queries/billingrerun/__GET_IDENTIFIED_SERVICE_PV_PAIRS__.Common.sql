
		SELECT rr.id_view, rr.id_svc, edpv.nm_enum_data as nm_view, edsvc.nm_enum_data as nm_svc, min(rr.id) as min_id, max(rr.id) as max_id 
    FROM %%TABLE_NAME%% rr
    INNER JOIN t_enum_data edpv on edpv.id_enum_data=rr.id_view
    INNER JOIN t_enum_data edsvc on edsvc.id_enum_data=rr.id_svc
		INNER JOIN t_prod_view pv on pv.id_view=rr.id_view
		WHERE rr.id_view IS NOT NULL AND rr.tx_state = 'A'
		AND pv.b_can_resubmit_from='Y'
		GROUP BY rr.id_view, rr.id_svc, edpv.nm_enum_data, edsvc.nm_enum_data
		