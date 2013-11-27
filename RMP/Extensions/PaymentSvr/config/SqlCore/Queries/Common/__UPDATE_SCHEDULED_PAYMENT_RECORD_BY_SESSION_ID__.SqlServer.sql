
			UPDATE t_pv_ps_paymentscheduler set %%SET_CLAUSE%%,c_laststatusupdate =GetDate()  where
			id_sess=%%ID_SESS%%
			