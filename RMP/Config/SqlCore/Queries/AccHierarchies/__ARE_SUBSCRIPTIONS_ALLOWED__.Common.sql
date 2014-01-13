
				select 
				b_CanSubscribe as areSubscriptionsAllowed,
				b_CanparticipateInGSub as areGroupSubscriptionsAllowed
        from t_acc_template templ
        inner join t_account_type atype
        on templ.id_acc_type = atype.id_type
        where templ.id_acc_template = %%TEMPLATEID%%
					