<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998-2003 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME		        : 
' VERSION	        : 1.0
' CREATION_DATE   : 
' AUTHOR	        : Rudi
' DESCRIPTION	    : Contains shared functions for interval management
'               
' ----------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetBillingGroupStateIcon
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION GetBillingGroupStateIcon(strState)
    Dim strImage
    
    Select Case strState
      Case BillingGroupStatus_Open
        strImage= "../localized/en-us/images/intervals/IntervalStateOpen.gif"
      Case BillingGroupStatus_SoftClosed
        strImage= "../localized/en-us/images/intervals/IntervalStateSoftClosed.gif"
      Case BillingGroupStatus_HardClosed
        strImage= "../localized/en-us/images/intervals/IntervalStateHardClosed.gif"
      Case Else
        strImage= "../localized/en-us/images/intervals/Interval.gif"
    End Select
    
    GetBillingGroupStateIcon = strImage           
END FUNCTION

FUNCTION GetBillingGroupCycleType(strType)
  Dim cycle
  
  Select Case strType
    Case CycleType_Monthly
      cycle = "Monthly"
    Case CycleType_Daily
      cycle = "Daily"
    Case CycleType_Weekly
      cycle = "Weekly"
    Case CycleType_BiWeekly
      cycle = "BiWeekly"
    Case CycleType_Quarterly
      cycle = "Quarterly"
    Case CycleType_SemiAnnual
	  cycle = "Semi-Annually"
    Case CycleType_Annual
      cycle = "Annual"
    Case CycleType_All
      cycle = "All"

    Case Else
      cycle = "(unknown cycle type)"
  End Select  
  
  GetBillingGroupCycleType = cycle  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetIntervalStateIcon
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
FUNCTION GetIntervalStateIcon(strState)
    dim strImage
    Select Case strState
            Case "New"
              strImage= "../localized/en-us/images/intervals/IntervalState0.gif"
              'iState=0
            Case "Open"
              strImage= "../localized/en-us/images/intervals/IntervalStateOpen.gif"
              'iState=1
            Case "Soft Close Pending"
              strImage= "../localized/en-us/images/intervals/IntervalState2.gif"
              'iState=2
            Case "Soft Closed"
              strImage= "../localized/en-us/images/intervals/IntervalStateSoftClosed.gif"
              'iState=3
            Case "Hard Close Pending"
              strImage= "../localized/en-us/images/intervals/IntervalState4.gif"
              'iState=4
            Case "Hard Closed"
              strImage= "../localized/en-us/images/intervals/IntervalStateHardClosed.gif"
              'iState=5
            Case Else
              strImage= "../localized/en-us/images/intervals/Interval.gif"
              'iState=-1
    End Select
    
    GetIntervalStateIcon = strImage           
END FUNCTION




%>