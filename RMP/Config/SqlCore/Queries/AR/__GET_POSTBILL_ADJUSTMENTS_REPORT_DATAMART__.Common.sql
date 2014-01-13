
           SELECT
                ajs.PostbillAdjAmt AS amount,
                ajs.PostbillTaxAdjAmt AS tax_adjustment_amount,               
                ajs.PostbillFedTaxAdjAmt AS federal_tax_adjustment_amount,               
                ajs.PostbillStateTaxAdjAmt AS state_tax_adjustment_amount,               
                ajs.PostbillCntyTaxAdjAmt AS county_tax_adjustment_amount,               
                ajs.PostbillLocalTaxAdjAmt AS local_tax_adjustment_amount,               
                ajs.PostbillOtherTaxAdjAmt AS other_tax_adjustment_amount,               
	          ajs.am_currency as currency,
           NumPostbillAdjustments AS count
           FROM
            vw_adjustment_summary_datamart ajs
           WHERE
            ajs.id_acc = %%ID_ACC%%
            AND ajs.id_usage_interval = %%ID_INTERVAL%%
        