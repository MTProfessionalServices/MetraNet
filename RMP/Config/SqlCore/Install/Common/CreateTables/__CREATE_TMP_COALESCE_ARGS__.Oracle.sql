
          create global temporary table tmp_coalesce_args
            (id_acc number(10),
            id_group number(10),
            vt_start date,
            vt_end date,
            tt_start date,
            tt_end date,
            update_tt_start date,
            update_tt_end date,
            update_vt_end date
            ) on commit preserve rows
        