
        declare
  id_usage_interval int;
  id_bill_group     int;

begin
  id_usage_interval := %%ID_USAGE_INTERVAL%%;
  id_bill_group := %%ID_BILL_GROUP%%;

MERGE
INTO   T_ACC_USAGE tau --table to update
USING  (
      -- write/test an efficient query to get TAU.pk and values needed to do the update of TAU
          select  
       au.id_sess,
       au.id_usage_interval,
        tax_fed_amount,
        tax_state_amount,
        tax_county_amount,
        tax_local_amount ,
        tax_other_amount,
		'Y' as tax_calculated
        from
          ( select  i.id_sess,
                 i.id_usage_interval,
                 sum(nvl(o.tax_fed_Amount, 0.0)) tax_fed_amount,
                 sum(nvl(o.Tax_State_Amount, 0.0)) tax_state_amount,
                 sum(nvl(o.Tax_County_Amount, 0.0)) tax_county_amount,
                 sum(nvl(o.Tax_Local_Amount, 0.0)) tax_local_amount,
                 sum(nvl(o.Tax_Other_Amount, 0.0)) tax_other_amount
                    from t_tax_output_%%ID_TAX_RUN%% o
                      inner join t_tax_input_%%ID_TAX_RUN%% i on i.id_tax_charge = o.id_tax_charge
                    group by id_sess,id_usage_interval
         ) tmpTaxLevels
         inner join t_acc_usage au on au.id_sess = tmpTaxLevels.id_sess and 
                         au.id_usage_interval = tmpTaxLevels.id_usage_interval
         inner join t_billgroup_member bgm on bgm.id_acc = au.id_acc and bgm.id_billgroup = %%ID_BILL_GROUP%%
         ) tax
-- join it to TAU using TAU pk
ON  (
    tau.id_sess = tax.id_sess and 
    tau.id_usage_interval = tax.id_usage_interval
    )
-- when it joins do the update
WHEN MATCHED THEN
UPDATE
SET    
tau.tax_federal = tax.tax_fed_amount,
tau.tax_state = tax.tax_state_amount,
tau.tax_county = tax.tax_county_amount,
tau.tax_local = tax.tax_local_amount,
tau.tax_other = tax.tax_other_amount;
end;
