
    /*  __GET_DEPENDENT_SUBSCRIBERS_COUNT_FOR_PRODUCT_OFFERING__ */
    select
          count(*) as numberdependentsubscribers
    from t_vw_expanded_sub
    where (vt_end is null
          or vt_end > getutcdate())
      and id_po = %%ID_PO%%
      