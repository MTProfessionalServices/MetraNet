
                select 
                /*  Protect against  */
                /*  1) the start date moving ahead of any subscription start dates */
                /*  2) the end date moving behing any subscription start dates */
                /*  */
                /*  We allow end dates to move behind subscription end dates temporarily (because */
                /*  we truncate the subscription end dates in response to this condition). */
                {fn IFNULL(sum(case when s.vt_start < ed.dt_start then 1 else 0 end), 0)} as n_start_date_violations,
                {fn IFNULL(sum(case when s.vt_start > ed.dt_end then 1 else 0 end), 0)} as n_end_date_violations
                from t_sub s  
                inner join t_po po on s.id_po=po.id_po
                inner join t_effectivedate ed on po.id_eff_date=ed.id_eff_date
                where 
                (s.vt_start < ed.dt_start
                or 
                s.vt_start > ed.dt_end)
                and
                s.id_po=%%ID_PO%% 
                