
				CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_po ON t_vw_allrateschedules_po (id_pi_template, id_sub, id_po, id_sched, id_pi_instance)
				create unique index idx_t_vw_allrateschedules_po_param on t_vw_allrateschedules_po (id_sched, id_pi_instance)
				CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_pl ON t_vw_allrateschedules_pl (id_pi_template, id_pricelist, id_sched)
				create unique index idx_t_vw_allrateschedules_pl_param on t_vw_allrateschedules_pl (id_sched)
				CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_po_icb ON t_vw_allrateschedules_po_icb (id_pi_template, id_sub, id_po, id_sched, id_pi_instance)
				create unique index idx_t_vw_allrateschedules_po_icb_sub on t_vw_allrateschedules_po_icb (id_sched, id_pi_instance)
        CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_po_noicb ON t_vw_allrateschedules_po_noicb (id_pi_template, id_po, id_sched, id_pi_instance)
        create unique index idx_t_vw_allrateschedules_po_noicb_pi on t_vw_allrateschedules_po_noicb (id_sched, id_pi_instance)
		