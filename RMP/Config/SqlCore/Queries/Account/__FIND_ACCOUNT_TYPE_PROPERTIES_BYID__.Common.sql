
		     select name as name, id_type as ID,
          b_CanSubscribe as cansubscribe, b_canbepayer as canbepayer, 
          b_canhavesyntheticroot as canhavesyntheticroot, 
          b_CanParticipateInGSub as canparticipateingsub,
          b_IsVisibleInHierarchy as isvisibleinhierarchy,
          b_CanHaveTemplates as canhavetemplates,
          b_IsCorporate as iscorporate,
          nm_description as description
          from t_account_type where id_type = '%%ACCOUNT_TYPE_ID%%'
			