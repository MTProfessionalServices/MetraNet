
        CREATE OR REPLACE procedure PIResolutionByName(
            dt_session IN DATE, 
            temp_nm_name IN varchar2,
            temp_id_acc IN INTEGER,
            PINameCur OUT sys_refcursor)
        is
        BEGIN
             OPEN PINameCur FOR
             select 
              typemap.id_po,
              typemap.id_pi_instance,
              sub.id_sub
              from
                    /* select out the instances from the pl map (either need to follow 
                         up with a group by or assume one param table or add a unique entry
                         with a null param table/price list; I am assuming the null entry exists) */
              t_pl_map typemap 
              /* Now that we have the correct list of instances we match them up with the
                         accounts on the billing interval being processed.  For each account grab the
                        information about the billing interval dates so that we can select the 
                        correct intervals to process.
                        Go get all subscriptions product offerings containing the proper discount
                        instances */
              , t_sub sub 
                        /* Go get the effective date of the subscription to the discount */
              , t_base_props base
              where
              /* Join criteria for t_sub */
              typemap.id_po = sub.id_po
                    /*	join criteria for t_sub to t_effective_date
                         Find the subscription which contains the dt_session; there should be
                        at most one of these. */
              and (sub.vt_start <= PIResolutionByName.dt_session)
              and (sub.vt_end >= PIResolutionByName.dt_session)
                    /* Join template to base props */
              and base.id_prop=typemap.id_pi_template
              /* Select the unique instance record that includes an instance in a template */
              and typemap.id_paramtable is null
              and base.nm_name = PIResolutionByName.temp_nm_name
              and sub.id_acc = PIResolutionByName.temp_id_acc;
        END PIResolutionByName;
		