
/*__OUTPUT_TO_BUYCOOKIES__*/

declare @id_usage_interval int
declare @id_bill_group int;
set @id_usage_interval = %%ID_USAGE_INTERVAL%%
set @id_bill_group = %%ID_BILL_GROUP%%

/* Aggregate to tax fields on t_acc_usage */
update au
    set    au.tax_federal = tax_fed_amount,
           au.tax_state = tax_state_amount,
           au.tax_county = tax_county_amount,
           au.tax_local = tax_local_amount,
           au.tax_other = tax_other_amount,
		   au.tax_calculated = 'Y'
    from
        ( select  i.id_sess,
                  i.id_usage_interval,
                  sum(isnull(o.tax_fed_Amount, 0.0)) tax_fed_amount,
                  sum(isnull(o.Tax_State_Amount, 0.0)) tax_state_amount,
                  sum(isnull(o.Tax_County_Amount, 0.0)) tax_county_amount,
                  sum(isnull(o.Tax_Local_Amount, 0.0)) tax_local_amount,
                  sum(isnull(o.Tax_Other_Amount, 0.0)) tax_other_amount
          from t_tax_output_%%ID_TAX_RUN%% o
             inner join t_tax_input_%%ID_TAX_RUN%% i on i.id_tax_charge = o.id_tax_charge
          group by id_sess,id_usage_interval
        ) tmpTaxLevels
    inner join t_acc_usage au on au.id_sess = tmpTaxLevels.id_sess and au.id_usage_interval = tmpTaxLevels.id_usage_interval
    inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = @id_bill_group
 
      