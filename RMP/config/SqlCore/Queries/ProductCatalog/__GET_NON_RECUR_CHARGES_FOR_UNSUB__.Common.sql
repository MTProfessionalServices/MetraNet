
select 
/* __GET_NON_RECUR_CHARGES_FOR_UNSUB__ */
gsm.n_event_type as c_NRCEventType,
%%DT_START%% as c_NRCIntervalStart,
%%DT_END%% as c_NRCIntervalEnd,
gsm.id_acc as c__AccountID,
gsm.vt_start as c_NRCIntervalSubscriptionStart,
gsm.vt_end as c_NRCIntervalSubscriptionEnd,
gsm.id_pi_instance as c__PriceableItemInstanceID, 
gsm.id_pi_template as c__PriceableItemTemplateID,
gsm.id_po as c__ProductOfferingID,
gsm.id_sub as c__SubscriptionID
from 
%%%TEMP_TABLE_PREFIX%%%tmp_nrcs gsm 
where
gsm.n_event_type=2
and
gsm.max_vt_tt_end >= %%DT_START%% 
and
gsm.max_vt_tt_end <= %%DT_END%%
and
%%DT_END%% >= gsm.tt_start 
and
%%DT_END%% <= gsm.tt_end
and
not exists (
	select * from 
	%%%TEMP_TABLE_PREFIX%%%tmp_nrcs gsm2 
	where
	gsm2.id_prop=gsm.id_prop
	and
	gsm.id_po = gsm2.id_po
	and
	gsm.id_acc = gsm2.id_acc
	and
	gsm.id_sub = gsm2.id_sub
	and
	gsm.position = gsm2.position
	and
	gsm2.n_event_type=2
	and
	gsm2.max_vt_tt_end < %%DT_START%% 		
	and
	%%DT_START%% > gsm2.tt_start
	and
	/* If a charge was previously billed, then it must have been true when billed */
	/* that tt_end > @dt_end > dbo.MTMaxOfTwoDates(tt_start, vt_start). */
	/* Granted, tt_end can be decrease as a fact is invalidated.  However, if we */
	/* assume that the adapter is NOT run in the future, then we conclude that */
	/* any subsequent tt_end will also be > @dt_end for the scheduled interval in */
	/* which the charge was billed; thus even now we know tt_end > dbo.MTMaxOfTwoDates(tt_start, vt_start). */
	gsm2.dt_arg_end < gsm2.tt_end
)
			