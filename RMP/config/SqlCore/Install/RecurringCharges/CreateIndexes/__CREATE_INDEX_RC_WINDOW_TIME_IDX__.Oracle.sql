
create index rc_window_time_idx on t_recur_window (c__payingaccount, c_PayerStart, c_PayerEnd, c_CycleEffectiveStart, c_CycleEffectiveEnd, c_MembershipStart, c_MembershipEnd, c_SubscriptionStart, c_SubscriptionEnd, c_UnitValueStart, c_UnitValueEnd)
	  