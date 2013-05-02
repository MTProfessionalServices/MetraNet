
          CREATE or replace force view VW_ADJUSTMENT_SUMMARY as
          select
          ajtrx.id_acc_payer id_acc,
          ajtrx.id_usage_interval,
          ajtrx.am_currency,
          ajui.dt_start,
          ajui.dt_end,
        /*add info about adjustments */
        SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PrebillAdjAmt
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_federal+aj_tax_state+aj_tax_county+aj_tax_local+aj_tax_other ELSE 0 END)  AS PrebillTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_federal ELSE 0 END)  AS PrebillFederalTaxAdjustAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_state ELSE 0 END)  AS PrebillStateTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_county ELSE 0 END)  AS PrebillCntyTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_local ELSE 0 END)  AS PrebillLocalTaxAdjAmnt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN aj_tax_other ELSE 0 END)  AS PrebillOtherTaxAdjAmnt
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PostbillAdjAmt
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_federal+aj_tax_state+aj_tax_county+aj_tax_local+aj_tax_other ELSE 0 END)  AS PostbillTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_federal ELSE 0 END)  AS PostbillFedTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_state ELSE 0 END)  AS PostbillStateTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_county ELSE 0 END)  AS PostbillCntyTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_local ELSE 0 END)  AS PostbillLocalTaxAdjAmt
         ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN aj_tax_other ELSE 0 END)  AS PostbillOtherTaxAdjAmt
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN 1 ELSE 0 END)  AS NumPostbillAdjustments
       ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN 1 ELSE 0 END)  AS NumPrebillAdjustments
        FROM t_adjustment_transaction ajtrx
        INNER JOIN t_usage_interval ajui on ajui.id_interval = ajtrx.id_usage_interval
        WHERE  ajtrx.c_status = 'A'
                        and (id_sess is not null or archive_sess is not null)
        GROUP BY
          ajtrx.id_acc_payer,
          ajtrx.id_usage_interval,
          ajtrx.am_currency,
          ajtrx.c_status,
          ajui.dt_start,
          ajui.dt_end
        