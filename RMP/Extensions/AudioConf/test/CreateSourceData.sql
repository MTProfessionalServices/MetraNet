create table MT_TestService(
	c_description nvarchar(80) NOT NULL,
	c_time DateTime NOT NULL,
	c_units DECIMAL NOT NULL,
	c_accountname nvarchar(20) NOT NULL,
	c_DecProp1 DECIMAL,
	c_DecProp2 DECIMAL,
	c_DecProp3 DECIMAL
)

insert into MT_testservice values('testing...2', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...1', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...3', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...4', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...5', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...6', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...7', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...8', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...9', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)
insert into MT_testservice values('testing...10', '2004-06-01 00:00:00.000', 10, 'demo', NULL, NULL, NULL)


CREATE TABLE [MT_audioconfcall] (
	[c_ConferenceID] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_Payer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_AccountingCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[c_ConferenceName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_ConferenceSubject] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[c_OrganizationName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_SpecialInfo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_SchedulerComments] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_ScheduledConnections] [int] NOT NULL ,
	[c_ScheduledStartTime] [datetime] NOT NULL ,
	[c_ScheduledTimeGMTOffset] [numeric](22,10) NOT NULL ,
	[c_ScheduledDuration] [int] NOT NULL ,
	[c_CancelledFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_CancellationTime] [datetime] NOT NULL ,
	[c_ServiceLevel] int,
	[ctext_ServiceLevel] nvarchar(30) NOT NULL,
	[c_TerminationReason] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_SystemName] [nvarchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_SalesPersonID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[c_OperatorID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [MT_audioconfconnection] (
	[c_ConferenceID] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_Payer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[c_UserBilled] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_UserName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[c_UserRole] int ,
	[ctext_UserRole] nvarchar(30) NOT NULL,
	[c_OrganizationName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_userphonenumber] [nvarchar] (38) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_specialinfo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_CallType] int,
	[ctext_CallType] nvarchar(30) NOT NULL,
	[c_transport] int,
	[ctext_transport] nvarchar(30) NOT NULL,
	[c_Mode] int,
	[ctext_Mode] nvarchar(30) NOT NULL,
	[c_ConnectTime] [datetime] NOT NULL ,
	[c_EnteredConferenceTime] [datetime] NOT NULL ,
	[c_ExitedConferenceTime] [datetime] NOT NULL ,
	[c_DisconnectTime] [datetime] NOT NULL ,
	[c_Transferred] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_TerminationReason] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_ISDNDisconnectCause] [int] NOT NULL ,
	[c_TrunkNumber] [int] NOT NULL ,
	[c_LineNumber] [int] NOT NULL ,
	[c_DNISDigits] [nvarchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[c_ANIDigits] [nvarchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

-- create calls

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13100', 'Pam', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  4 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13155', 'Kevin', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  5 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Automated')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13158', 'DavidB', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  4 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13106', 'Finance', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  5 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Standard')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13108', 'WSG', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  3 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Standard')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13111', 'MetraTech', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  2, '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Executive')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13113', 'Engineering', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  7 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13119', 'Scott', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  2 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13122', 'Development', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  8 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Automated')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13124', 'MetraTech', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  2 , '2004-10-06 11:01:46.700', 5, 3, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13126', 'Meredith', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  6 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Standard')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13128', 'Kevin', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  9 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13131', 'HR', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  4 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Standard')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13134', 'UI', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  9 , '2004-10-06 11:01:46.700', 5, 3, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13137', 'Engineering', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  7 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13139', 'Jill', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  2 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Executive')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13142', 'Meredith', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  5 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13145', 'Kevin', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  5 , '2004-10-06 11:01:46.700', 5, 3, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13147', 'DavidB', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  3 , '2004-10-06 11:01:46.700', 5, 2, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Standard')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13150', 'Jill', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  3 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

insert into MT_audioconfcall(c_ConferenceID, c_Payer, c_accountingCode, c_ConferenceName, c_ConferenceSubject, c_OrganizationName, c_SpecialInfo, c_SchedulerComments, c_ScheduledConnections, c_ScheduledStartTime, c_ScheduledTimeGMTOffset, c_ScheduledDuration, c_CancelledFlag, c_CancellationTime, c_TerminationReason, c_SystemName, c_SalesPersonID, c_OperatorID, ctext_ServiceLevel)
 values('13152', 'Jill', 'GL123', 'NoName', 'None', 'Metratech', 'none', 'mpme',  2 , '2004-10-06 11:01:46.700', 5, 1, 'N', '2004-10-06 11:02:12.357', 'No Reason', 'Bridge1', NULL, NULL, 'Basic')

--set the service level enum value
update mt_audioconfcall
set c_servicelevel = ed.id_enum_data
from netmeter..t_enum_data ed
inner join netmeter..t_description d
on ed.id_enum_data = d.id_desc
inner join mt_audioconfcall source
on source.ctext_servicelevel = d.tx_desc
where d.id_lang_code = 840
and ed.nm_enum_data like '%ServiceLevel%'



--create connections

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13100', 'Pam', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13100', 'Pam', 'N', 'Plugins.GetUsername', 'Moderator', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13119', 'Scott', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13122', 'Development', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '7813291197', 'None', 'Dial-In', 'Toll', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13124', 'MetraTech', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13126', 'Meredith', 'N', 'Plugins.GetUsername', 'Chair', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13128', 'Kevin', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '6176803222', 'None', 'Dial-In', 'Domestic', 'Collect', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13128', 'Kevin', 'N', 'Plugins.GetUsername', 'CSR', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Direct-Dial', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13131', 'HR', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '7813291197', 'None', 'Dial-Out', 'Toll', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13131', 'HR', 'N', 'Plugins.GetUsername', 'Operator', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Direct-Dial', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13134', 'UI', 'N', 'Plugins.GetUsername', 'Moderator', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13134', 'UI', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '6176803222', 'None', 'Dial-In', 'Toll', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13137', 'Engineering', 'N', 'Plugins.GetUsername', 'Moderator', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Domestic', 'Unattended', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13139', 'Jill', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '7813291197', 'None', 'Dial-Out', 'Toll', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13139', 'Jill', 'N', 'Plugins.GetUsername', 'Moderator', 'Metratech', '7813291197', 'None', 'Dial-Out', 'Domestic', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13142', 'Meredith', 'N', 'Plugins.GetUsername', 'Presenter', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Unattended', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13142', 'Meredith', 'N', 'Plugins.GetUsername', 'Chair', 'Metratech', '6176803222', 'None', 'Dial-In', 'Domestic', 'Direct-Dial', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13145', 'Kevin', 'N', 'Plugins.GetUsername', 'CSR', 'Metratech', '7813291197', 'None', 'Dial-In', 'Toll', 'Collect', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13147', 'DavidB', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13147', 'DavidB', 'N', 'Plugins.GetUsername', 'Presenter', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13150', 'Jill', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13152', 'Jill', 'N', 'Plugins.GetUsername', 'Operator', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13152', 'Jill', 'N', 'Plugins.GetUsername', 'Chair', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13155', 'Kevin', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '7813291197', 'None', 'Dial-In', 'Toll', 'Unattended', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13155', 'Kevin', 'N', 'Plugins.GetUsername', 'Presenter', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13158', 'DavidB', 'N', 'Plugins.GetUsername', 'CSR', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13106', 'Finance', 'N', 'Plugins.GetUsername', 'CSR', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Domestic', 'Direct-Dial', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13108', 'WSG', 'N', 'Plugins.GetUsername', 'Presenter', 'Metratech', '6176803222', 'None', 'Dial-In', 'Toll', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13108', 'WSG', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '7813291197', 'None', 'Dial-In', 'Domestic', 'Originator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13111', 'Metratech', 'N', 'Plugins.GetUsername', 'Participant', 'Metratech', '6176803222', 'None', 'Dial-Out', 'Toll', 'Collect', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13113', 'Engineering', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '7813291197', 'None', 'Dial-Out', 'Domestic', 'Passcode', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')

insert into MT_audioconfconnection (c_ConferenceID, c_Payer, c_UserBilled, c_UserName, ctext_UserRole, c_organizationName, c_userphonenumber, c_specialinfo, ctext_callType, ctext_transport, ctext_mode, c_ConnectTime, c_enteredConferenceTime, c_ExitedConferenceTime, c_DisconnectTime, c_transferred, c_TerminationReason, c_ISDNDisconnectCause, c_TrunkNumber, c_lineNumber, c_DNISDigits, c_ANIDigits)
values ('13113', 'Engineering', 'N', 'Plugins.GetUsername', 'Translator', 'Metratech', '6176803222', 'None', 'Dial-In', 'Domestic', 'Operator', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', '2004-09-26 15:04:41.297', 'N', 'None', 0, 10, 35, '781 398 2000', '781 398 2242')


-- update the enum type values for mode, userrole, transport and calltype

update mt_audioconfconnection
set c_CallType = ed.id_enum_data
from netmeter..t_enum_data ed
inner join netmeter..t_description d
on ed.id_enum_data = d.id_desc
inner join mt_audioconfconnection source
on source.ctext_calltype = d.tx_desc
where d.id_lang_code = 840
and ed.nm_enum_data like '%CallType%'


update mt_audioconfconnection
set c_Mode = ed.id_enum_data
from netmeter..t_enum_data ed
inner join netmeter..t_description d
on ed.id_enum_data = d.id_desc
inner join mt_audioconfconnection source
on source.ctext_Mode = d.tx_desc
where d.id_lang_code = 840
and ed.nm_enum_data like '%Mode%'


update mt_audioconfconnection
set c_Transport = ed.id_enum_data
from netmeter..t_enum_data ed
inner join netmeter..t_description d
on ed.id_enum_data = d.id_desc
inner join mt_audioconfconnection source
on source.ctext_transport = d.tx_desc
where d.id_lang_code = 840
and ed.nm_enum_data like '%Transport%'


update mt_audioconfconnection
set c_UserRole = ed.id_enum_data
from netmeter..t_enum_data ed
inner join netmeter..t_description d
on ed.id_enum_data = d.id_desc
inner join mt_audioconfconnection source
on source.ctext_userrole = d.tx_desc
where d.id_lang_code = 840
and ed.nm_enum_data like '%audioconfconnection/userrole/%'

-- set current times for starttime, cancellation time, connectime etc

update mt_audioconfcall 
set c_scheduledstarttime = getdate()

update mt_audioconfcall 
set c_cancellationtime = getdate()

update mt_audioconfconnection
set c_connecttime = getdate()

update mt_audioconfconnection
set c_enteredconferencetime = getdate()

update mt_audioconfconnection
set c_exitedconferencetime = getdate()+1.1

update mt_audioconfconnection
set c_disconnecttime = getdate()+1.1
