VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAdminConfigSetHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------


'----------------------------------------------------------------------------
'*****
'***** DESCRIPTION: This class is used to do work with configuration sets
'*****
'***** ASSUMPTIONS:
'*****
'***** CALLS (REQUIRES): Propset
'*****
'----------------------------------------------------------------------------
Option Explicit



'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
Private Const mkstrReferenceSetName = "MTShared"



'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
' none



'----------------------------------------------------------------------------
' METHODS - INITIALIZE & TERMINATE
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: Class_Initialize
'   Description:  Read the registry to get the config path
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
Private Sub Class_Initialize()
    Call setConfigDir
End Sub



'----------------------------------------------------------------------------
' METHODS - PUBLIC
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: getRepositoryConfigSets
'   Description:  returns the MTConfigSetList that is the list of configuration
'                   sets with the local working area
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Function getRepositoryConfigSets(ByVal icstrUserName As String, _
'                                    ByVal icstrPassword As String, _
'                                    Optional ByVal icbolGetAll As Boolean = False) As MTConfigSetList
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As MTConMan
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Set getRepositoryConfigSets = Nothing
'        Exit Function
'    End If
'
'    Call objConfigMan.SetIncludeAllSetFlag(icbolGetAll)
'
'    Set getRepositoryConfigSets = objConfigMan.GetRepositoryConfigSetList
'    Set objConfigMan = Nothing
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set getRepositoryConfigSets = Nothing
'    Call Err.Raise("-1", , "Error occurred while getting the config sets: " & Err.Description)
'End Function
'
'
'


'----------------------------------------------------------------------------
'   Name: checkInSet
'   Description:  Checks in a configuration set based on the name and version
'                   supplied.
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'               icstrSetName - the name of the config set to check in
'               icintSetVersion - the version of the config set to check in
'               icstrComments - the comments for the check in
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Sub checkInSet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String, _
'                        ByVal icstrSetName As String, _
'                        ByVal icintSetVersion As Integer, _
'                        ByVal icstrComments As String)
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As MTConMan
'    Dim objConManApp        As MTConManApplication
'    Dim objConfigSetRev     As MTConfigSetRevision
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Sub
'    End If
'
'
'    '-----------------------------------------------------------
'    ' Create the config set revision, then perform the action
'    '-----------------------------------------------------------
'    Set objConfigSetRev = New MTConfigSetRevision
'    Call objConfigSetRev.AddRevision(icstrSetName, CStr(icintSetVersion), icstrUserName, Now, icstrComments)
'    objConfigSetRev.ConfigSetOwner = objConfigMan.GetConfigSetOwner(icstrSetName)
'
'    Set objConManApp = New MTConManApplication
'    objConManApp.WorkingAreaHostname = "localhost"
'    objConManApp.ConfigSetRevision = objConfigSetRev
'
'    Call objConfigMan.CheckInConfig(objConfigSetRev)
'
'    Set objConfigMan = Nothing
'    Set objConfigSetRev = Nothing
'    Set objConManApp = Nothing
'    Exit Sub
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set objConfigSetRev = Nothing
'    Set objConManApp = Nothing
'    Call Err.Raise("-1", , "Error occurred while checking in the config set: " & Err.Description)
'End Sub
'


'----------------------------------------------------------------------------
'   Name: checkInRefSet
'   Description:  Checks in the latest reference configuration set.
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Sub checkInRefSet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String, _
'                        ByVal icstrComments As String)
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As MTConMan
'    Dim intVersion          As Integer
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Sub
'    End If
'
'    intVersion = CInt(objConfigMan.GetWorkingAreaConfigSetVersion(mkstrReferenceSetName))
'    Set objConfigMan = Nothing
'
'    Call checkInSet(icstrUserName, icstrPassword, mkstrReferenceSetName, intVersion, icstrComments)
'    Exit Sub
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Call Err.Raise("-1", , "Error occurred while checking out the config set: " & Err.Description)
'End Sub




'----------------------------------------------------------------------------
'   Name: checkOutSet
'   Description:  Checks out a configuration set based on the name and version
'                   supplied.
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'               icstrSetName - the name of the config set to check out
'               icintSetVersion - the version of the config set to check out
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Sub checkOutSet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String, _
'                        ByVal icstrSetName As String, _
'                        ByVal icintSetVersion As Integer)
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As MTConMan
'    Dim objConfigSetRev     As MTConfigSetRevision
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Sub
'    End If
'
'
'    '-----------------------------------------------------------
'    ' Create the config set revision, then perform the action
'    '-----------------------------------------------------------
'    Set objConfigSetRev = New MTConfigSetRevision
'    Call objConfigSetRev.AddRevision(icstrSetName, CStr(icintSetVersion), icstrUserName, Now, "")
'    objConfigSetRev.ConfigSetOwner = objConfigMan.GetConfigSetOwner(icstrSetName)
'    Call objConfigMan.CheckOutConfig(objConfigSetRev)
'
'
'
'    Set objConfigMan = Nothing
'    Set objConfigSetRev = Nothing
'    Exit Sub
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set objConfigSetRev = Nothing
'    Call Err.Raise("-1", , "Error occurred while checking out the config set: " & Err.Description)
'End Sub
'
'


'----------------------------------------------------------------------------
'   Name: checkOutRefSet
'   Description:  Checks out the latest reference configuration set.
'                    Returns the version number that was checked out
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Function checkOutRefSet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String) As Integer
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As MTConMan
'    Dim intVersion          As Integer
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Function
'    End If
'
'    intVersion = CInt(objConfigMan.getRepConfigSetVersion(mkstrReferenceSetName))
'    Set objConfigMan = Nothing
'
'    Call checkOutSet(icstrUserName, icstrPassword, mkstrReferenceSetName, intVersion)
'
'    checkOutRefSet = intVersion
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Call Err.Raise("-1", , "Error occurred while checking out the config set: " & Err.Description)
'End Function



'----------------------------------------------------------------------------
'   Name: deploySet
'   Description:  deploys  a configuration set based on the name and version
'                   supplied.  Either a test deployment or a real
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'               icstrSetName - the name of the config set to deploy
'               icintSetVersion - the version of the config set to deploy
'               icbolIsTestDeploy - a flag to indicate whether it is a test deploy
'               icdtmDeployDate - the date and time to deploy
'               icstrComments - currently not used - comments to use if a check-in
'                           is required
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Sub deploySet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String, _
'                        ByVal icstrSetName As String, _
'                        ByVal icintSetVersion As Integer, _
'                        ByVal icbolIsTestDeploy As Boolean, _
'                        ByVal icdtmDeployDate As Date, _
'                        ByVal icstrComments As String)
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As New MTConMan
'    Dim objConManApp        As MTConManApplication
'    Dim arrConfigSets       As MTConfigSetList
'    Dim objConfigSet        As MTConfigSet
'    Dim objConfigSetRev     As MTConfigSetRevision
'    Dim bolFound            As Boolean
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Sub
'    End If
'
'
'
'
'    '-----------------------------------------------------------
'    ' Create the config set revision, then perform the action
'    '-----------------------------------------------------------
'    Set objConfigSetRev = New MTConfigSetRevision
'    Call objConfigSetRev.AddRevision(icstrSetName, CStr(icintSetVersion), icstrUserName, Now, "")
'    objConfigSetRev.ConfigSetOwner = objConfigMan.GetConfigSetOwner(icstrSetName)
'    objConfigSetRev.ModifiedBy = icstrUserName
'    objConfigSetRev.EffectiveOleDate = icdtmDeployDate
'
'    Set objConManApp = New MTConManApplication
'    objConManApp.WorkingAreaHostname = "localhost"
'    objConManApp.ConfigSetRevision = objConfigSetRev
'
'    Call objConfigMan.DeployConfig(objConfigSetRev)
'
'
''    bolFound = False
''
''    '-----------------------------------------------------------
''    ' Go through the config sets until the correct one is found
''    ' then do the appropriate action
''    '-----------------------------------------------------------
''    Set arrConfigSets = objConfigMan.GetRepositoryConfigSetList
''    For Each objConfigSet In arrConfigSets
''        If bolFound Then
''            Exit For
''        End If
''
''        If objConfigSet.SetName = icstrSetName Then
''            For Each objConfigSetRev In objConfigSet
''                If objConfigSetRev.Version = icintSetVersion Then
''                    objConfigSetRev.ModifiedBy = icstrUserName
''                    objConfigSetRev.EffectiveOleDate = icdtmDeployDate
''                    Call objConfigMan.DeployConfig(objConfigSetRev)
''                    bolFound = True
''                    Exit For
''                End If
''            Next
''        End If
''    Next
'
'    Set objConfigMan = Nothing
'    Set objConManApp = Nothing
'    Set arrConfigSets = Nothing
'    Set objConfigSet = Nothing
'    Set objConfigSetRev = Nothing
'    Exit Sub
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Set objConManApp = Nothing
'    Set arrConfigSets = Nothing
'    Set objConfigSet = Nothing
'    Set objConfigSetRev = Nothing
'    Call Err.Raise("-1", , "Error occurred while checking in the config set: " & Err.Description)
'End Sub



'----------------------------------------------------------------------------
'   Name: checkOutRefSet
'   Description:  Checks out the latest reference configuration set.
'                    Returns the version number that was checked out
'   Parameters: icstrUserName - the username to get to the working area
'               icstrPassword - the password to use
'   Return Value: none
'-----------------------------------------------------------------------------
'Public Sub deployRefSet(ByVal icstrUserName As String, _
'                        ByVal icstrPassword As String, _
'                        ByVal icbolIsTestDeploy As Boolean, _
'                        ByVal icdtmDeployDate As Date, _
'                        ByVal icstrComments As String)
'On Error GoTo ErrHandler
'
'    Dim objConfigMan        As MTConMan
'    Dim intVersion          As Integer
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        Exit Sub
'    End If
'
'    intVersion = CInt(objConfigMan.GetWorkingAreaConfigSetVersion(mkstrReferenceSetName))
'    Set objConfigMan = Nothing
'
'    Call deploySet(icstrUserName, icstrPassword, mkstrReferenceSetName, intVersion, icbolIsTestDeploy, icdtmDeployDate, icstrComments)
'    Exit Sub
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    Call Err.Raise("-1", , "Error occurred while deploying the config set: " & Err.Description)
'End Sub



'----------------------------------------------------------------------------
'   Name: getConfigPath
'   Description:  returns the local path for a particular config set
'   Parameters: icstrConfigName - the name of the config set
'               icstrConfigRevision - revision
'   Return Value: the local path to that directory
'-----------------------------------------------------------------------------
Public Function getConfigPath(ByVal icstrConfigName As String, ByVal icstrConfigRevision As String)
    getConfigPath = getWADirectory & "\" & icstrConfigName & "__v" & icstrConfigRevision
End Function




'----------------------------------------------------------------------------
'   Name: getRepConfigSetVersion
'   Description:  returns the highest revision for the given config set
'                   in the repository
'   Parameters: icstrConfigName - the name of the config set
'   Return Value: the highest revision number
'-----------------------------------------------------------------------------
'Public Function getRepConfigSetVersion(ByVal icstrUserName As String, _
'                            ByVal icstrPassword As String, _
'                            ByVal icstrConfigName As String) As String
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As New MTConMan
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        getRepConfigSetVersion = -1
'        Exit Function
'    End If
'
'    getRepConfigSetVersion = CLng(objConfigMan.getRepConfigSetVersion(icstrConfigName))
'
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    getRepConfigSetVersion = -1
'    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
'End Function



'----------------------------------------------------------------------------
'   Name: getWAConfigSetVersion
'   Description:  returns the highest revision for the given config set
'                   in the working area
'   Parameters: icstrConfigName - the name of the config set
'   Return Value: the highest revision number
'-----------------------------------------------------------------------------
'Public Function getWAConfigSetVersion(ByVal icstrUserName As String, _
'                            ByVal icstrPassword As String, _
'                            ByVal icstrConfigName As String) As String
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As New MTConMan
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        getWAConfigSetVersion = -1
'        Exit Function
'    End If
'
'    getWAConfigSetVersion = CLng(objConfigMan.GetWorkingAreaConfigSetVersion(icstrConfigName))
'
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    getWAConfigSetVersion = -1
'    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
'End Function





'----------------------------------------------------------------------------
'   Name: getDeployedConfigSetVersion
'   Description:  returns the highest revision for the given config set
'                   that has been deployed
'   Parameters: icstrConfigName - the name of the config set
'   Return Value: the highest revision number
'-----------------------------------------------------------------------------
'Public Function getDeployedConfigSetVersion(ByVal icstrUserName As String, _
'                            ByVal icstrPassword As String, _
'                            ByVal icstrConfigName As String) As String
'
'On Error GoTo ErrHandler
'    Dim objConfigMan        As New MTConMan
'
'    '-----------------------------------------------------------
'    ' If we can't get the working areas - just exit
'    '-----------------------------------------------------------
'    Set objConfigMan = getConManObject(icstrUserName, icstrPassword)
'    If objConfigMan Is Nothing Then
'        getDeployedConfigSetVersion = -1
'        Exit Function
'    End If
'
'    getDeployedConfigSetVersion = CLng(objConfigMan.getDeployedConfigSetVersion(icstrConfigName))
'
'    Exit Function
'
'ErrHandler:
'    Set objConfigMan = Nothing
'    getDeployedConfigSetVersion = -1
'    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
'End Function


