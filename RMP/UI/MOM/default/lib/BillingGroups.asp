<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
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
' NAME          : BillingGroups.Asp 
' VERSION       : Kona
' CREATION_DATE : 06/08/2005
' AUTHOR        : Kevin A. Boucher
' DESCRIPTION   : MetratTech Billing Groups UI Helper Class
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Class CBillingGroup
  Public Name
  Public Description
  Public BillingGroupID
  Public IntervalID
  Public State
  Public Accounts
  Public Adapters
  Public Succeeded
  Public Failed
  Public OriginalGroup
End Class

Dim BillingGroups
Set BillingGroups = New CBillingGroups   ' Allocate the BillingGroups instance
    
CLASS CBillingGroups 
            
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : GetBillingGroupsRS
	    ' PARAMETERS  : IntervalID
	    ' DESCRIPTION : Returns the Billing Groups rowset for the initialized interval
	    ' RETURNS     :      
      PUBLIC FUNCTION GetBillingGroupsRS(intervalID)
       Dim rowset
       Set rowset = ExecuteSQL("Select * from t_billing_groups where id_interval=" & intervalID) 
      
        If(Not IsValidObject(rowset)) Then
          If rowset.RecordCount > 0 Then
            rowset.MoveFirst
          End If  
        End If  
        Set GetBillingGroupsRS = rowset
      END FUNCTION

	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : MaterializeGroups
	    ' PARAMETERS  : IntervalID
	    ' DESCRIPTION : Creates the billing groups for the interval
	    ' RETURNS     :          
      PUBLIC FUNCTION MaterializeGroups(intervalID)
        Dim sql

        sql = "delete from t_billing_groups where id_interval=" & intervalID
        Call ExecuteSQL(sql)
        
        sql = "insert into t_billing_groups Values(111, 'North America', 'The North America Billing Group.', " & intervalID & ", 'Soft Closed', 160445, 20, 0, 0, 'North America')"
        Call ExecuteSQL(sql)
        
        sql = "insert into t_billing_groups Values(222, 'Hong Kong', 'The Hong Kong Billing Group.', " & intervalID & ", 'Soft Closed', 67984, 20, 0, 0, NULL)"
        Call ExecuteSQL(sql)
        
        sql = "insert into t_billing_groups Values(999, 'Default Billing Group', 'This group contains all accounts not associated with another Billing Group.', " & intervalID & ", 'Open', 554, 20, 0, 0, NULL)"
        Call ExecuteSQL(sql)

      END FUNCTION

	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : GetBillingGroupRS
	    ' PARAMETERS  : intervalID, billingGroupID
	    ' DESCRIPTION : Gets the billing group for the interval and billing group id
	    ' RETURNS     :          
      PUBLIC FUNCTION GetBillingGroupRS(intervalID, billingGroupID)
       Dim rowset
       Set rowset = ExecuteSQL("Select * from t_billing_groups where id_interval=" & intervalID & " and id_billing_group=" & billingGroupID) 
      
        If(Not IsValidObject(rowset)) Then
          If rowset.RecordCount > 0 Then
            rowset.MoveFirst
          End If  
        End If  
        Set GetBillingGroupRS = rowset

      END FUNCTION
                 
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Default Initialize
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Initialize() ' As Boolean
        

	    END SUB
      
	    ' ---------------------------------------------------------------------------------------------------------------------------------------
	    ' FUNCTION    : Default Terminate
	    ' PARAMETERS  :
	    ' DESCRIPTION :
	    ' RETURNS     :
	    PRIVATE SUB Class_Terminate() ' As Boolean
        Set mGroups = Nothing
        Set mGroupsRS = Nothing
	    END SUB		  
	
END CLASS    	

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : ExecuteSQL
' PARAMETERS  : strSQL
' DESCRIPTION : Run SQL statement
' RETURNS     : Rowset
PUBLIC FUNCTION ExecuteSQL(strSQL)
  Dim objRowSet
  
  On Error Resume Next
  
  Set objRowSet = Nothing
  Set objRowSet = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  
  objRowSet.init("queries\audit") 'dummy
  objRowSet.SetQueryString(strSQL)
  objRowSet.Execute()

  On Error Goto 0
  
  Set ExecuteSQL = objRowSet
END FUNCTION
  
%>