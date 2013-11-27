
        select
          au.am_currency as am_currency,
	        substring(cast(ed.nm_enum_data as VARCHAR(255)), LEN(cast(ed.nm_enum_data as VARCHAR(255))) -2, 3) as div_currency
        from
	        t_acc_usage au 
          inner join
          t_av_internal avInternal on au.id_acc = avInternal.id_acc
	        join
	        t_be_cor_cor_division div on avInternal.c_Division = div.c_Name
	        join
	        t_enum_data ed on div.c_currency = ed.id_enum_data
        where 
	        au.id_sess = @sessionId;
			