
		     select id_type as id, name as name,
          b_CanSubscribe as cansubscribe, b_canbepayer as canbepayer, 
          b_canhavesyntheticroot as canhavesyntheticroot, 
          b_CanParticipateInGSub as canparticipateingsub,
          b_IsVisibleInHierarchy as isvisibleinhierarchy,
          b_CanHaveTemplates as canhavetemplates,
          b_IsCorporate as iscorporate,
          nm_description as description
          from t_account_type
			