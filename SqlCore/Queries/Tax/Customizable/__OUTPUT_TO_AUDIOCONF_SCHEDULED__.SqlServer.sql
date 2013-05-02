
/*__OUTPUT_TO_AUDIOCONF__*/
declare @dt_start datetime
declare @dt_end datetime

set @dt_start = %%START_DATE%%
set @dt_end = %%END_DATE%%

/* Bridge Charge */
update pv
set 
  pv.c_BridgeFederalTaxAmount = o.tax_fed_amount,
  pv.c_BridgeStateTaxAmount = o.tax_state_amount,
  pv.c_BridgeCountyTaxAmount = o.tax_county_amount,
  pv.c_BridgeLocalTaxAmount = o.tax_local_amount,
  pv.c_BridgeOtherTaxAmount = o.tax_other_amount
from t_pv_audioconfconnection pv
  inner join t_tax_input_%%ID_TAX_RUN%% r on r.id_sess = pv.id_sess and r.id_usage_interval = pv.id_usage_interval and r.charge_name = 'Bridge'
  inner join t_tax_output_%%ID_TAX_RUN%% o on r.id_tax_charge = o.id_tax_charge


/* Transport Charge */
update pv
set 
  pv.c_TransportFederalTaxAmount = o.tax_fed_amount,
  pv.c_TransportStateTaxAmount = o.tax_state_amount,
  pv.c_TransportCountyTaxAmount = o.tax_county_amount,
  pv.c_TransportLocalTaxAmount = o.tax_local_amount,
  pv.c_TransportOtherTaxAmount = o.tax_other_amount
from t_pv_audioconfconnection pv
  inner join t_tax_input_%%ID_TAX_RUN%% r on r.id_sess = pv.id_sess and r.id_usage_interval = pv.id_usage_interval and r.charge_name = 'Transport'
  inner join t_tax_output_%%ID_TAX_RUN%% o on r.id_tax_charge = o.id_tax_charge

/* Aggregate to tax fields on t_acc_usage */
update au
    set    au.tax_federal = tax_fed_amount,
           au.tax_state = tax_state_amount,
           au.tax_county = tax_county_amount,
           au.tax_local = tax_local_amount,
           au.tax_other = tax_other_amount
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

/* Rollup children records to the parent record in t_acc_usage */
    declare @nConferenceID as int;
    declare @nConnectionID as int;
    declare @nFeatureID    as int;

    select @nConferenceID = id_enum_data
    from t_enum_data
    where nm_enum_data = 'metratech.com/audioconfcall'

    select @nConnectionID = id_enum_data
    from t_enum_data
    where nm_enum_data = 'metratech.com/audioconfconnection'

    select @nFeatureID = id_enum_data
    from t_enum_data
    where nm_enum_data = 'metratech.com/AudioConfFeature'

     --print @nConferenceID;
     --print @nConnectionID;
     --print @nFeatureID;

    update au
    set
        tax_federal = ChildTaxFederal,
        tax_state = ChildTaxState,
        tax_county = ChildTaxCounty,
        tax_local = ChildTaxLocal
    from  t_acc_usage au
        inner join (
             select  id_parent_sess ConfIdSess,
                 sum(isnull(tax_federal, 0.0)) ChildTaxFederal,
                 sum(isnull(tax_state, 0.0)) ChildTaxState,
                 sum(isnull(tax_county, 0.0)) ChildTaxCounty,
                 sum(isnull(tax_local, 0.0)) ChildTaxLocal
             from t_acc_usage au
             where
                au.dt_session >= @dt_start
                and au.dt_session <@dt_end
                and id_parent_sess is not null
                and id_view in (@nConnectionID,@nFeatureID)
             group by id_parent_sess
         ) as ChildTaxes
            on ChildTaxes.ConfIdSess = au.id_sess
    where 
       au.dt_session >= @dt_start
       and au.dt_session <@dt_end
       and au.id_view = @nConferenceID


      