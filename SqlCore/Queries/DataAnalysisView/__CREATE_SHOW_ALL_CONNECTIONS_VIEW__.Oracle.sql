
				CREATE or replace VIEW t_vw_ShowAllConnections
				AS
				SELECT pv.c_ConferenceID, pv.c_UserBilled, pv.c_UserName,
				pv.c_UserRole, pv.c_userphonenumber, pv.c_specialinfo,
				pv.c_CallType, pv.c_transport, pv.c_Mode, pv.c_ConnectTime,
				pv.c_EnteredConferenceTime, pv.c_ExitedConferenceTime,
				pv.c_DisconnectTime, pv.c_Transferred,
				pv.c_ISDNDisconnectCause, pv.c_TrunkNumber,
				pv.c_LineNumber, pv.c_DNISDigits, pv.c_ANIDigits,
				pv.c_ConnectionMinutes, pv.c_CalendarCode,
				pv.c_CountryNameID, au.id_view ViewID,
				au.id_sess SessionID, au.amount,
				au.am_currency Currency, au.id_acc AccountID,
				au.dt_session Timestamp, 'Atomic' SessionType,
				((au.tax_federal) + (au.tax_state) + (au.tax_county) +
				(au.tax_local) + (au.tax_other)) TaxAmount,
				au.id_usage_interval IntervalID, parent.c_AccountingCode,
				parent.c_ConferenceName, parent.c_LeaderName
				FROM t_pv_audioconfconnection pv,
				t_acc_usage au, t_acc_usage parent_au,
				t_pv_audioconfcall parent
				WHERE pv.id_sess = au.id_sess
				and au.id_usage_interval=pv.id_usage_interval
				and au.id_parent_sess = parent_au.id_sess
				and parent_au.id_sess = parent.id_sess
				and parent_au.id_usage_interval = parent.id_usage_interval
			