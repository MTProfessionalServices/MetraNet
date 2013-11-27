
           SELECT COUNT(*) AS cnt 
           FROM
           t_pi_template child 
           WHERE
           child.id_template_parent = %%ID_PI_TEMPLATE%%
        