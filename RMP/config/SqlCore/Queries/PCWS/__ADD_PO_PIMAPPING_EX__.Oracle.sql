
                DECLARE
                     v_PIType                INT;
                     v_PITemplate            INT;
                     v_PIInstanceID_Parent   INT;
                  BEGIN
                     SELECT id_pi_type, id_pi_template, id_pi_instance_parent
                       INTO v_PIType, v_PITemplate, v_PIInstanceID_Parent
                       FROM t_pl_map
                      WHERE id_pi_instance = %%ID_PI%%
                        AND id_po = %%ID_PO%%
                        AND id_paramtable IS NULL;

                     INSERT INTO t_pl_map
                                 (id_paramtable, id_pi_type, id_pi_template,
                                  id_pi_instance, id_pi_instance_parent, id_po,
                                  id_pricelist, b_canicb, dt_modified
                                 )
                          VALUES (%%ID_PTD%%, v_PIType, v_PITemplate,
                                  %%ID_PI%%, v_PIInstanceID_Parent, %%ID_PO%%,
                                  %%ID_PL%%, '%%CAN_ICB%%', %%%SYSTEMDATE%%%
                                 );
                    END;
              