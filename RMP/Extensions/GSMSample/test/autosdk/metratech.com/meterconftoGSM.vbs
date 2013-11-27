Option Explicit
Dim objMeter, objBatch, objSessionSet, objsession, objsession2, objsession3, objsession4

Set objMeter = CreateObject("MetraTechSDK.Meter")
objMeter.Startup
objMeter.AddServer 0, "localhost", 80, False, "", ""


Set objBatch = objMeter.CreateBatch()
objBatch.Name = "MeterToGSM"
objBatch.Namespace = "tenth"
objBatch.ExpectedCount = 1
objBatch.Source = "final"
objBatch.SequenceNumber = "1"
objBatch.SourceCreationDate  = Now()
wscript.echo "Attempting to save the batch..."

err.clear
'on error resume next
objBatch.Save()


Set objSessionSet = objBatch.CreateSessionSet()
wscript.echo "SessionSet Created, ID = " & objSessionSet.SessionSetID
  
wscript.echo "Creating Session 1"
Set objSession = objSessionSet.CreateSession("metratech.com/audioconfcall")
objSession.InitProperty "ConferenceID", "final"
objSession.InitProperty "Payer", "metratech"
objSession.InitProperty "AccountingCode", "GL99A"
objSession.InitProperty "ConferenceName", "Billing Rerun Bug 10334"
objSession.InitProperty "ConferenceSubject", "Billing Rerun Bug 10334"
objSession.InitProperty "OrganizationName", "Metratech Corp"
objSession.InitProperty "SpecialInfo", "Auto Start"
objSession.InitProperty "SchedulerComments", "No Comment"
objSession.InitProperty "ScheduledConnections", 3
objSession.InitProperty "ScheduledStartTime", "2005-10-22T23:00:00Z"
objSession.InitProperty "ScheduledtimeGMTOffset" , 5
objSession.InitProperty "ScheduledDuration", 3
objSession.InitProperty "CancelledFlag", "N"
objSession.InitProperty "CancellationTime", "2005-10-22T23:00:00Z"
objSession.InitProperty "ServiceLevel", "Standard"
objSession.InitProperty "TerminationReason", "Normal"
objSession.InitProperty "SystemName", "Bridge1"
objSession.InitProperty "SalesPersonID", "Amy"
objSession.InitProperty "OperatorID", "Philip"

wscript.echo "Creation Session 2"
Set objSession2 =objSession.CreateChildSession("metratech.com/audioConfConnection")
objSession2.InitProperty "ConferenceID", "final"
objSession2.InitProperty "Payer", "metratech"
objSession2.InitProperty "UserBilled", "N"
objSession2.InitProperty "UserName", "pkenny"
objSession2.InitProperty "UserRole", "CSR"
objSession2.InitProperty "OrganizationName", "Metratech Corp."
objSession2.InitProperty "userphonenumber", "781 398 2242"
objSession2.InitProperty "specialinfo", "Expo Update"
objSession2.InitProperty "CallType", "Dial-In"
objSession2.InitProperty "Transport", "Toll"
objSession2.InitProperty "Mode", "Direct-Dialed"
objSession2.InitProperty "ConnectTime", "2005-10-22T23:00:00Z"
objSession2.InitProperty "EnteredConferenceTime", "2005-10-22T23:00:00Z"
objSession2.InitProperty "ExitedConferenceTime", "2005-10-22T23:35:00Z"
objSession2.InitProperty "DisconnectTime", "2005-10-22T23:35:00Z"
objSession2.InitProperty "Transferred", "N"
objSession2.InitProperty "TerminationReason", "Normal"
objSession2.InitProperty "ISDNDisconnectCause", 0
objSession2.InitProperty "TrunkNumber", 10
objSession2.InitProperty "LineNumber", 35
objSession2.InitProperty "DNISDigits", "781 398 2000"
objSession2.InitProperty "ANIDigits", "781 398 2000"


wscript.echo "Creation Session 3"
Set objSession3 =objSession.CreateChildSession("metratech.com/audioConfConnection")
objSession3.InitProperty "ConferenceID", "final"
objSession3.InitProperty "Payer", "metratech"
objSession3.InitProperty "UserBilled", "N"
objSession3.InitProperty "UserName", "pkenny"
objSession3.InitProperty "UserRole", "CSR"
objSession3.InitProperty "OrganizationName", "Metratech Corp."
objSession3.InitProperty "userphonenumber", "781 398 2242"
objSession3.InitProperty "specialinfo", "Expo Update"
objSession3.InitProperty "CallType", "Dial-In"
objSession3.InitProperty "Transport", "Toll"
objSession3.InitProperty "Mode", "Direct-Dialed"
objSession3.InitProperty "ConnectTime", "2005-10-22T23:00:00Z"
objSession3.InitProperty "EnteredConferenceTime", "2005-10-22T23:00:00Z"
objSession3.InitProperty "ExitedConferenceTime", "2005-10-22T23:35:00Z"
objSession3.InitProperty "DisconnectTime", "2005-10-22T23:35:00Z"
objSession3.InitProperty "Transferred", "N"
objSession3.InitProperty "TerminationReason", "Normal"
objSession3.InitProperty "ISDNDisconnectCause", 0
objSession3.InitProperty "TrunkNumber", 10
objSession3.InitProperty "LineNumber", 35
objSession3.InitProperty "DNISDigits", "781 398 2000"
objSession3.InitProperty "ANIDigits", "781 398 2000"

wscript.echo "Creation Session 4"
Set objSession4 =objSession.CreateChildSession("metratech.com/audioConfConnection")
objSession4.InitProperty "ConferenceID", "final"
objSession4.InitProperty "Payer", "metratech"
objSession4.InitProperty "UserBilled", "N"
objSession4.InitProperty "UserName", "pkenny"
objSession4.InitProperty "UserRole", "CSR"
objSession4.InitProperty "OrganizationName", "Metratech Corp."
objSession4.InitProperty "userphonenumber", "781 398 2242"
objSession4.InitProperty "specialinfo", "Expo Update"
objSession4.InitProperty "CallType", "Dial-In"
objSession4.InitProperty "Transport", "Toll"
objSession4.InitProperty "Mode", "Direct-Dialed"
objSession4.InitProperty "ConnectTime", "2005-10-22T23:00:00Z"
objSession4.InitProperty "EnteredConferenceTime", "2005-10-22T23:00:00Z"
objSession4.InitProperty "ExitedConferenceTime", "2005-10-22T23:35:00Z"
objSession4.InitProperty "DisconnectTime", "2005-10-22T23:35:00Z"
objSession4.InitProperty "Transferred", "N"
objSession4.InitProperty "TerminationReason", "Normal"
objSession4.InitProperty "ISDNDisconnectCause", 0
objSession4.InitProperty "TrunkNumber", 10
objSession4.InitProperty "LineNumber", 35
objSession4.InitProperty "DNISDigits", "781 398 2000"
objSession4.InitProperty "ANIDigits", "781 398 2000"


objSessionSet.Close()

wscript.echo "Metered Count = <" & objBatch.MeteredCount & ">" 

objMeter.ShutDown