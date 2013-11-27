
                select 
                case when n_begintype = 0 or n_begintype = 4 then 0 else 1 end as AvailabilitySet 
                from
                t_po po
                join 
                t_effectivedate ed on po.id_avail = ed.id_eff_date
                where 
                po.id_po = %%PO_ID%%
                