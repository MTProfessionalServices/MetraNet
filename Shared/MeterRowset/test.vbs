
Option explicit

Const MTC_DT_WCHAR = 0
Const MTC_DT_CHAR = 1
Const MTC_DT_INT = 2
Const MTC_DT_FLOAT = 3
Const MTC_DT_DOUBLE = 4
Const MTC_DT_TIME = 5
Const MTC_DT_BOOL = 6
Const MTC_DT_DECIMAL = 7

'meter.AddColumnMapping "counter1", MTC_DT_DECIMAL, "TotalMinutes", True
'meter.AddColumnMapping "counter2", MTC_DT_DECIMAL, "TotalPages", true
'meter.AddCommonProperty "piid", MTC_DT_INT, CInt(12346)
'meter.AddCommonProperty "caption", MTC_DT_INT, "a simple test"

Dim parentQuery
parentQuery = "select ac.id_sess, ac.tx_UID, ac.id_acc, ac.id_usage_interval, ac.id_parent_sess, ac.dt_session, ac.amount, ac.am_currency, ac.tx_batch, ac.dt_crt, pv.c_ConferenceID, pv.c_Payer, pv.c_AccountingCode, pv.c_ConferenceName, pv.c_ConferenceSubject, pv.c_OrganizationName, pv.c_SpecialInfo, pv.c_SchedulerComments, pv.c_ScheduledConnections, pv.c_ScheduledStartTime, pv.c_ScheduledTimeGMTOffset, pv.c_ScheduledDuration, pv.c_CancelledFlag, pv.c_CancellationTime, 3 as c_ServiceLevel, pv.c_TerminationReason, pv.c_SystemName, pv.c_SalesPersonID, pv.c_OperatorID, pv.c_ActualNumConnections, pv.c_ActualStartTime, pv.c_ActualDuration, pv.c_ConferenceEndTime, pv.c_ConferenceTotal, pv.c_LeaderName, pv.c_ReservationCharges, pv.c_UnusedPortCharges, pv.c_ConnectionTotalAmount, pv.c_AdjustmentAmount, pv.c_OverusedPortCharges from t_pv_audioconfcall pv join t_acc_usage ac on ac.id_sess = pv.id_sess"

Dim childQuery
childQuery = "select ac.id_sess, ac.tx_UID, ac.id_acc, ac.id_usage_interval, ac.id_parent_sess, ac.dt_session, ac.amount, ac.am_currency, ac.tx_batch, ac.dt_crt, pv.c_ConferenceID, pv.c_Payer, pv.c_UserBilled, pv.c_UserName, 'Participant' as c_UserRole, pv.c_OrganizationName, pv.c_userphonenumber, pv.c_specialinfo, 'Dial-In' as c_CallType, 'Toll-Free' as c_transport, 'Unattended' as c_Mode, pv.c_ConnectTime, pv.c_EnteredConferenceTime, pv.c_ExitedConferenceTime, pv.c_DisconnectTime, pv.c_Transferred, pv.c_TerminationReason, pv.c_ISDNDisconnectCause, pv.c_TrunkNumber, pv.c_LineNumber, pv.c_DNISDigits, pv.c_ANIDigits, pv.c_ConnectionMinutes, pv.c_CalendarCode, pv.c_CountryNameID from t_pv_audioconfconnection pv join t_acc_usage ac on ac.id_sess = pv.id_sess order by id_parent_sess"


Dim childRowset
set childRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
childRowset.Init "queries\ProductCatalog"
childRowset.SetQueryString childQuery
childRowset.Execute

Dim parentRowset
set parentRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
parentRowset.Init "queries\ProductCatalog"
parentRowset.SetQueryString parentQuery
parentRowset.Execute

Dim meter
set meter = CreateObject("MetraTech.MeterRowset")
meter.InitSDK "AggregateRatingServer"
meter.InitForService "metratech.com/audioconfcall"
meter.AddChildRowset childRowset, "metratech.com/audioconfconnection"
meter.MeterRowset parentRowset
