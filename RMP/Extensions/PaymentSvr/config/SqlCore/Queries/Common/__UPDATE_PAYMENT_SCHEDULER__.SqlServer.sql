
update t_pv_ps_paymentscheduler
  set c_lastfourdigits = N'%%LAST_FOUR_DIGITS%%',
      c_creditcardtype = %%CREDIT_CARD_TYPE%%
  from t_pv_ps_paymentscheduler
  inner join t_enum_data as pending_enum on pending_enum.nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Pending'
  inner join t_enum_data as pending_approval_enum on pending_approval_enum.nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/PendingApproval'
  inner join t_enum_data as retry_enum on retry_enum.nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Retry'
  inner join t_enum_data as failed_enum on failed_enum.nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Failed'
  where
  (
  c_currentstatus = pending_enum.id_enum_data
  or c_currentstatus = pending_approval_enum.id_enum_data
  or c_currentstatus = retry_enum.id_enum_data
  or (c_currentstatus = failed_enum.id_enum_data and c_numberretries < c_maxretries)
  )
  and c_originalaccountid = %%ACCOUNT_ID%%
	  