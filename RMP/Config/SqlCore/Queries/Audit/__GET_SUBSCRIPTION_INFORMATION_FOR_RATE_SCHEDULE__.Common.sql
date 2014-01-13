
          select gs.tx_Name as GroupSubscriptionName, s.id_group as GroupSubscriptionId, gs.id_corporate_account as GroupSubscriptionCorporateAccountId, hn_corp.hierarchyname as GroupSubscriptionCorporateAccountName,
                 hn.hierarchyname as IndividualSubscriptionName, s.id_acc as IndividualSubscriptionAccountId
                 ,bpPI.nm_name PriceableItemName, bpPT.nm_display_name ParameterTableName, bpPO.nm_display_name as ProductOfferingDisplayName
                 /*, s.id_po, s.id_group, plm.id_pricelist as PriceListId, plm.id_paramtable, plm.id_pi_type, *
                 */
                 from t_sub s          
          join t_pl_map plm on s.id_sub = plm.id_sub
          join t_rsched rsched on rsched.id_sched = %%RS_ID%% and plm.id_paramtable = rsched.id_pt and plm.id_pricelist = rsched.id_pricelist and plm.id_pi_template = rsched.id_pi_template
          left join t_group_sub gs on s.id_group = gs.id_group
          left join t_vw_base_props bpPT on plm.id_paramtable = bpPT.id_prop
          left join t_vw_base_props bpPI on plm.id_pi_type = bpPI.id_prop
          left join t_vw_base_props bpPO on plm.id_po = bpPO.id_prop
          left join vw_hierarchyname hn on s.id_acc = hn.id_acc
          left join vw_hierarchyname hn_corp on gs.id_corporate_account = hn_corp.id_acc
          inner join t_language lang on bpPT.id_lang_code=lang.id_lang_code and bpPI.id_lang_code=lang.id_lang_code and bpPO.id_lang_code=lang.id_lang_code

        