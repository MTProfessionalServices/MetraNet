<!-- #INCLUDE FILE="../../auth.asp" --> 
<HTML>
 <HEAD>
  <LINK rel="STYLESHEET" type="text/css" href="/mom/default/localized/en-us/styles/Styles.css">  
 </HEAD>

<BODY>

<FORM name="mdm">

<!-- Title Bar -->
<TABLE BORDER="0"  CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
 <TR>
  <TD Class="CaptionBar" nowrap>Usage Server Maintenance</TD>
 </TR>
</TABLE>
<BR>
<%

dim objUSM

set objUSM = CreateObject("Metratech.MTUsageServerMaintenance")

dim sAction
sAction=session("USM_MANUAL_OPERATION_ManualAction")

dim iRunEventValue 
'From the MTUsageServer.idl file  
'EVENT_PERIOD_SOFT_CLOSE = 1,
'EVENT_PERIOD_HARD_CLOSE = 2,
'EVENT_PERIOD_ALL = 3,

if UCASE(sAction)="RUN" then

  if UCASE(session("USM_MANUAL_OPERATION_RunSoftClose"))="TRUE" Then
    if UCASE(session("USM_MANUAL_OPERATION_RunHardClose"))="TRUE" Then
      iRunEventValue = 3
    else
      iRunEventValue = 1
    end if
  else
    if UCASE(session("USM_MANUAL_OPERATION_RunHardClose"))="TRUE" Then
      iRunEventValue = 2
    else
      iRunEventValue = 0
    end if
  end if
  
  if iRunEventValue > 0 then
    response.write("Usage Server Maintenance: RUN...")
    response.flush
    if iRunEventValue=3 then
      '// Run all of them
      objUSM.RunRecurringEvents
    else
      objUSM.RunSpecificRecurringEvent iRunEventValue
    end if
    response.write("Done")
    response.flush
  else
    response.write("Both 'Run' operations were unselected: No Action taken.")
  end if
else
  if UCASE(sAction)="CLOSE" then
    dim iOpenGracePeriod
    dim iSoftClosedGracePeriod
    dim bDoCloseOperation
    bDoCloseOperation = false  '// We use this to determine if the user has unselected both parts of the operation
    
    if UCASE(session("USM_MANUAL_OPERATION_CloseOpen"))="TRUE" then
      iOpenGracePeriod=0
      bDoCloseOperation = true
    else
      iOpenGracePeriod=-1  '// -1 means we won't run this part of the operation
    end if
    if UCASE(session("USM_MANUAL_OPERATION_CloseSoftClosed"))="TRUE" then
      iSoftClosedGracePeriod=0
      bDoCloseOperation = true
    else
      iSoftClosedGracePeriod=-1  '// -1 means we won't run this part of the operation
    end if
    
    '// Now determine what date to use
    dim ExpirationDate
    if bDoCloseOperation then
      if session("USM_MANUAL_OPERATION_ExpirationDateType")="Now" then
        ExpirationDate=Now() ' RUDI
      else
        ExpirationDate= CDate(session("USM_MANUAL_OPERATION_CloseExpirationDate"))
      end if
      
      
      response.write("Usage Server Maintenance: CLOSE...")
      response.flush
      objUSM.CloseIntervals ExpirationDate, iOpenGracePeriod, iSoftClosedGracePeriod
      response.flush
      response.write("Done")
    else
      response.write("Both 'Close' operations were unselected: No Action taken.")
    end if
  else
    response.write("Unknown Action: No Action taken.")
  end if
end if


%>
</form>
<center>
<button OnClick="window.location='DefaultDialogUSMManual.asp';" name="ok" Class="clsOkButton">OK</button>

</center>
</body>
</html>
