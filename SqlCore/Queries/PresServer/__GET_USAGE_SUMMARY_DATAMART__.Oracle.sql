
  	  select *
      from
      (
      SELECT
      /* __GET_USAGE_SUMMARY_DATAMART__ */
      bpd2.nm_display_name as ProductOfferingName,
      bp2d2.nm_display_name as PriceableItemName,
      bp3d2.nm_display_name as PriceableItemInstanceName,
      au.id_prod as ProductOfferingId,
      au.id_pi_instance as PriceableItemInstanceId,
      au.id_pi_template as PriceableItemTemplateId,
      piTemplated2.id_template_parent as PriceableItemParentId,
      au.id_view as ViewID,
      descd2.tx_desc as ViewName,
      'Product' as ViewType,
      {fn IFNULL(bp3d2.n_display_name, bp2d2.n_display_name)} as DescriptionID,
      au.am_currency Currency,
      SUM({fn IFNULL(au.Amount, 0.0)}) as Amount
      /* prebill adjustments */
      ,sum({fn IFNULL(adjustments.AtomicPrebillAdjAmt, 0.0)}) AtomicPrebillAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillAdjAmt, 0.0)}) CompoundPrebillAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillAdjedAmt, au.amount)}) CompoundPrebillAdjedAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillAdjedAmt, au.amount)}) AtomicPrebillAdjedAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillFedTaxAdjAmt, 0.0)}) CompoundPrebillFedTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillStateTaxAdjAmt, 0.0)}) CompoundPrebillStateTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillCntyTaxAdjAmt, 0.0)}) CompoundPrebillCntyTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillLocalTaxAdjAmt, 0.0)}) CompoundPrebillLocalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillOtherTaxAdjAmt, 0.0)}) CompoundPrebillOtherTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPrebillTotalTaxAdjAmt, 0.0)}) CompoundPrebillTotalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillFedTaxAdjAmt, 0.0)}) CompoundPostbillFedTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillStateTaxAdjAmt, 0.0)}) CompoundPostbillStateTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillCntyTaxAdjAmt, 0.0)}) CompoundPostbillCntyTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillLocalTaxAdjAmt, 0.0)}) CompoundPostbillLocalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillOtherTaxAdjAmt, 0.0)}) CompoundPostbillOtherTaxAdjAmt
      ,sum({fn IFNULL(adjustments.CompoundPostbillTotalTaxAdjAmt, 0.0)}) CompoundPostbillTotalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillFedTaxAdjAmt, 0.0)}) AtomicPrebillFedTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillStateTaxAdjAmt, 0.0)}) AtomicPrebillStateTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillCntyTaxAdjAmt, 0.0)}) AtomicPrebillCntyTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillLocalTaxAdjAmt, 0.0)}) AtomicPrebillLocalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillOtherTaxAdjAmt, 0.0)}) AtomicPrebillOtherTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPrebillTotalTaxAdjAmt, 0.0)}) AtomicPrebillTotalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillFedTaxAdjAmt, 0.0)}) AtomicPostbillFedTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillStateTaxAdjAmt, 0.0)}) AtomicPostbillStateTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillCntyTaxAdjAmt, 0.0)}) AtomicPostbillCntyTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillLocalTaxAdjAmt, 0.0)}) AtomicPostbillLocalTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillOtherTaxAdjAmt, 0.0)}) AtomicPostbillOtherTaxAdjAmt
      ,sum({fn IFNULL(adjustments.AtomicPostbillTotalTaxAdjAmt, 0.0)}) AtomicPostbillTotalTaxAdjAmt
     ,SUM({fn IFNULL(au.Tax_Federal, 0.0)} + {fn IFNULL(au.Tax_State, 0.0)} + {fn IFNULL(au.Tax_County, 0.0)} 
     + {fn IFNULL(au.Tax_Local, 0.0)} + {fn IFNULL(au.Tax_Other, 0.0)}) as TaxAmount,
      SUM({fn IFNULL(au.tax_federal, 0.0)}) FederalTaxAmount,
      SUM({fn IFNULL(au.tax_state, 0.0)}) StateTaxAmount,
      SUM({fn IFNULL(au.tax_county, 0.0)}) CountyTaxAmount,
      SUM({fn IFNULL(au.tax_local, 0.0)}) LocalTaxAmount,
      SUM({fn IFNULL(au.tax_other, 0.0)}) OtherTaxAmount,
      SUM({fn IFNULL(au.Amount, 0.0)} + {fn IFNULL(au.Tax_Federal, 0.0)} + {fn IFNULL(au.Tax_State, 0.0)} + {fn IFNULL(au.Tax_County, 0.0)} + {fn IFNULL(au.Tax_Local, 0.0)} + {fn IFNULL(au.Tax_Other, 0.0)}) as AmountWithTax,      
      SUM(%%DISPLAYAMOUNT%%) AS DisplayAmount,
      COUNT(1) as Count
      from
      t_acc_usage au 
      left outer join t_mv_adjustments_usagedetail Adjustments on au.id_sess = Adjustments.id_sess
      and Adjustments.id_usage_interval = au.id_usage_interval
      left outer join t_vw_base_props bp2d2 on au.id_pi_template=bp2d2.id_prop and bp2d2.id_lang_code=%%ID_LANG%%
      left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template
      left outer join t_vw_base_props bpd2 on au.id_prod=bpd2.id_prop and bpd2.id_lang_code=%%ID_LANG%%
      left outer join t_vw_base_props bp3d2 on au.id_pi_instance=bp3d2.id_prop and bp3d2.id_lang_code=%%ID_LANG%%
	  inner join t_description descd2 on au.id_view=descd2.id_desc and descd2.id_lang_code=%%ID_LANG%%
      %%FROM_CLAUSE%%
      where
      rownum <= 1001
      and
      %%TIME_PREDICATE%%
      and 
      %%ACCOUNT_PREDICATE%%
      and 
      %%SESSION_PREDICATE%%
      group by
      au.id_prod,
      bpd2.nm_display_name,
      bp2d2.nm_display_name,
      bp3d2.nm_display_name,
      au.id_pi_instance,
      au.id_pi_template,
      piTemplated2.id_template_parent,
      au.id_view,
      descd2.tx_desc,
      bp2d2.n_display_name,
      bp3d2.n_display_name,
      au.am_currency 
      order by
      ProductOfferingName,
      piTemplated2.id_template_parent desc,
      PriceableItemName,
      au.id_view,
      au.am_currency 
      ) foo		
      