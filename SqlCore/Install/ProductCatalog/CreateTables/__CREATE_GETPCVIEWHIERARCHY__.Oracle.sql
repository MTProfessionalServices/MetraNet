
            CREATE OR REPLACE PROCEDURE GetPCViewHierarchy(
                p_id_acc       INT,
                p_id_interval  INT,
                p_id_lang_code INT,
                p_cur OUT sys_refcursor)
            AS
            BEGIN
                OPEN p_cur FOR
                SELECT 
                tb_po.n_display_name id_po,/* use the display name as the product offering ID */
                /* au.id_prod id_po, */
                pi_template.id_template_parent id_template_parent,
                /* po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end, */
                CASE WHEN T_DESCRIPTION.tx_desc IS NULL THEN template_desc.tx_desc ELSE T_DESCRIPTION.tx_desc END po_nm_name,
                ed.nm_enum_data pv_child,
                ed.id_enum_data pv_childID,
                CASE WHEN parent_kind.nm_productview IS NULL THEN tb_po.n_display_name ELSE tenum_parent.id_enum_data END pv_parentID,
                CASE WHEN pi_props.n_kind = 15 THEN 'Y' ELSE 'N' END AggRate,
                CASE WHEN au.id_pi_instance IS NULL THEN id_view ELSE 
                    (CASE WHEN pi_props.n_kind = 15 AND child_kind.nm_productview = ed.nm_enum_data THEN
                    -(au.id_pi_instance + TO_NUMBER(40000000,'XXXXXXXX'))
                    ELSE
                    -au.id_pi_instance 
                    END)
                END viewID,
                id_view realPVID,
                /* ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end, */
                CASE WHEN tb_instance.nm_display_name IS NULL THEN tb_template.nm_display_name ELSE tb_instance.nm_display_name END ViewName,
                'Product' ViewType,
                /* id_view DescriptionID, */
                CASE WHEN T_DESCRIPTION.tx_desc IS NULL THEN template_props.n_display_name ELSE id_view END DescriptionID,
                SUM(au.amount) Amount,
                COUNT(au.id_sess) COUNT,
                au.am_currency Currency, SUM((NVL((au.tax_federal), 
                0.0) + NVL((au.tax_state), 0.0) + NVL((au.tax_county), 0.0) + 
                NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0))) TaxAmount, 
				SUM(au.amount + 
				  /*If implied taxes, then taxes are already included, don't add them again */
				  (case when au.is_implied_tax = 'N' then (NVL((au.tax_federal), 0.0) + NVL((au.tax_state), 0.0) + 
                    NVL((au.tax_county), 0.0) + NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0)) else 0 end)
				  /*If informational taxes, then they shouldn't be in the total */
                  - (case when au.tax_informational = 'Y' then (NVL((au.tax_federal), 0.0) + NVL((au.tax_state), 0.0) + 
                    NVL((au.tax_county), 0.0) + NVL((au.tax_local), 0.0) + NVL((au.tax_other), 0.0)) else 0 end)
				  AmountWithTax
                FROM T_USAGE_INTERVAL
                JOIN T_ACC_USAGE au ON au.id_acc = p_id_acc AND au.id_usage_interval = p_id_interval AND au.id_pi_template IS NOT NULL
                JOIN T_BASE_PROPS tb_template ON tb_template.id_prop = au.id_pi_template
                JOIN T_PI_TEMPLATE pi_template ON pi_template.id_template = au.id_pi_template
                JOIN T_PI child_kind ON child_kind.id_pi = pi_template.id_pi
                JOIN T_BASE_PROPS pi_props ON pi_props.id_prop = child_kind.id_pi
                JOIN T_ENUM_DATA ed ON ed.id_enum_data = au.id_view
                JOIN T_BASE_PROPS template_props ON pi_template.id_template = template_props.id_prop
                JOIN T_DESCRIPTION template_desc ON template_props.n_display_name = template_desc.id_desc AND template_desc.id_lang_code = p_id_lang_code
                LEFT OUTER JOIN T_PI_TEMPLATE parent_template ON parent_template.id_template = pi_template.id_template_parent
                LEFT OUTER JOIN T_PI parent_kind ON parent_kind.id_pi = parent_template.id_pi
                LEFT OUTER JOIN T_ENUM_DATA tenum_parent ON tenum_parent.nm_enum_data = parent_kind.nm_productview
                LEFT OUTER JOIN T_BASE_PROPS tb_po ON tb_po.id_prop = au.id_prod
                LEFT OUTER JOIN T_BASE_PROPS tb_instance ON tb_instance.id_prop = au.id_pi_instance 
                LEFT OUTER JOIN T_DESCRIPTION ON T_DESCRIPTION.id_desc = tb_po.n_display_name AND T_DESCRIPTION.id_lang_code = p_id_lang_code
                WHERE
                T_USAGE_INTERVAL.id_interval = p_id_interval
                GROUP BY 
                /* t_pl_map.id_po,t_pl_map.id_pi_instance_parent, */
                tb_po.n_display_name,tb_instance.n_display_name,
                T_DESCRIPTION.tx_desc,template_desc.tx_desc,
                tb_instance.nm_display_name,tb_template.nm_display_name,
                tb_instance.nm_display_name, /* this shouldn't need to be here!! */
                child_kind.nm_productview,
                parent_kind.nm_productview,tenum_parent.id_enum_data,
                pi_props.n_kind,
                id_view,ed.nm_enum_data,ed.id_enum_data,
                au.am_currency,
                tb_template.nm_name,
                pi_template.id_template_parent,
                au.id_pi_instance,
                template_props.n_display_name
                ORDER BY tb_po.n_display_name ASC, pi_template.id_template_parent ASC;
            END;
		