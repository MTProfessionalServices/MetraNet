VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

#Const DEBUG_PRINT = False

' Define the type of the item - This is not a flag
Public Enum TDB_ItemType
    TEST_ITEM = 1
    TEST_SESSION_ITEM = 2
    FOLDER_ITEM = 4
    STATIC_FILE_ITEM = 8
    GLOBAL_TEST_ITEM = 16
    COMPARE_DEF_ITEM = 32
End Enum

' Define the sub type of the item. a Folder can a sub type STANDARD_FOLDER or SYSTEM_FOLDER
Public Enum TDB_ItemFlags
    DEFAULT_ITEM = 1
    STANDARD_ITEM = DEFAULT_ITEM
    STANDARD_FOLDER = DEFAULT_ITEM
    SYSTEM_FOLDER = 2
    EXTERNAL_FOLDER = 4
    IGNORED_FOLDER = 8
End Enum

Public Enum TDB_ProgramType
    VBScript = 1
    EXE
    BAT
    Unknown
End Enum

Public Enum TDB_CopyFlags
    cfPROPERTIES = 1
    cfPARAMETERS = 2
    cfTESTS = 4
    cfALL = cfPROPERTIES + cfPARAMETERS + cfTESTS
End Enum

Public PopUpDefinition As String ' This has never was used but keep for compatibility reason

Public Dictionary As Object '  MTMSIX.Dictionary

' Common property for all the CTDBItem Type
Public ItemType                         As TDB_ItemType
Public Parent                           As CTDBItem
Public Path                             As String
Public Name                             As String

Public LongID                           As Long ' Long ID are only used during the Test Harness Session
Public Flags                            As TDB_ItemFlags
Public LastSavedTime                    As String
Public LastSavedComputer                As String
Public LastSavedUserName                As String
Public ReadOnly                         As Boolean
Public chkSendEmail                     As Boolean 'Do you want to send email after session has completed executing.


Public UseParameterNameInCommandLine    As Boolean ' Default value is TRUE
Public UseGlobalParameterInCommandLine  As Boolean ' Default value is TRUE
Public ContinueTestSessionIfFailed      As Boolean ' Default value is TRUE changed in Test Harness 3.5
Public SkipTestInSession                As Boolean ' Default value is FALSE added in Test Harness 3.5
Public Program                          As String
Public IsSessionInSession               As Boolean ' Default is false added in 3.8

Private m_strName                           As String
Private m_varID                             As Variant
Private m_booSessionMode                    As Boolean
Private m_Tests                             As CTDBItems ' If the CTDBItem is a Test Session then it has a collection of test.
Private m_InterSectionParameters          As CTDBParameters

' 4.0 Implementation of a new object called CompareDef
Public PropertyBagName
Public ResultFolder
Public SQLQuery


Private m_Text As New cStringConcat ' Use to generate text infor
Private m_description           As String
Private m_DescriptionParser As MetraTech_QA_TestHarness_CommentParser.IDescriptionParser
Public m_Parameters                       As CTDBParameters
Private m_Children                         As New CTDBItems




' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Initialize(ByVal eType As TDB_ItemType, ByVal strPath As String, Optional ByVal strFileName As String, Optional booLoadChildren As Boolean, Optional booValidateIntegrity As Boolean = False, Optional ByVal booNewTest As Boolean, Optional ByVal booIsRoot As Boolean = False, Optional ByVal strPathsToIgnore As String) As Boolean

    On Error GoTo ErrMgr
    
    #If DEBUG_PRINT Then
        Debug.Print "Initialize Path:" & strPath & " FileName:" & strFileName
    #End If
    
    If booIsRoot Then
    
        Set g_static_IntegrityGUIDList = New Collection
        g_static_MainDataBaseLoading = True
        
        LoadDictionary
    End If
    
    If (Len(strPathsToIgnore)) Then
        m_static_arrayPathsToIgnore = Split(strPathsToIgnore, ";")
    End If
    
    Me.DBInfo.InitializationCount = Me.DBInfo.InitializationCount + 1

    
'    If (Me.DBInfo.InitializationCount Mod g_static_lngRefreshEveryItem) = 0 Then
'
'        If Not g_static_booMainForm Is Nothing Then
'
'            g_static_booMainForm.RefreshLoading Me.DBInfo.InitializationCount, strFileName
'        End If
'    End If
    If eType = TEST_SESSION_ITEM Then
    
        If Not g_static_booMainForm Is Nothing Then
        
            g_static_booMainForm.RefreshLoading Me.DBInfo.InitializationCount, strFileName
        End If
    End If


        
    ItemType = eType
    Path = strPath
    Name = strFileName
    
    If (Not IsValidObject(Parent)) Then
        If (Me.ItemType = FOLDER_ITEM) Then
            ID = Path
        End If
    End If
    
    'Debug.Print "CTDBItem Initialize " & Caption
        
    If (UCase$(Name) = TESTHARNESS_GLOBAL_ID) Then ItemType = GLOBAL_TEST_ITEM ' Global test
    
    Select Case eType
    
        Case COMPARE_DEF_ITEM
'            Debug.Assert 0
            If booNewTest Then
            
            Else
                If (Not LoadCompareDefnfo()) Then Exit Function
            End If
        
            
        Case STATIC_FILE_ITEM
        
            Me.DBInfo.StaticFileInitializationCounter = Me.DBInfo.StaticFileInitializationCounter + 1
        
        Case TEST_ITEM
        
            If booNewTest Then
            
            Else
                If (Not LoadTestInfo()) Then Exit Function
            End If
            
        Case TEST_SESSION_ITEM
            
            ''''''''''Set Tests = New CTDBItems
                        
            If booNewTest Then
            
            Else
                If (Not LoadTestSessionInfo(True)) Then Exit Function
            End If
            
        Case FOLDER_ITEM
            Me.DBInfo.FolderInitializationCount = Me.DBInfo.FolderInitializationCount + 1
            Name = Path
            If g_static_booShowStaticFile Then ReadSystemFolderInfo
    End Select
        
    If FolderMustBeIgnored Then
    
        Debug.Print "Ignore folder " & Me.Name
        Flags = Flags + IGNORED_FOLDER
    Else
        If (booLoadChildren) Then
            
            If (LoadFolderChildren(booIsRoot)) Then
            
                If (LoadTestChildren()) Then
                
                End If
            End If
        Else
            ' we do not have children it is ok
        End If
    End If

    ' Only for the root, validate the integrity.
    If (booValidateIntegrity) Then
        Initialize = ValidateIntegrity(True)
    Else
        Initialize = True
    End If
    
    If (g_static_MainDataBaseLoading) And (Not IntegrityGUIDListAdd(Me.ID)) Then
    
        ShowError PreProcess(TESTHARNESS_ERROR_7030, "TEST", Me.Name), "CTDBItem", "Initialize"
    End If
    
    If booIsRoot Then
    
        g_static_MainDataBaseLoading = False
    End If


    If Me.ItemType = TEST_ITEM Then
    
        If CBool(InStr(Me.Name, ",")) Then
    
            ShowError PreProcess(TESTHARNESS_ERROR_7050, "TEST", Me.Name), "CTDBItem", "Initialize"
        End If
    End If
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Initialize"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function PathName() As String

    On Error GoTo ErrMgr


    Dim objTextFile As New cTextFile
    PathName = objTextFile.GetFileName(Path)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "PathName"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function ToString() As String

    On Error GoTo ErrMgr

    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ToString"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function LoadTestChildren() As Boolean

    On Error GoTo ErrMgr


    Dim objFiles    As New CVariables
    Dim objFile     As New CVariable
    Dim objTextFile As New cTextFile
    Dim objTest     As CTDBItem
    Dim strID       As String
    
    ' Load the test
    Me.DBInfo.GetDirCount = Me.DBInfo.GetDirCount + 1
    If (objTextFile.GetFilesList(Path, "*." & TESTHARNESS_TEST_FILE_EXTENSION, objFiles)) Then
    
        For Each objFile In objFiles
        
            If (GetIDFromXMLFile(objFile.Value, strID)) Then
                Set objTest = Me.Children.AddTestToDB(Me, strID)
                If (IsValidObject(objTest)) Then
                objTest.Initialize TEST_ITEM, objTextFile.GetPathFromFileName(objFile.Value), objFile.Name
                Else
                    ShowErrorDuplicateIDInDB objFile.Value, strID
                End If
            Else
                Exit Function
            End If
        Next
    End If

    ' Load  the test session
    objFiles.Clear
    Me.DBInfo.GetDirCount = Me.DBInfo.GetDirCount + 1
    If (objTextFile.GetFilesList(Path, "*." & TESTHARNESS_TEST_SESSION_FILE_EXTENSION, objFiles)) Then

        For Each objFile In objFiles

            If (GetIDFromXMLFile(objFile.Value, strID)) Then
                Set objTest = Me.Children.AddTestToDB(Me, strID)
                If IsValidObject(objTest) Then
                
                    objTest.Initialize TEST_SESSION_ITEM, objTextFile.GetPathFromFileName(objFile.Value), objFile.Name
                Else
                    ShowError PreProcess(TESTHARNESS_ERROR_7029, "SESSION", objFile.Value), "CTDBItem", "LoadTestChildren"
                End If
            Else
                Exit Function
            End If
        Next
    End If
    
    If (Me.Flags And SYSTEM_FOLDER) Then

        objFiles.Clear
        If (objTextFile.GetFilesList(Path, "*.*", objFiles)) Then

            For Each objFile In objFiles

                If (UCase(objFile.Name) <> TESTHARNESS_TEST_FOLDER_INFO_FILE_NAME) Then

                    Set objTest = Me.Children.AddTestToDB(Me, objFile.Value)
                    objTest.Initialize STATIC_FILE_ITEM, objTextFile.GetPathFromFileName(objFile.Value), objFile.Name
                End If
            Next
        End If
    End If
    

    ' 4.0 Load CompareDef
    objFiles.Clear
    Me.DBInfo.GetDirCount = Me.DBInfo.GetDirCount + 1
    If (objTextFile.GetFilesList(Path, "*." & TESTHARNESS_COMPAREDEF_EXTENSION, objFiles)) Then
    
        For Each objFile In objFiles
        
            If (GetIDFromXMLFile(objFile.Value, strID)) Then
            
                Set objTest = Me.Children.AddTestToDB(Me, strID)
                If (IsValidObject(objTest)) Then
                    objTest.Initialize COMPARE_DEF_ITEM, objTextFile.GetPathFromFileName(objFile.Value), objFile.Name
                Else
                    ShowErrorDuplicateIDInDB objFile.Value, strID
                End If
            Else
                Exit Function
            End If
        Next
    End If
    LoadTestChildren = True

    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadTestChildren"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function LoadFolderChildren(Optional ByVal booIsRoot As Boolean = False) As Boolean

    On Error GoTo ErrMgr

    Dim objFolders          As New CVariables
    Dim objFolder           As New CVariable
    Dim objTextFile         As New cTextFile
    Dim objTest             As CTDBItem
    Dim DatabasePath        As String
    Dim DatabasePathName    As String
    Dim i                   As Long
    
    If (objTextFile.GetFoldersList(Path, "*.*", objFolders)) Then
    
        For Each objFolder In objFolders
        
            Set objTest = Me.Children.AddTestToDB(Me, objFolder.Value)
            objTest.Initialize FOLDER_ITEM, objFolder.Value, objFolder.Name, True
        Next
    
        ' If we are loading the root we are checking for the external test database
        If booIsRoot Then
        
               objFolders.Clear
               
               i = 1
               Do
                    DatabasePath = Environ("METRATECHTESTDATABASE" & i)
                    
                    If Len(DatabasePath) Then
                        DatabasePathName = objTextFile.GetFileName(DatabasePath)
                        objFolders.Add DatabasePathName, DatabasePath, , , DatabasePathName
                    Else
                        Exit Do
                    End If
                    i = i + 1
               Loop
               For Each objFolder In objFolders
        
                    Set objTest = Me.Children.AddTestToDB(Me, objFolder.Value)
                    objTest.Initialize FOLDER_ITEM, objFolder.Value, objFolder.Name, True
                    objTest.Flags = objTest.Flags + EXTERNAL_FOLDER
                    
                Next
        End If
    
        
    End If
    LoadFolderChildren = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadFolderChildren"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function FillTreeView(objTreeView As Variant, Optional ByVal booRoot As Boolean, Optional ByVal booClear As Boolean = False, Optional ByVal booExpand As Boolean = False) As Boolean

    On Error GoTo ErrMgr


    Dim objChild     As CTDBItem
    Dim strParentID  As String
    Dim objTV        As TreeView
    
    Set objTV = objTreeView
    
    If (booClear) Then objTV.Nodes.Clear
        
    If (IsValidObject(Me.Parent)) Then
        strParentID = Me.Parent.ID
    Else
        ' That's the root
    End If
    
    If Me.ItemType = COMPARE_DEF_ITEM Then
        'Debug.Assert 0
    End If
    
    tvAddNode objTV, strParentID, Me.ID, Me.Caption, Icon(booRoot), TypeString(), booExpand
    
    For Each objChild In Children
        
        objChild.FillTreeView objTV, False
    Next
    
    FillTreeView = True

    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "FillTreeView"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get TypeString() As String

    On Error GoTo ErrMgr


    Select Case ItemType
    
        Case TDB_ItemType.COMPARE_DEF_ITEM
            TypeString = "COMPAREDEF"
    
        Case TDB_ItemType.FOLDER_ITEM
            TypeString = "FOLDER"
        
        Case TDB_ItemType.TEST_ITEM
            TypeString = "TEST"
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            TypeString = "TEST_SESSION"
            
        Case TDB_ItemType.STATIC_FILE_ITEM
            TypeString = "STATIC_FILE"
            
        Case TDB_ItemType.GLOBAL_TEST_ITEM
            TypeString = "GLOBAL_TEST"
    End Select

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "TypeString"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get Icon(Optional booRoot As Boolean = False) As String

    On Error GoTo ErrMgr


    If (booRoot) Then
        Icon = "Root"
        Exit Property
    End If

    Select Case ItemType
        
        Case COMPARE_DEF_ITEM
            Icon = "CompareDef"
        
        Case TDB_ItemType.FOLDER_ITEM
            Icon = "Folder"
            If (Flags And SYSTEM_FOLDER) Then Icon = "SystemFolder"
            If (Flags And EXTERNAL_FOLDER) Then Icon = "ExternalFolder"
            If (Flags And IGNORED_FOLDER) Then Icon = "IgnoredFolder"
        
        Case TDB_ItemType.TEST_ITEM
            Icon = "Test"
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            If SessionContainsSession Then
                Icon = "SuperTestSession"
            Else
                Icon = "TestSession"
            End If
            
        Case TDB_ItemType.STATIC_FILE_ITEM
            Icon = "StaticFile"
            
        Case TDB_ItemType.GLOBAL_TEST_ITEM
            Icon = "GlobalTest"
        
    End Select

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Icon"
End Property



Private Function SessionContainsSession() As Boolean

    On Error GoTo ErrMgr
    
    Dim objTest As CTDBItem
    
    For Each objTest In Me.Tests
    
        If objTest.IsSessionInSession Then
        
            SessionContainsSession = True
            Exit Function
        End If
    Next
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "SessionContainsSession"
    
End Function
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get Find(vntKey As Variant) As CTDBItem

    On Error GoTo ErrMgr
    
    If (UCase(vntKey) = UCase(Me.ID)) Then
        Set Find = Me
        Exit Property
    End If
    
    If (IsNumeric(vntKey)) Then
        If (CLng(vntKey) = ID) Then
            Set Find = Me
            Exit Property
        End If
    End If
    
    Set Find = Me.Children.Item(vntKey, True)
    

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Find"
End Property

Public Function Search(ByVal strWildCard As String, ByVal List As CVariables) As Boolean

    On Error GoTo ErrMgr
    
    Dim objResult As CTDBItem
    
    'Dim obTextFile As New cTextFile
    'obTextFile.LogFile "c:\temp\search.txt", Me.Name
    
        
    If UCase$(Me.Name) Like UCase$(strWildCard) Then
        
        If Me.ItemType = TEST_ITEM Or Me.ItemType = TEST_SESSION_ITEM Then
        
            List.Add Me.Name, Me.ID
        End If
    End If
    
    Dim it As CTDBItem
    For Each it In Me.Children

        it.Search strWildCard, List
    Next
    Search = True
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Find"
End Function





' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function NotePad(Optional ByVal strEditorName As String = "notepad.exe") As Boolean

    On Error GoTo ErrMgr


    Dim objUnitTestAPI As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    
    objUnitTestAPI.ExecSync strEditorName & " " & Me.FullName
    NotePad = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "NotePad"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get FullProgramName(Optional ByVal booShowError As Boolean = True) As String

    On Error GoTo ErrMgr

        Dim t                   As New cTextFile
        Dim strFullString       As String
        
        strFullString = Path & "\" & Me.ProgramMacro() ' try Relative path by adding the current path
        
        If t.ExistFile(strFullString) Then
        
            FullProgramName = strFullString
            
        ElseIf t.ExistFile(Me.ProgramMacro()) Then ' Try Absolute path if exist - added in 3.8
        
            FullProgramName = Me.ProgramMacro()

        Else
            If booShowError Then
                ShowError PreProcess(TESTHARNESS_ERROR_7012, "NAME", strFullString)
            End If
            FullProgramName = ""
        End If
        Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "FullProgramName"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function PopulateDialog(objFrm As Variant, Optional ByVal objSpecificControl As Object, Optional ByVal booDisplayEnumValueColumn As Boolean = True) As Boolean

    On Error GoTo ErrMgr

    Dim objCtl      As Control
    Dim varValue    As Variant
    Dim frm         As Form
    
    Set frm = objFrm
    
    If (IsValidObject(MakeItAnObject(objSpecificControl))) Then
    
        Set objCtl = objSpecificControl
        GoSub PopulateControl
    Else
    
        For Each objCtl In frm.Controls
        
            GoSub PopulateControl
        Next
    End If
    
    If Me.ItemType = TEST_ITEM And Not IsValidObject(objSpecificControl) Then
    
        If (ControlExist(frm, "Parameters")) Then
        
            PopulateDialog = PopupateParametersListView(frm.Parameters, booDisplayEnumValueColumn, False)
        End If
    End If
    PopulateDialog = True
    Exit Function
    
PopulateControl:
 
    Select Case UCase$(TypeName(objCtl))
    
        Case "TEXTBOX"
            If (COMPropertyExist(Me, objCtl.Name, varValue)) Then
                objCtl.Text = varValue
            End If
        Case "CHECKBOX"
            If (COMPropertyExist(Me, objCtl.Name, varValue)) Then
                objCtl.Value = IIf(varValue, vbChecked, vbUnchecked)
            End If
    End Select
Return
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "PopulateDialog"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function PopupateParametersListView(objlvParameters As Variant, ByVal booDisplayEnumValueColumn As Boolean, ByVal DisplayParameterIntersection As Boolean) As Boolean

    On Error GoTo ErrMgr

    Dim objListViewItem As ListItem
    Dim objParameter    As CTDBParameter
    Dim lvParameters    As ListView
    Dim lngMaxCol       As Long
    Dim strIcon         As String
    
    Set lvParameters = objlvParameters
    
    lngMaxCol = IIf(booDisplayEnumValueColumn, 4, 3)
    
    lvAddColumn lvParameters, "Name", True, (lvParameters.Width / lngMaxCol) - (3 * Screen.TwipsPerPixelX)
    lvAddColumn lvParameters, "Required", False, (lvParameters.Width / lngMaxCol) - (3 * Screen.TwipsPerPixelX)
    lvAddColumn lvParameters, "Value", False, (lvParameters.Width / lngMaxCol) - (3 * Screen.TwipsPerPixelX)
    
    If booDisplayEnumValueColumn Then
        lvAddColumn lvParameters, "EnumValue", False, (lvParameters.Width / lngMaxCol) - (3 * Screen.TwipsPerPixelX)
    End If
    
    If Me.ItemType = TEST_ITEM Then
    
        For Each objParameter In Me.Parameters
           
            If DisplayParameterIntersection Then
                strIcon = "RequiredUnknown"
            Else
                strIcon = IIf(objParameter.Required, "Required", "Optional") ' Icon
            End If
            
            Set objListViewItem = lvAddRow(lvParameters, IIf(Me.UseGlobalParameterInCommandLine, objParameter.Name, ""), objParameter.Name, , strIcon)
            objListViewItem.SubItems(1) = "" & objParameter.Required
            objListViewItem.SubItems(2) = "" & objParameter.Value
            
            If booDisplayEnumValueColumn Then
                objListViewItem.SubItems(3) = "" & objParameter.EnumValue
            End If
            'objParameter.Tag
        Next
        
    ElseIf Me.ItemType = TEST_SESSION_ITEM Then
    
        For Each objParameter In InterSectionParameters
           
            If DisplayParameterIntersection Then
                strIcon = "RequiredUnknown"
            Else
                strIcon = IIf(objParameter.Required, "Required", "Optional") ' Icon
            End If
           
            Set objListViewItem = lvAddRow(lvParameters, IIf(Me.UseGlobalParameterInCommandLine, objParameter.Name, ""), objParameter.Name, , strIcon)  ' Icon
            objListViewItem.SubItems(1) = "" & objParameter.Required
            objListViewItem.SubItems(2) = "" & objParameter.Value
            'objParameter.Tag
        Next
    End If
    
    PopupateParametersListView = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "PopupateParametersListView"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function CreateSubFolder(ByVal strFolderName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim strPath As String
    strPath = Me.Path & "\" & strFolderName
    MkDir strPath
    CreateSubFolder = True
    Exit Function
ErrMgr:

End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Delete() As Boolean

    On Error GoTo ErrMgr


    Dim objTextFile As New cTextFile
    Dim strOwnerID  As String
    Dim objOwner    As CTDBItem
    
    If (ReadOnly) Then
        ShowError PreProcess(TESTHARNESS_ERROR_7008, "NAME", Caption)
        Exit Function
    End If
    
    If (Me.ItemType = TEST_ITEM) Then
        If (IsTestUsed(Me.ID, Me.Root(), strOwnerID)) Then
            Set objOwner = Me.Root().Find(strOwnerID)
            ShowError PreProcess(TESTHARNESS_ERROR_7010, "NAME", Caption, "TEST_SESSION_FULL_NAME", objOwner.FullName)
            Exit Function
        End If
    End If
    
    
    If (MsgBox(PreProcess(TESTHARNESS_MESSAGE_7009, "NAME", Me.Name), vbQuestion + vbYesNo) = vbNo) Then Exit Function
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
            RmDir Me.Path
            
        Case TDB_ItemType.TEST_ITEM
            objTextFile.DeleteFile Me.FullName
            
        Case TDB_ItemType.TEST_SESSION_ITEM
            objTextFile.DeleteFile Me.FullName
                
        Case TDB_ItemType.STATIC_FILE_ITEM
            objTextFile.DeleteFile Me.FullName
            
    End Select
    Delete = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Delete"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function EditScript(ByVal strEditor As String, Optional ByVal booSyncronous As Boolean = True) As Boolean

    On Error GoTo ErrMgr

    
    Dim objUnitTestAPI  As Object
    Dim strCommand      As String
    
    If Me.ItemType = TEST_ITEM Then
    
        If GetProgramType() = VBScript Or GetProgramType() = BAT Then
    
            strCommand = """" & strEditor & """ " & """" & FullProgramName & """"
            GoSub EXECUTE_COMMAND

        ElseIf GetProgramType() = EXE Then
        
            If UCase$(Program) = "W3RUNNER.EXE" Then
                
                strCommand = """" & strEditor & """ " & """" & ProcessEnviron(Me.Parameters.Item("file").Value) & """"
                GoSub EXECUTE_COMMAND
            End If
            If UCase$(Program) = "COMPAREENGINE.EXE" Then
                
                'strCommand = """" & "csvedit.exe" & """ " & " -file """ & ProcessEnviron(Me.Parameters.Item("csvfile").Value) & """"
                
                strCommand = """" & "csvedit.exe" & """ " & " -server """ & ProcessEnviron(Me.Parameters.Item("server").Value) & """ -database """ & ProcessEnviron(Me.Parameters.Item("database").Value) & """ -file """ & ProcessEnviron(Me.Parameters.Item("csvfile").Value) & """"
                
                GoSub EXECUTE_COMMAND
            End If
            
        Else
            ShowError TESTHARNESS_ERROR_7037, "CTDBItem", "EditScript"
        End If
    End If
    EditScript = True
    Exit Function
    
EXECUTE_COMMAND:

    Dim f As New cTextFile
    'MsgBox App.Path & "\editfile.command.txt"
    f.LogFile App.Path & "\editfile.command.txt", strCommand, True
    
    If booSyncronous Then
    
        
        Set objUnitTestAPI = GetNewTestApiInstance()
        objUnitTestAPI.ExecSync strCommand, vbNormalFocus
    Else
        Shell strCommand, vbNormalFocus
    End If
Return
    
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "EditScript"
End Function

    
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...


Public Function Execute(Optional ByVal strScriptingExecutable As String = "CScript.exe", Optional ByVal booShowWindow As Boolean = False, Optional ByVal TestHarnessForm As Object, Optional booCopyCommandLine As Boolean = False, Optional ByVal lngExecuteOnlyLongId As Long) As Boolean

    On Error GoTo ErrMgr


    Dim objTOOL     As New cTool
    Dim objChild    As CTDBItem
    
    
    LogStartResult ' new in 4.0
    
    'If IsMissing(TestHarnessForm) Then TestHarnessForm = Empty
'    Debug.Assert 0
    Select Case ItemType
    
' -- We do not execute folder --
'        Case TDB_ItemType.FOLDER_ITEM
'
'            For Each objChild In Me.Children
'
'                If (objChild.ItemType = TEST_ITEM) Or (objChild.ItemType = TEST_SESSION_ITEM) Then
'
'                    objChild.Execute EmailTo, booRecordMode, DatabaseName, ServerName, BuildID, strScriptingExecutable, booShowWindow
'
'                    If (IsValidObject(TestHarnessForm)) Then TestHarnessForm.RefreshTestUI
'                End If
'                Execute = True
'            Next


        Case TDB_ItemType.COMPARE_DEF_ITEM
            Execute = ExecuteCompareDef()
                    
        Case TDB_ItemType.TEST_ITEM
            Execute = ExecuteTest(strScriptingExecutable, booShowWindow, booCopyCommandLine)
            
        Case TDB_ItemType.TEST_SESSION_ITEM
            Execute = ExecuteTestSession(strScriptingExecutable, booShowWindow, TestHarnessForm, booCopyCommandLine, lngExecuteOnlyLongId)
            
        Case TDB_ItemType.STATIC_FILE_ITEM
            objTOOL.ExecFile Me.FullName
                
    End Select

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Execute"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function ExecuteTest(Optional strScriptingExecutable As String = "CScript.exe", Optional ByVal booShowWindow As Boolean, Optional booCopyCommandLine As Boolean = False) As Boolean

    On Error GoTo ErrMgr

    Dim objTOOL         As New cTool
    Dim eWindowStatus   As VbAppWinStyle
    Dim objUnitTestAPI  As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    Dim strCommandLine  As String
    Dim objTextFile     As New cTextFile
    Dim strTmpBatFile   As String
    
    objTextFile.LogFile Environ("METRATECHTESTDATABASETEMP") & "\TestHarness.CurrentTest.txt", Me.Name, True
    
    objUnitTestAPI.CurrentTest = Me.Name
            
    eWindowStatus = IIf(booShowWindow, vbNormalFocus, vbMinimizedNoFocus)
    
    If booCopyCommandLine Then
    
        Clipboard.Clear
        Select Case GetProgramType()
        
            Case TDB_ProgramType.EXE
                 strCommandLine = ProgramMacro() & " " & GetParametersString()
                
            Case TDB_ProgramType.BAT
                strCommandLine = Environ("COMSPEC") & " /c """ & Me.FullProgramName & """ " & GetParametersString()
                
            Case TDB_ProgramType.VBScript
                strCommandLine = strScriptingExecutable & " " & Trim(QuotedFullProgramName() & " " & GetParametersString())
                
            Case TDB_ProgramType.Unknown
                strCommandLine = ""
                Exit Function
        End Select
        Clipboard.SetText strCommandLine
    Else
    
        OutputFileContext.Save Me.ID, Me.ItemType
        
        
        If Me.SkipTestInSession Then ' New Skip mode only for test executed from a session
        
            Dim TestApiInstance As Object
            Set TestApiInstance = GetNewTestApiInstance()
            TestApiInstance.SkipResult Me.Name, Now, Now
            TestApiInstance.TRACE PreProcess(TESTHARNESS_MESSAGE_7025, "TEST", Me.Name)
        Else
        
            
            Select Case GetProgramType()
            
                Case TDB_ProgramType.EXE
                    strCommandLine = ProgramMacro() & " " & GetParametersString()
                    objUnitTestAPI.ExecSync strCommandLine, eWindowStatus
                    
                Case TDB_ProgramType.BAT
                    strCommandLine = """" & Me.FullProgramName & """ " & GetParametersString()
                    strTmpBatFile = Environ("TEMP") & "\TestHarness.Bat"
                    objTextFile.LogFile strTmpBatFile, strCommandLine, True
                    
                    objTOOL.execPrgSyncrone Environ("COMSPEC") & " /c " & strTmpBatFile, eWindowStatus
                    
                Case TDB_ProgramType.VBScript
                    strCommandLine = strScriptingExecutable & " " & Trim(QuotedFullProgramName() & " " & GetParametersString())
                    objUnitTestAPI.ExecSync strCommandLine, eWindowStatus
                    
                    
                Case TDB_ProgramType.Unknown
                    ExecuteTest = False
                    Exit Function
            End Select
        End If
        
        objTextFile.LogFile Environ("METRATECHTESTDATABASETEMP") & "\TestHarness.CommandLine.Log", strCommandLine
        
        Select Case OutputFileContext.Read(AppOptions("ShowMessageIfTestFail", True), AppOptions("RecordModeOn", False), AppOptions("DatabaseRecordMode"), AppOptions("SQLServerRecodMode"), AppOptions("BuildID"), AppOptions("DBUserName"), AppOptions("DBPassWord"), UCase(AppOptions("CommandLineMode")) = "TRUE")
        
            Case OUTPUT_FILE_CONTEXT_FILE_FAILED
                ExecuteTest = False
                LogIntoMTLOGTestStartOrEnd False, False
                
            Case OUTPUT_FILE_CONTEXT_FILE_OK
                ExecuteTest = True
                LogIntoMTLOGTestStartOrEnd False, True ' OK
                
            Case OUTPUT_FILE_CONTEXT_FILE_NOT_FOUND
                ShowError PreProcess(TESTHARNESS_ERROR_7025, "FILENAME", OutputFileContext.FileName), TypeName(Me), "ExecuteTest"
                LogIntoMTLOGTestStartOrEnd False, False
                
            Case OUTPUT_FILE_CONTEXT_FILE_DID_NOT_CHANGED
            
                ShowError PreProcess(TESTHARNESS_ERROR_7024, "NAME", Me.Name), TypeName(Me), "ExecuteTest"
                
                objUnitTestAPI.LogResult Me.Name, False, CStr(Now()), CStr(Now()), PreProcess(TESTHARNESS_ERROR_7024, "NAME", Me.Name)
                
                LogIntoMTLOGTestStartOrEnd False, False
                
            Case OUTPUT_FILE_CONTEXT_FILE_UNKNOWN
                ShowError PreProcess(TESTHARNESS_ERROR_7026, "NAME", Me.Name), TypeName(Me), "ExecuteTest"
                LogIntoMTLOGTestStartOrEnd False, False
        End Select
    End If
    
TheExit:
    objUnitTestAPI.CurrentTest = ""
    Exit Function
    
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ExecuteTest"
        GoTo TheExit
End Function
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...

Public Function GetParametersString() As String

    On Error GoTo ErrMgr

    Dim objParameter    As CTDBParameter
    Dim strS            As String
    Dim objUnitTestAPI  As Object: Set objUnitTestAPI = GetNewTestApiInstance()
        
    For Each objParameter In Me.Parameters
    
        If Not objParameter.Required And Len(objParameter.Value) = 0 Then ' If the parameter if optional and the value is blank then we do not include it on the command line
            
        Else
        
            GoSub BuildString
        End If
    Next
    
    ' Get the global parameters from the global.test CTDBItem only if it is not the global.test item
    If (UCase(Me.ID) <> UCase(TESTHARNESS_GLOBAL_ID)) And (Me.UseGlobalParameterInCommandLine) Then
    
        strS = strS & GlobalTDBItem.GetParametersString() & " "
        strS = strS & "-LOCALTESTPATH """ & Me.Path & """" & " " ' Here we use the
        strS = strS & "-LOCALTESTNAME """ & Me.Name & """" & " "
        strS = strS & "-LOCALTESTGUID """ & Me.ID & """" & " "
    
        If (objUnitTestAPI.TestSessionParameters.Count) Then
        
            For Each objParameter In objUnitTestAPI.TestSessionParameters
            
                If Not objParameter.Required And Len(objParameter.Value) = 0 Then ' If the parameter if optional and the value is blank then we do not include it on the command line
                    
                Else
                
                    GoSub BuildString
                End If
            Next
        End If
    End If
    
    GetParametersString = Trim(strS)

    Exit Function
    
BuildString:
    If (UseParameterNameInCommandLine) Then
        strS = strS & "-" & objParameter.Name & " """ & ProcessEnviron(objParameter.Value) & """" & " "
    Else
        strS = strS & ProcessEnviron(objParameter.Value)
    End If
Return
    
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GetParametersString"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function GetProgramType() As TDB_ProgramType

    On Error GoTo ErrMgr


    Select Case UCase(Right(Program, 3))
    
        Case "BAT", "CMD": GetProgramType = TDB_ProgramType.BAT
        Case "EXE": GetProgramType = TDB_ProgramType.EXE
        Case "VBS", "WSF", "WSH": GetProgramType = TDB_ProgramType.VBScript
        Case Else
            GetProgramType = Unknown
    End Select

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GetProgramType"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function QuotedFullProgramName() As String

    On Error GoTo ErrMgr

    QuotedFullProgramName = """" & FullProgramName & """"

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "QuotedFullProgramName"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    Dim objWindow As New cWindows
    
    ID = objWindow.CreateGUIDKey() ' Create a valid string id
    
    LongID = GetUnicLongID()           ' Create a valid long id
    
    ContinueTestSessionIfFailed = True ' changed in Test Harness 3.5
    
    Flags = TDB_ItemFlags.DEFAULT_ITEM
    
    ItemType = TEST_ITEM ' When we read a session test through XMLLoader the item test objects are not initialized and so do not have any type. We for a default type.
                         
    UseParameterNameInCommandLine = True
    UseGlobalParameterInCommandLine = True
    

    ReadOnly = False
            
    UpdateLastSavedInfo
    
    
    g_booLogWithoutCOMLogger = False
    
    
    'Set Parameters.Parent = Me
    
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Class_Initialize"
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function GetUnicLongID() As Long

    On Error GoTo ErrMgr
    g_lngGetUnicLongID = g_lngGetUnicLongID + 1
    GetUnicLongID = g_lngGetUnicLongID
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GetUnicLongID"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get Root() As CTDBItem

    On Error GoTo ErrMgr

    If (Not IsValidObject(Parent)) Then ' The root does not have any parent
        Set Root = Me
    Else
        Set Root = Parent.Root()
    End If

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Root"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    'Debug.Print "Class_Terminate " & Caption

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Class_Terminate"
End Sub

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get GlobalTDBItem() As CTDBItem

    On Error GoTo ErrMgr

        
    Dim objTDBItemGlobal As CTDBItem
    Dim objTDBItemRoot   As CTDBItem
    
    Set objTDBItemRoot = Me.Root
    
    Set objTDBItemGlobal = objTDBItemRoot.Find(TESTHARNESS_GLOBAL_ID)
    If (Not IsValidObject(objTDBItemGlobal)) Then
        ShowError TESTHARNESS_ERROR_7005
        LogError TESTHARNESS_ERROR_7005, "CTDBItem.cls", "GlobalTDBItem"
    Else
        Set GlobalTDBItem = objTDBItemGlobal
    End If

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GlobalTDBItem"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function ReadSystemFolderInfo() As Boolean

    On Error GoTo ErrMgr


    Dim objTextFile     As New cTextFile
    Dim objXMLLoader    As New XMLLoader
    Dim objTranslate    As New CVariables
    
    ReadSystemFolderInfo = True
    
    If (objTextFile.ExistFile(FolderInfoFileName)) Then
    
        objTranslate.Add "folder", "CTDBItem"
        ReadSystemFolderInfo = objXMLLoader.LoadObjectModelData(Me, FolderInfoFileName, objTranslate, "folder")
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ReadSystemFolderInfo"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get FolderInfoFileName() As String

    On Error GoTo ErrMgr

    FolderInfoFileName = Me.Path & "\folder.info.xml"

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "FolderInfoFileName"
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   : Can only clone Test Item for now
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Clone(booSameID As Boolean, booSameLongID As Boolean) As CTDBItem

    On Error GoTo ErrMgr

    Dim objNewInstance As CTDBItem
    Dim objParameter   As CTDBParameter
    Dim objWindow As New cWindows
    
    If (Me.ItemType = TEST_ITEM) Then
    
        Set objNewInstance = New CTDBItem
        
        objNewInstance.Initialize Me.ItemType, Me.Path, Me.Name, , , True
        
        objNewInstance.SkipTestInSession = Me.SkipTestInSession
        
        objNewInstance.UseGlobalParameterInCommandLine = Me.UseGlobalParameterInCommandLine
        objNewInstance.UseParameterNameInCommandLine = Me.UseParameterNameInCommandLine
        objNewInstance.ContinueTestSessionIfFailed = Me.ContinueTestSessionIfFailed
        objNewInstance.Program = Me.Program

        
        For Each objParameter In Me.Parameters
        
            objNewInstance.Parameters.AddInstance objParameter.Clone()
        Next
        
        If (booSameID) Then
            objNewInstance.ID = Me.ID
        Else
            objNewInstance.ID = objWindow.CreateGUIDKey() ' Create a valid string id
        End If
        
        If (booSameLongID) Then
            objNewInstance.LongID = Me.LongID
        Else
            objNewInstance.LongID = GetUnicLongID()           ' Create a valid long id
        End If
    End If
    
    If (Me.ItemType = TEST_SESSION_ITEM) Then
    
        Set objNewInstance = New CTDBItem
        
        objNewInstance.Initialize Me.ItemType, Me.Path, Me.Name
        
        If (booSameID) Then
            objNewInstance.ID = Me.ID
        Else
            objNewInstance.ID = objWindow.CreateGUIDKey() ' Create a valid string id
        End If
        
        If (booSameLongID) Then
            objNewInstance.LongID = Me.LongID
        Else
            objNewInstance.LongID = GetUnicLongID()           ' Create a valid long id
        End If
    End If
    Set Clone = objNewInstance
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Clone"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Save() As Boolean

    On Error GoTo ErrMgr

    If (ReadOnly) Then
        ShowError PreProcess(TESTHARNESS_ERROR_7008, "NAME", Caption)
        Exit Function
    End If
    UpdateLastSavedInfo
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        Case TDB_ItemType.TEST_ITEM
            Save = SaveAsTest
        Case TDB_ItemType.TEST_SESSION_ITEM
            Save = SaveAsTestSession
        Case TDB_ItemType.STATIC_FILE_ITEM
            ' not supported
    End Select

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Save"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function SaveAsTestSession() As Boolean

    On Error GoTo ErrMgr


    Dim strXML          As String
    Dim objTest         As CTDBItem
    Dim objParameter    As CTDBParameter
    Dim objTextFile     As New cTextFile
    
    strXML = strXML & "<Session>" & vbNewLine
    
    SaveCommon strXML
    strXML = strXML & PreProcess("    <chkSendEmail>[CHKSENDEMAIL]</chkSendEmail>", "CHKSENDEMAIL", Me.chkSendEmail) & vbNewLine
    strXML = strXML & "    <Tests type=""collection"">" & vbNewLine
        
    For Each objTest In Me.Tests
    
        strXML = strXML & PreProcess("      <Test id=""[ID]"" nokey=""true"">", "ID", objTest.ID) & vbNewLine
        
        strXML = strXML & PreProcess("            <Name>[NAME]</Name>", "NAME", objTest.Name) & vbNewLine
        strXML = strXML & PreProcess("            <ContinueTestSessionIfFailed>[CONTINUETESTSESSIONIFFAILED]</ContinueTestSessionIfFailed>", "CONTINUETESTSESSIONIFFAILED", objTest.ContinueTestSessionIfFailed) & vbNewLine
        strXML = strXML & PreProcess("            <UseParameterNameInCommandLine>[USEPARAMETERNAMEINCOMMANDLINE]</UseParameterNameInCommandLine>", "USEPARAMETERNAMEINCOMMANDLINE", objTest.UseParameterNameInCommandLine) & vbNewLine
        strXML = strXML & PreProcess("            <UseGlobalParameterInCommandLine>[USEGLOBALPARAMETERINCOMMANDLINE]</UseGlobalParameterInCommandLine>", "USEGLOBALPARAMETERINCOMMANDLINE", objTest.UseGlobalParameterInCommandLine) & vbNewLine
        strXML = strXML & PreProcess("            <SkipTestInSession>[SKIP]</SkipTestInSession>", "SKIP", objTest.SkipTestInSession) & vbNewLine
        
        ' Added in 3.7
        objTest.IsSessionInSession = objTest.ItemType = TEST_SESSION_ITEM
        strXML = strXML & PreProcess("            <IsSessionInSession>[ISSESSIONINSESSION]</IsSessionInSession>", "ISSESSIONINSESSION", objTest.IsSessionInSession) & vbNewLine

        strXML = strXML & "            <Parameters type=""collection"">" & vbNewLine
        
        For Each objParameter In objTest.Parameters
        
                'strXML = strXML & PreProcess("                <Parameter id=""[NAME]""><Value>[VALUE]</Value></Parameter>", "NAME", objParameter.Name, "VALUE", objParameter.Value) & vbNewLine
                strXML = strXML & PreProcess("                <Parameter id=""[NAME]""><value>[VALUE]</value><required>[REQUIRED]</required><enumvalue>[ENUMVALUE]</enumvalue></Parameter>", "NAME", objParameter.Name, "VALUE", objParameter.Value, "REQUIRED", objParameter.Required, "ENUMVALUE", objParameter.EnumValue) & vbNewLine
        Next
        strXML = strXML & "            </Parameters>" & vbNewLine
        strXML = strXML & "      </Test>" & vbNewLine
    Next
    strXML = strXML & "    </Tests>" & vbNewLine
    strXML = strXML & "</Session>" & vbNewLine
    SaveAsTestSession = objTextFile.LogFile(FullName, strXML, True)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "SaveAsTestSession"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function FullName() As String

    On Error GoTo ErrMgr

    FullName = Path & "\" & Name

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "FullName"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function PopulateInstance(frm As Variant, Optional ByVal objSpecificControl As Variant) As Boolean

    On Error GoTo ErrMgr


    Dim objCtl      As Control
    Dim varValue    As Variant
    
    If (IsValidObject(MakeItAnObject(objSpecificControl))) Then
    
        Set objCtl = objSpecificControl
        GoSub Populate
    Else
        For Each objCtl In frm.Controls
            GoSub Populate
        Next
    End If
   
    PopulateInstance = True
    Exit Function
    
Populate:

    Select Case UCase$(TypeName(objCtl))
     
         Case "TEXTBOX"
             If (Not objCtl.Locked) Then
                 If (COMPropertyExist(Me, objCtl.Name, varValue)) Then
                      CallByName Me, objCtl.Name, VbLet, objCtl.Text
                 End If
             End If
         Case "CHECKBOX"
             If (COMPropertyExist(Me, objCtl.Name, varValue)) Then
                 CallByName Me, objCtl.Name, VbLet, CBool(objCtl.Value = vbChecked)
             End If
     End Select
Return


    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "PopulateInstance"
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function PopupateTestsListBox(Tests As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim objTest As CTDBItem
    For Each objTest In Me.Tests
    
        Tests.AddItem objTest.Caption
        Tests.itemData(Tests.NewIndex) = objTest.ID
    Next
    PopupateTestsListBox = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "PopupateTestsListBox"
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false this does not mean the test succeed.
Friend Function ExecuteTestSession(Optional strScriptingExecutable As String = "CScript.exe", Optional ByVal booShowWindow As Boolean, Optional TestHarnessForm As Object, Optional booCopyCommandLine As Boolean = False, Optional ByVal lngExecuteOnlyLongId As Long) As Boolean

    On Error GoTo ErrMgr
    Dim objTOOL                 As New cTool
    Dim eWindowStatus           As VbAppWinStyle
    Dim objUnitTestAPI As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    Dim objTest                 As CTDBItem
    Dim objSubTestSession       As CTDBItem
    Dim objTestInfo             As CTDBItem
    Dim booTestResult           As Boolean
    Dim booTestSessionResult    As Boolean
    Dim booContinue             As Boolean
    Dim objTestRoot             As CTDBItem
    Dim strStartTime            As String
    Dim strCommandLine          As String
    Dim TestApiInstance         As Object

    m_booSessionMode = True
'    Debug.Assert 0



    
    If booCopyCommandLine Then Clipboard.Clear
    
    strStartTime = Now()
    EmailMsg = ""
    Set objTestRoot = Me.Root()

    GoSub SetLocalSessionInfo
    
    objUnitTestAPI.TestSessionParameters.Clear
        
    eWindowStatus = IIf(booShowWindow, vbNormalFocus, vbMinimizedNoFocus)
    
    booTestSessionResult = True
    booContinue = True
    
    For Each objTestInfo In Me.Tests ' Loop around all the Tests but there does not contains all the test info Expect the name and the parameters
    
        If (lngExecuteOnlyLongId = 0) Or (lngExecuteOnlyLongId = objTestInfo.LongID) Then
                                     
            booContinue = objTestInfo.ContinueTestSessionIfFailed
            
            If objTestInfo.IsSessionInSession Then
            
                Set objSubTestSession = Root.Find(objTestInfo.ID) ' Find the real instance of the test session
                
                If objTestInfo.SkipTestInSession Then
                    
                    Set TestApiInstance = GetNewTestApiInstance()
                    TestApiInstance.SkipResult objSubTestSession.Name, Now, Now
                    TestApiInstance.TRACE PreProcess(TESTHARNESS_MESSAGE_7027, "SESSION_IN", objSubTestSession.Name, "SESSION_PARENT", Me.Name)
                    booTestResult = True
                Else
                    objSubTestSession.LogStartResult
                    booTestResult = objSubTestSession.ExecuteTestSession(strScriptingExecutable, booShowWindow, TestHarnessForm, booCopyCommandLine)
                    GoSub SetLocalSessionInfo
                End If
            Else
                ' Find the Real Test and copy the information
                Set objTest = Root.Find(objTestInfo.ID)
                
                objTest.CopyExecutionInfoTo objTestInfo
                
                booTestResult = objTestInfo.Execute(strScriptingExecutable, booShowWindow, TestHarnessForm, booCopyCommandLine)
            End If
            
            booTestSessionResult = booTestSessionResult And booTestResult
            
            If booCopyCommandLine Then
            
                strCommandLine = strCommandLine & Clipboard.GetText() & vbNewLine
                
            Else
                If (booTestSessionResult) Then ' Check the result of the test
                
                     If Not objTestInfo.SkipTestInSession Then
                     
                         If Not Me.OutputFileContext.TestSucceed() Then
                        
                            If Not objTestInfo.ContinueTestSessionIfFailed Then
                            
                                TRACE PreProcess(TESTHARNESS_ERROR_7011, "TEST_SESSION_NAME", Me.Caption, "TEST_NAME", objTestInfo.Caption)
                                Exit For
                            End If
                         End If
                     End If
                End If
                If (IsValidObject(TestHarnessForm)) Then TestHarnessForm.RefreshTestUI
                If (Not (booTestSessionResult) And Not (booContinue)) Then Exit For
            End If
        End If
    Next
    
    ExecuteTestSession = booTestSessionResult
    
    If booCopyCommandLine Then
    
        strCommandLine = vbNewLine & "REM -- Session " & Me.Name & " --" & vbNewLine & strCommandLine
        Clipboard.SetText strCommandLine
    Else
        If Me.chkSendEmail Then ' send email
            SendEmailMsg EmailMsg, AppOptions("EMAIL")
        End If
        
        ' Write the test session result to the coverage database
        OutputFileContext.Save Me.ID, Me.ItemType
        
        objUnitTestAPI.LogResult Me.Name, booTestSessionResult, strStartTime, Now(), "", IIf(SessionContainsSession(), LOG_RESULT_MODE.LOG_RESULT_MODE_SUPER_SESSION, LOG_RESULT_MODE.LOG_RESULT_MODE_SESSION)
        
        OutputFileContext.Read AppOptions("ShowMessageIfTestFail", True), AppOptions("RecordModeOn", False), AppOptions("DatabaseRecordMode"), AppOptions("SQLServerRecodMode"), AppOptions("BuildID"), AppOptions("DBUserName"), AppOptions("DBPassWord"), AppOptions("CommandLineMode", False)
    End If

clean:
    objUnitTestAPI.TestSessionParameters.Clear ' we clean the session parameters in case we a simple test.
    m_booSessionMode = False
    ' 4.0
    Me.GlobalTDBItem.Parameters.Remove "LOCALSESSIONPATH"
    Me.GlobalTDBItem.Parameters.Remove "LOCALSESSIONNAME"
    
    Exit Function
    
    
SetLocalSessionInfo:
    ' v2.2 - Path the test session name to the command line and  4.0
    Me.GlobalTDBItem.Parameters.Add "LOCALSESSIONPATH", Me.Path, False, ""
    Me.GlobalTDBItem.Parameters.Add "LOCALSESSIONNAME", Me.Name, False, ""
    Me.GlobalTDBItem.Parameters.Add "LOCALSESSIONGUID", Me.ID, False, "" ' pass the guid now too

Return
    
    
ErrMgr:

    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ExecuteTestSession"
    GoTo clean
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function CopyTo(objTDBItemDest As CTDBItem, eMode As TDB_CopyFlags) As Boolean

    On Error GoTo ErrMgr


    If eMode And cfPROPERTIES Then
        
        objTDBItemDest.Initialize Me.ItemType, Me.Path, Me.Name
        Set objTDBItemDest.Parent = Me.Parent
    End If
    If eMode And cfPARAMETERS Then
    
    End If
    If eMode And cfTESTS Then
    
    End If
    CopyTo = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "CopyTo"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Paste(ByVal strName As String) As Boolean

    On Error GoTo ErrMgr


    Dim objItemToPaste As CTDBItem
    Dim objTextFile    As New cTextFile
    
    Set objItemToPaste = Root.Find(strName)
    If (IsValidObject(objItemToPaste)) Then
        
        Paste = objTextFile.FileCopy(objItemToPaste.FullName(), Me.Path & "\" & objItemToPaste.Name)
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Paste"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get ID() As Variant

    On Error GoTo ErrMgr

    ID = m_varID

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ID"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Let ID(ByVal vNewValue As Variant)

    On Error GoTo ErrMgr

     m_varID = vNewValue

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ID"
End Property

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function GetIDFromXMLFile(ByVal strXMLFileName As String, ByRef strID As String) As Boolean

    On Error GoTo ErrMgr


    Dim objTextFile As New cTextFile
    Dim strXML      As String
    Dim lngStartPos As Long
    Dim lngEndPos   As Long
    Dim booRetValue As Boolean
    
    strXML = UCase(objTextFile.LoadFile(strXMLFileName))
    lngStartPos = InStr(strXML, TESTHARNESS_TEST_FILE_XML_ID_TAG)
    If (lngStartPos) Then
        lngStartPos = lngStartPos + Len(TESTHARNESS_TEST_FILE_XML_ID_TAG)
        lngEndPos = InStr(lngStartPos, strXML, "<")
        If (lngEndPos) Then
        
            strID = Mid(strXML, lngStartPos, lngEndPos - lngStartPos)
            booRetValue = True
        End If
    End If
    If (Not booRetValue) Then
        ShowError PreProcess(TESTHARNESS_MESSAGE_7010, "NAME", strXMLFileName)
    End If
    GetIDFromXMLFile = booRetValue

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GetIDFromXMLFile"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function ValidateIntegrity(ByVal booPretend As Boolean) As Boolean

    On Error GoTo ErrMgr

    Dim objChild As CTDBItem
    
    
    If booPretend Then
    
        ValidateIntegrity = True
        Exit Function
    End If

    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
        
        Case TDB_ItemType.TEST_SESSION_ITEM
        
            If (Not ValidateIntegrityTestSession()) Then Exit Function
            
        Case TDB_ItemType.STATIC_FILE_ITEM

    End Select
    
    For Each objChild In Me.Children
    
        If (Not objChild.ValidateIntegrity(booPretend)) Then Exit Function
    Next
    
    ValidateIntegrity = True
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ValidateIntegrity"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function ValidateIntegrityTestSession() As Boolean

    On Error GoTo ErrMgr

    Dim objItem         As CTDBItem
    Dim objTmpItem      As CTDBItem
    Dim objCachedRoot   As CTDBItem
    Dim ParameterInValid As CTDBParameter
    Set objCachedRoot = Root
    
    Dim lngErrorCount As Long
            
    For Each objItem In Me.Tests ' Check the each test associated with the test session is existing in the database.
    
        If Not IsPartOfIntegrityGUIDList(objItem.ID) Then
        
            ShowError PreProcess(TESTHARNESS_ERROR_7006, "TEST_NAME", objItem.Name, "TEST_ID", objItem.ID, "TEST_SESSION_NAME", Me.Caption)
            lngErrorCount = lngErrorCount + 1
        End If
        
        If Not objItem.Parameters.ValidateIntegrity(ParameterInValid) Then
        
            ShowError PreProcess(TESTHARNESS_ERROR_7034, "PARAMETER", ParameterInValid.Name, "TEST_NAME", objItem.Name, "TEST_ID", objItem.ID, "TEST_SESSION_NAME", Me.Caption)
            lngErrorCount = lngErrorCount + 1
        End If
        
'        Set objTmpItem = objCachedRoot.Find(objItem.ID)
'        If (Not IsValidObject(objTmpItem)) Then
'            ShowError PreProcess(TESTHARNESS_ERROR_7006, "TEST_NAME", objItem.Name, "TEST_ID", objItem.ID, "TEST_SESSION_NAME", Me.Caption)
'            Exit Function
'        End If
    Next
    ValidateIntegrityTestSession = CBool(lngErrorCount = 0)

    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ValidateIntegrityTestSession"
End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Free.
' DESCRIPTION   : Free all the COM Instances used by the database, because of circular reference this function must be
'                 called before releasing a CTDBItem.
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function Free() As Boolean

    On Error GoTo ErrMgr


    Dim objChild As CTDBItem
    For Each objChild In Children
    
        objChild.Free
    Next
    Set Parent = Nothing

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Free"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Private Function SaveAsTest() As Boolean

    On Error GoTo ErrMgr


    Dim strXML          As String
    Dim objTest         As CTDBItem
    Dim objParameter    As CTDBParameter
    Dim objTextFile     As New cTextFile
    
    strXML = strXML & "<Test>" & vbNewLine
    
    SaveCommon strXML
    
    strXML = strXML & PreProcess("    <UseParameterNameInCommandLine>[USEPARAMETERNAMEINCOMMANDLINE]</UseParameterNameInCommandLine>", "USEPARAMETERNAMEINCOMMANDLINE", Me.UseParameterNameInCommandLine) & vbNewLine
    strXML = strXML & PreProcess("    <UseGlobalParameterInCommandLine>[USEGLOBALPARAMETERINCOMMANDLINE]</UseGlobalParameterInCommandLine>", "USEGLOBALPARAMETERINCOMMANDLINE", Me.UseGlobalParameterInCommandLine) & vbNewLine
    strXML = strXML & PreProcess("    <Program>[PROGRAM]</Program>", "PROGRAM", Me.Program) & vbNewLine
    strXML = strXML & PreProcess("    <PopUpDefinition>[POPUP]</PopUpDefinition>", "POPUP", PopUpDefinition) & vbNewLine
    
    
    'MsgBox Program
    
    strXML = strXML & "    <Parameters type=""collection"">" & vbNewLine
    
    For Each objParameter In Parameters
    
        strXML = strXML & PreProcess("                <Parameter id=""[NAME]""><value>[VALUE]</value><required>[REQUIRED]</required><enumvalue>[ENUMVALUE]</enumvalue></Parameter>", "NAME", objParameter.Name, "VALUE", objParameter.Value, "REQUIRED", objParameter.Required, "ENUMVALUE", objParameter.EnumValue) & vbNewLine
    Next
    strXML = strXML & "    </Parameters>" & vbNewLine
    strXML = strXML & "</Test>" & vbNewLine
    SaveAsTest = objTextFile.LogFile(FullName, strXML, True)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "SaveAsTest"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Property Get Caption() As String

    On Error GoTo ErrMgr


    Dim objTextFile     As New cTextFile
    Dim strShortName    As String
    
    strShortName = objTextFile.GetFileName(Name)
    
    Select Case ItemType
    
        Case TDB_ItemType.COMPARE_DEF_ITEM
            If (Len(strShortName)) Then Caption = Mid(strShortName, 1, Len(strShortName) - Len(TESTHARNESS_COMPAREDEF_EXTENSION) - 1)
    
    
        Case TDB_ItemType.FOLDER_ITEM
            Caption = PathName()
        
        Case TDB_ItemType.TEST_ITEM
            If (Len(strShortName)) Then Caption = Mid(strShortName, 1, Len(strShortName) - Len(TESTHARNESS_TEST_FILE_EXTENSION) - 1)
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            If (Len(strShortName)) Then Caption = Mid(strShortName, 1, Len(strShortName) - Len(TESTHARNESS_TEST_SESSION_FILE_EXTENSION) - 1)
            
        Case TDB_ItemType.STATIC_FILE_ITEM
            Caption = strShortName
            
        Case TDB_ItemType.GLOBAL_TEST_ITEM
            Caption = Mid(strShortName, 1, Len(strShortName) - Len(TESTHARNESS_TEST_FILE_EXTENSION) - 1)
            
    End Select

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "Caption"
End Property


Private Function UpdateLastSavedInfo() As Boolean

    On Error GoTo ErrMgr

    Dim objWinApi As New cWindows
    LastSavedTime = Now()
    LastSavedComputer = objWinApi.ComputerName()
     LastSavedUserName = objWinApi.UserName()
    UpdateLastSavedInfo = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "UpdateLastSavedInfo"
End Function

Private Function SaveCommon(strXML As String) As Boolean

    On Error GoTo ErrMgr

    strXML = strXML & PreProcess("    <Description>[DESCRIPTION]</Description>", "DESCRIPTION", m_description) & vbNewLine
    strXML = strXML & PreProcess("    <Id>[ID]</Id>", "ID", Me.ID) & vbNewLine
    strXML = strXML & PreProcess("    <LastSavedComputer>[LASTSAVEDCOMPUTER]</LastSavedComputer>", "LASTSAVEDCOMPUTER", Me.LastSavedComputer) & vbNewLine
    strXML = strXML & PreProcess("    <LastSavedUserName>[LASTSAVEDUSERNAME]</LastSavedUserName>", "LASTSAVEDUSERNAME", Me.LastSavedUserName) & vbNewLine
    strXML = strXML & PreProcess("    <LastSavedTime>[LASTSAVEDTIME]</LastSavedTime>", "LASTSAVEDTIME", Me.LastSavedTime) & vbNewLine
    strXML = strXML & PreProcess("    <ReadOnly>[READONLY]</ReadOnly>", "READONLY", Me.ReadOnly) & vbNewLine
    strXML = strXML & PreProcess("    <Flags>[FLAGS]</Flags>", "FLAGS", Me.Flags) & vbNewLine
    SaveCommon = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "SaveCommon"
End Function


Public Function IsValidParameterNameChar(strChar As String) As Boolean

    On Error GoTo ErrMgr

    
    IsValidParameterNameChar = CBool(InStr(ParametersValidChars, UCase(strChar)))

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "IsValidParameterNameChar"
End Function

Public Property Get ParametersValidChars() As String

    On Error GoTo ErrMgr

    If (IsEmpty(static_CTDBItem_StrParametersValidChars)) Then
    
        ParametersValidChars = TESTHARNESS_PARAMETER_VALID_CHARS
    Else
        ParametersValidChars = static_CTDBItem_StrParametersValidChars
    End If

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ParametersValidChars"
End Property

Public Property Let ParametersValidChars(ByVal vNewValue As String)

    On Error GoTo ErrMgr

    static_CTDBItem_StrParametersValidChars = vNewValue

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ParametersValidChars"
End Property

Public Property Get ProgramMacro() As String

    On Error GoTo ErrMgr

    Dim objPreProcessor As MTVBLib.CPreProcessor
    Set objPreProcessor = New MTVBLib.CPreProcessor
    
    ' Insert the absolute path into the path of the object, this allow to define
    objPreProcessor.Add "DB_PATH", Me.Root.Path ' 2004-4-2 This was never used - Fred
    
    ProgramMacro = ProcessEnviron(objPreProcessor.Process(Program))

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ProgramMacro"
End Property


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function IsTestUsed(ByRef strID As String, objOwner As CTDBItem, ByRef strOwnerID As String) As Boolean

    On Error GoTo ErrMgr


    Dim objChild    As CTDBItem
    Dim objTest     As CTDBItem
        
    If (objOwner.ItemType = TEST_SESSION_ITEM) Then
    
        For Each objTest In objOwner.Tests
        
            If (objTest.ID = strID) Then
            
                strOwnerID = objOwner.ID
                IsTestUsed = True
                Exit Function
            End If
        Next
    End If
    For Each objChild In objOwner.Children
    
        If (objChild.IsTestUsed(strID, objChild, strOwnerID)) Then
        
            IsTestUsed = True
            Exit Function
        End If
    Next
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "IsTestUsed"
End Function

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : OutputFileContext
' DESCRIPTION   : Return the unique instance of the output file context
' PARAMETERS    :
' RETURN        :
Public Property Get OutputFileContext() As CTDBOutputFileContext

    On Error GoTo ErrMgr

    Set OutputFileContext = static_DBOutputFileContext

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "OutputFileContext"
End Property

' i beleive this stuff is not used
Public Property Get Stack() As CVariantStack

    On Error GoTo ErrMgr

    If Not IsValidObject(static_Stack) Then
        Set static_Stack = New CVariantStack
    End If
    Set Stack = static_Stack

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "OutputFileContext"
End Property

Private Function TRACE(strMessage) As Boolean

    On Error GoTo ErrMgr


    Dim objUnitTestAPI As Object: Set objUnitTestAPI = GetNewTestApiInstance
    objUnitTestAPI.TRACE strMessage
    TRACE = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "TRACE"
End Function

Public Function ParametersCopy() As CTDBParameters

    On Error GoTo ErrMgr


    Dim objVar              As CTDBParameter
    Dim objParametersCopy   As CTDBParameters
    Set objParametersCopy = New CTDBParameters
    
    For Each objVar In Me.Parameters
    
        objParametersCopy.AddInstance objVar.Clone()
    Next
    Set ParametersCopy = objParametersCopy

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ParametersCopy"
End Function

Public Property Get IniFile() As cIniFile

    Set IniFile = static_MTTestDataBaseIniFile
End Property

Public Property Set IniFile(ByVal vNewValue As cIniFile)

    Set static_MTTestDataBaseIniFile = vNewValue
End Property


Public Property Get AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS") As String

    On Error GoTo ErrMgr

    AppOptions = IniFile.getVar(strSection, strOptionName, strDefaultValue)

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "AppOptions"
End Property

Public Function Explorer() As Boolean

    On Error GoTo ErrMgr
    
    'Dim objTOOL As New cTool
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
            Shell "explorer.exe " & Me.Path(), vbNormalFocus
'
'        Case TDB_ItemType.TEST_ITEM
'            objTOOL.ExecFile Me.FullName
'        Case TDB_ItemType.TEST_SESSION_ITEM
'            objTOOL.ExecFile Me.FullName
'        Case TDB_ItemType.STATIC_FILE_ITEM
'            objTOOL.ExecFile Me.FullName
'        Case TDB_ItemType.GLOBAL_TEST_ITEM
'
    End Select
    Explorer = True
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "SystemOpen"
End Function

Private Function ShowErrorDuplicateIDInDB(strFileName As String, strID As String) As Boolean

    Dim objItemAlreadyLoaded As CTDBItem
    Set objItemAlreadyLoaded = Me.Root.Find(strID)
    ShowError PreProcess(TESTHARNESS_ERROR_7017, "TEST1", objItemAlreadyLoaded.FullName, "TEST2", strFileName)
End Function

Private Function ProcessEnviron(strValue As String) As String

    Dim objPP       As New CPreProcessor
    Dim i           As Long
    Dim strTmp      As String
    Dim lngPOS      As Long
    Dim strResult   As String
    
    On Error GoTo ErrMgr
    
    i = 1
    Do
        On Error Resume Next
        strTmp = ""
        strTmp = Environ(i)
        If (Err) Then Err.Clear
        On Error GoTo ErrMgr
        
        If (Len(strTmp)) Then
        
            lngPOS = InStr(strTmp, "=")
            If (lngPOS) Then
                objPP.Add UCase(Mid(strTmp, 1, lngPOS - 1)), Mid(strTmp, lngPOS + 1)
            End If
        Else
            strResult = objPP.Process(strValue, "%", "%")
            Exit Do
        End If
        i = i + 1
    Loop
    
    strResult = Me.Root.Dictionary.PreProcess(strResult)
    strResult = Replace(strResult, vbNewLine, " ")
    strResult = Replace(strResult, vbCr, " ")
    strResult = Replace(strResult, vbLf, " ")
    ProcessEnviron = strResult
    
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ProcessEnviron"
End Function

Public Property Get DBInfo() As CTDBInfo

    Set DBInfo = static_objDBInfo
End Property

'Public Function CheckForBoundChecker(strScriptingCommand As String) As String
'
'    Dim strBoundCheckerCommand  As String
'    Dim strRetVal               As String
'    Dim objTextFile             As New cTextFile
'
'    CheckForBoundChecker = strScriptingCommand
'
'    If AppOptions("BoundChecker") = "1" Then
'
'        objTextFile.DeleteFile GetBoundCheckFileName
'        strBoundCheckerCommand = AppOptions("BoundCheckerCommandLine")
'        strRetVal = strBoundCheckerCommand & " /b""" & GetBoundCheckFileName() & """ " & strScriptingCommand
'
'        strRetVal = Replace(LCase(strRetVal), "%temp%", Environ("TEMP"))
'        CheckForBoundChecker = strRetVal
'    End If
'End Function
'
'Private Function BoundCheckerShowReport() As Boolean
'
'    Dim t                               As New cTool
'    Dim strParameters                   As String
'    Dim strTmpBacthFile                 As String
'    Dim objTextFile                     As New cTextFile
'
'    If AppOptions("BoundChecker") = "1" And Not m_booSessionMode Then
'        '
'        ' Product the new bound checker dump file
'        '
'        strParameters = "[BCE_DUMP] -e -s -r [DC][TEST_HARNESS_TMP_BCE_FILE][DC] >[DC][BOUNDCHECKER_UNIT_TEST_DUMP_FILE][DC]"
'        strParameters = PreProcess(strParameters, "TEST_HARNESS_TMP_BCE_FILE", GetBoundCheckFileName(), "BOUNDCHECKER_UNIT_TEST_DUMP_FILE", BoundCheckerTmpDumpFileName(), "DC", """", "BCE_DUMP", AppOptions("BoundCheckerDump", "bce_dump.exe"))
'
'        strTmpBacthFile = Environ("TEMP") & "\TestHarness.tmp.bat"
'        objTextFile.LogFile strTmpBacthFile, strParameters, True
'
'        t.execPrgSyncrone Environ("comspec"), "/c " & strTmpBacthFile, vbNormalFocus
'
'
'        '
'        ' Compare the dump files
'        '
'        If objTextFile.ExistFile(BoundCheckerDumpFileName()) Then
'
'            If objTextFile.LoadFile(BoundCheckerDumpFileName()) <> objTextFile.LoadFile(BoundCheckerTmpDumpFileName()) Then
'
'                ShowError PreProcess(TESTHARNESS_MESSAGE_7021, "CRLF", vbNewLine, "NAME", Me.Name), TypeName(Me), "BoundCheckerShowReport"
'            End If
'        Else
'            ShowError PreProcess(TESTHARNESS_MESSAGE_7020, "NAME", Me.Name), TypeName(Me), "BoundCheckerShowReport"
'        End If
'
'        ' Open the Bound Checker Report Mode
'        If AppOptions("BoundCheckerShowReport") = "1" Then t.execPrgSyncrone AppOptions("BoundCheckerReportViewer"), """" & GetBoundCheckFileName() & """", vbNormalFocus
'    End If
'    BoundCheckerShowReport = True
'End Function
'
'Private Function GetBoundCheckFileName() As String
'
'    Dim strFileName As String
'    Dim objTextFile As New cTextFile
'
'    strFileName = objTextFile.GetFileName(Me.FullName)
'
'    GetBoundCheckFileName = Environ("TEMP") & "\TestHarness.tmp.bce"
'End Function
'
'Private Function BoundCheckerDumpFileName() As String
'    BoundCheckerDumpFileName = Me.FullName & ".boundchecker.dump.txt"
'End Function
'
'Private Function BoundCheckerTmpDumpFileName() As String
'    BoundCheckerTmpDumpFileName = Environ("TEMP") & "\" & Me.Name & ".boundchecker.dump.txt"
'End Function

'<Test>
'    <Description></Description>
'    <Id>{D86AF28B-BD40-4FB8-91D7-735147FE7662}</Id>
'    <LastSavedComputer>CHARLIE</LastSavedComputer>
'    <LastSavedUserName>amarshall</LastSavedUserName>
'    <LastSavedTime>11/29/2001 5:05:35 PM</LastSavedTime>
'    <ReadOnly>False</ReadOnly>
'    <Flags>1</Flags>
'    <UseParameterNameInCommandLine>True</UseParameterNameInCommandLine>
'    <UseGlobalParameterInCommandLine>True</UseGlobalParameterInCommandLine>
'    <Program>W3Runner.exe</Program>
'    <Parameters type="collection">
'                <Parameter id="function"><value>TC5_MCM</value></Parameter>
'                <Parameter id="file"><value>%METRATECHTESTDATABASE%\QA\Integration Tests\BCRelative\MCM_BCR_CYCLE_Annual.vbs</value></Parameter>
'    </Parameters>
'</Test>

' This is a very dum xml parser,  and now in 2004-4 that i want to add an optional tag for the parameters, which may be there of not on one parameters
' but my there for the next one, I am stuck...
Private Function ReadXMLTag(ByRef lngCPOS As Long, strUCaseXML As String, strXML As String, ByVal strTag As String, Optional strAttribute As String, Optional ByVal varDefaultValue As Variant) As Variant
    
    Dim lngPosEnd   As Long
    Dim lngPOS      As Long
    
    lngPOS = lngCPOS
    
    If Len(strAttribute) Then
    
        strTag = UCase$("<" & strTag & " ")
        lngPOS = InStr(lngPOS, strUCaseXML, strTag) ' Find "<Parameter "
        If lngPOS Then
            lngPOS = InStr(lngPOS, strUCaseXML, UCase$(strAttribute) & "=""") ' from there find id=
            If lngPOS Then
                lngPOS = lngPOS + Len(strAttribute & "=""")
                lngPosEnd = InStr(lngPOS, strUCaseXML, """") ' from there find id=
                ReadXMLTag = Trim(Mid(strXML, lngPOS, lngPosEnd - lngPOS))
                lngCPOS = lngPosEnd
            End If
        End If
    Else
    
        strTag = UCase$("<" & strTag & ">")
        lngPOS = InStr(lngPOS, strUCaseXML, strTag)
        
        If lngPOS Then
        
            lngPOS = lngPOS + Len(strTag)
            
            lngPosEnd = InStr(lngPOS, strUCaseXML, "<")
            
            If lngPosEnd Then
            
                ReadXMLTag = Trim(Mid(strXML, lngPOS, lngPosEnd - lngPOS))
                
                lngCPOS = lngPosEnd
            End If
        Else
            If IsMissing(varDefaultValue) Then varDefaultValue = Empty
            ReadXMLTag = varDefaultValue ' return a default value added in 3.5
        End If
    End If
End Function


Private Function CheckXMLNextTagExist(ByVal lngCPOS As Long, strUCaseXML As String, strXML As String, ByVal strTag As String, Optional strAttribute As String) As Boolean
    
    Dim lngNewPos As Long
    
    strTag = UCase$("<" & strTag & ">")
    lngNewPos = InStr(lngCPOS, strUCaseXML, strTag)
    
    CheckXMLNextTagExist = CBool(lngNewPos = lngCPOS)

End Function



 
' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function LoadTestSessionInfo(ByVal booReadTestsList As Boolean) As Boolean
    
    On Error GoTo ErrMgr

    Dim objTextFile             As New cTextFile
    Dim strUCaseXML             As String
    Dim lngPOS                  As Long
    Dim lngEndPos               As Long
    Dim strTestID               As String
    Dim strParameterName        As String
    Dim strParameterValue       As String
    Dim strXML                  As String
    Dim objTest                 As CTDBItem
    Dim strUCaseXMLbu           As String
    Dim strXMLbu                As String
    Dim lngCharCount            As Long
    Dim strParameterRequired    As String
    Dim strParameterEnumValue   As String
    Dim objTmpParam             As CTDBParameter
        
    Const LenXMLEndTagTest = 7
    Const XMLEndTagTest = "</Test>"
    
    Me.DBInfo.TestSessionInitializationCounter = Me.DBInfo.TestSessionInitializationCounter + 1
    
    If InStr(Me.FullName, "PS Standard Test Session.SESSION") Then
'        Debug.Assert 0
    End If
    
    

    strXML = objTextFile.LoadFile(Me.FullName)
    strUCaseXML = UCase$(strXML)
    lngPOS = 1
    
    Description = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Description")
    ID = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Id")
    LastSavedComputer = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedComputer")
    LastSavedUserName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedUserName")
    LastSavedTime = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedTime")
    ReadOnly = ReadXMLTag(lngPOS, strUCaseXML, strXML, "ReadOnly")
    Flags = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Flags")
    chkSendEmail = ReadXMLTag(lngPOS, strUCaseXML, strXML, "chkSendEmail")
    
    If booReadTestsList Then
    
        Do  'Tests Loop
            
            strTestID = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Test", "Id")
            If Len(strTestID) Then
            
                strUCaseXMLbu = strUCaseXML ' Backup the XML because we going to alter it to parse one set of parameter at the time
                strXMLbu = strXML

                lngEndPos = InStr(lngPOS, strXML, XMLEndTagTest) ' Get only the current last test xml
                lngCharCount = Len(strXML) - lngEndPos + LenXMLEndTagTest
                
                Mid(strXML, lngEndPos + Len(XMLEndTagTest), lngCharCount) = Space(lngCharCount)
                
                strUCaseXML = UCase$(strXML)
                
                Set objTest = Me.Tests.Add(strTestID, True)

                objTest.Name = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Name")
                
                If CBool(InStr(objTest.Name, ",")) Then
            
                    ShowError PreProcess(TESTHARNESS_ERROR_7052, "TEST", objTest.Name, "SESSION", Me.Name), Me, "LoadTestSessionInfo"
                End If
                
                objTest.ContinueTestSessionIfFailed = ReadXMLTag(lngPOS, strUCaseXML, strXML, "ContinueTestSessionIfFailed")
                objTest.UseParameterNameInCommandLine = ReadXMLTag(lngPOS, strUCaseXML, strXML, "UseParameterNameInCommandLine")
                objTest.UseGlobalParameterInCommandLine = ReadXMLTag(lngPOS, strUCaseXML, strXML, "UseGlobalParameterInCommandLine")
                objTest.SkipTestInSession = ReadXMLTag(lngPOS, strUCaseXML, strXML, "SkipTestInSession", , False)
                
                ' Added in 4.0
                ' We should test if the tag exist first - so far it is ok because there is no such a tag in the parameter definition
                objTest.IsSessionInSession = ReadXMLTag(lngPOS, strUCaseXML, strXML, "IsSessionInSession", , False)
                If objTest.IsSessionInSession Then objTest.ItemType = TEST_SESSION_ITEM
                           
                Do ' Parameters Loop
                
                    strParameterRequired = "TRUE" ' Default value in case the tag is not defined
                    strParameterEnumValue = ""
                    strParameterName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Parameter", "Id")
                    If Len(strParameterName) Then
                    
                        strParameterValue = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Value")
                        lngPOS = lngPOS + Len("Value") + 3
                        
                        If CheckXMLNextTagExist(lngPOS, strUCaseXML, strXML, "required") Then
                        
                            strParameterRequired = ReadXMLTag(lngPOS, strUCaseXML, strXML, "required")
                            lngPOS = lngPOS + Len("required") + 3
                        End If
                        If CheckXMLNextTagExist(lngPOS, strUCaseXML, strXML, "enumvalue") Then
                        
                            strParameterEnumValue = ReadXMLTag(lngPOS, strUCaseXML, strXML, "enumvalue")
                            lngPOS = lngPOS + Len("enumvalue") + 3
                        End If
                        Set objTmpParam = objTest.Parameters.Add(strParameterName, strParameterValue, CBool(strParameterRequired), strParameterEnumValue)
                    Else
                        Exit Do
                    End If
                Loop
                strUCaseXML = strUCaseXMLbu
                strXML = strXMLbu
            Else
                Exit Do
            End If
        Loop
    End If
    LoadTestSessionInfo = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString() & vbNewLine & "Session:" & Me.FullName, "CTDBItem", "LoadTestSessionInfo"
End Function

Public Property Get ShowStaticFile() As Boolean
    ShowStaticFile = g_static_booShowStaticFile
End Property

Public Property Let ShowStaticFile(ByVal vNewValue As Boolean)
    g_static_booShowStaticFile = vNewValue
End Property

Public Property Get MainForm() As Variant
    Set MainForm = g_static_booMainForm
End Property

Public Property Set MainForm(ByVal vNewValue As Variant)
    Set g_static_booMainForm = vNewValue
End Property

Private Function FolderMustBeIgnored() As Boolean

    Dim vPath           As Variant
    Dim strUCasePath    As String
    
    strUCasePath = UCase$(Me.Path)
    
    If IsEmpty(m_static_arrayPathsToIgnore) Then Exit Function
    
    For Each vPath In m_static_arrayPathsToIgnore
    
        If UCase$(vPath) = strUCasePath Then
        
            FolderMustBeIgnored = True
            Exit Function
        End If
    Next
End Function


Public Function ValidTestName(ByRef strTestName As String) As Boolean

    strTestName = Replace(strTestName, ",", " ")
    ValidTestName = True
End Function

Private Function IsPartOfIntegrityGUIDList(strGuid As String) As Boolean

    On Error Resume Next
    Dim v As Variant
    v = g_static_IntegrityGUIDList.Item(strGuid)
    IsPartOfIntegrityGUIDList = Err.Number = 0
    Err.Clear
End Function

Private Function IntegrityGUIDListAdd(strGuid As String) As Boolean

    On Error Resume Next
    g_static_IntegrityGUIDList.Add 1, strGuid
    IntegrityGUIDListAdd = Err.Number = 0
    Err.Clear
End Function



Public Function LogStartResult() As Boolean

    Dim objUnitTestAPI As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    
    Dim strParameterString As String ' Not used here...

    Dim mode As LOG_RESULT_MODE
    
    mode = LOG_RESULT_MODE_START
    
    Select Case ItemType
    
        Case TDB_ItemType.TEST_ITEM, TDB_ItemType.COMPARE_DEF_ITEM
        
            LogIntoMTLOGTestStartOrEnd True
        
            mode = mode + LOG_RESULT_MODE_TEST
            LogStartResult = True
            Exit Function ' The Start Test is logged by the VBScript CTest Class not by the test harness. So the mecanism works also from the command line
            
        Case TDB_ItemType.TEST_SESSION_ITEM
            
            If SessionContainsSession() Then
            
                mode = mode + LOG_RESULT_MODE_SUPER_SESSION
            Else
                mode = mode + LOG_RESULT_MODE_SESSION
            End If
    End Select
    objUnitTestAPI.LogResult Me.Name, True, Now(), Now(), "", mode, strParameterString
    LogStartResult = True
End Function


Private Function LogIntoMTLOGTestStartOrEnd(booStart As Boolean, Optional ByVal booStatus) As Boolean


        If booStart Then
            MTGlobal_VB_MSG.TRACE "", , , LOG_INFO
            MTGlobal_VB_MSG.TRACE PreProcess(TESTHARNESS_MESSAGE_7058, "TEST", Me.Name), , , LOG_INFO
            MTGlobal_VB_MSG.TRACE "", , , LOG_INFO
        Else
            MTGlobal_VB_MSG.TRACE "", , , LOG_INFO
            MTGlobal_VB_MSG.TRACE PreProcess(TESTHARNESS_MESSAGE_7059, "TEST", Me.Name, "STATUS", IIf(booStatus, "[SUCCEED]", "[FAILED]")), , , LOG_INFO
            MTGlobal_VB_MSG.TRACE "", , , LOG_INFO
        End If
End Function

Public Function CopyTextInfoToClipBoard() As Boolean

On Error GoTo ErrMgr

    Dim i As CTDBItem
    Dim p As CVariable
    
    Set m_Text = New cStringConcat
    m_Text.Init 16384
    m_Text.AutomaticCRLF = True
    
'    AddToText "Session:" & Me.Name, True
 '   AddToText "Path:" & Me.Path
  '  AddToText "Tests:", True
    
    For Each i In Me.Tests
        
        AddToText "Test:" & i.Caption, True, 4
        
        AddToText "Comment   :" & vbNewLine, , 8
        AddToText "Parameters:" & vbNewLine, , 8
        
        For Each p In i.Parameters
        
            AddToText MakeString(p.Name, 32), , 12
            AddToText "Value  :" & p.Value, , 16
            AddToText "Comment:", , 16
            AddToText ""
        Next
        AddToText ""
    Next
    Clipboard.Clear
    Clipboard.SetText m_Text.GetString()
    
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "CopyTextInfoToClipBoard"
End Function


Private Function AddToText(ByVal strText As String, Optional ByVal booUnderLine As Boolean, Optional ByVal lngIndent As Long) As Boolean
   
    m_Text.Concat String(lngIndent, " ") & strText
    If booUnderLine Then
    
        m_Text.Concat String(lngIndent, " ") & String(Len(strText), "-")
        m_Text.Concat ""
    End If
    
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "AddToText"
End Function

Public Function BuildInterSectionParameters(ByVal strLongIDsCSV As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim t               As CTDBItem
    Dim p               As CTDBParameter
    Dim TestsSelected   As CTDBItems
    Dim booLoop         As Boolean
    
'    Debug.Assert 0
    
    Set m_InterSectionParameters = New CTDBParameters
    Set TestsSelected = BuildTestsCollection(strLongIDsCSV)
      
    ' for each parameters count how many time it it reference, store the counter in the tag fields
    ' I also store the parameters value
    ' I will need a value to display.
    For Each t In TestsSelected
    
         For Each p In t.Parameters
            
            If m_InterSectionParameters.Exist(p.Name) Then
            
                m_InterSectionParameters.Item(p.Name).Required = m_InterSectionParameters.Item(p.Name).Required Or p.Required ' Carry the required info, if one is true all are true
                m_InterSectionParameters.Item(p.Name).Tag = m_InterSectionParameters.Item(p.Name).Tag + 1
            Else
                Set p = m_InterSectionParameters.Add(p.Name, p.Value, p.Required, p.EnumValue)
                p.Tag = 1
            End If
         Next
    Next
    
    booLoop = True
    Do While booLoop
    
        booLoop = False
        
        For Each p In m_InterSectionParameters
        
            If p.Tag <> TestsSelected.Count Then ' The parameters is not present in all the selected test
            
                m_InterSectionParameters.Remove p.Name, , True
                booLoop = True
                Exit For
            End If
        Next
    Loop
    BuildInterSectionParameters = True
Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "BuildInterSectionParameters"
End Function

Private Function BuildTestsCollection(ByVal strLongIDsCSV As String) As CTDBItems
    
    Dim t           As CTDBItem
    Dim objSubTests As New CTDBItems
    
    On Error GoTo ErrMgr
    
    strLongIDsCSV = "," & strLongIDsCSV & ","
    
    For Each t In Me.Tests
    
        If CBool(InStr(strLongIDsCSV, "," & t.LongID & ",")) Then
        
            objSubTests.AddTestToSession t
        End If
    Next
    Set BuildTestsCollection = objSubTests
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "BuildTestsCollection"
End Function

Public Property Get InterSectionParameters() As CTDBParameters

    Set InterSectionParameters = m_InterSectionParameters
End Property


Public Function SetParameter(ByVal strLongIDsCSV As String, Parameter As CTDBParameter) As Boolean
    
    Dim t               As CTDBItem
    Dim TestsSelected   As CTDBItems
    Dim booLoop         As Boolean
    
    On Error GoTo ErrMgr
    
    Set TestsSelected = BuildTestsCollection(strLongIDsCSV)
   
    For Each t In TestsSelected
         
        If t.Parameters.Exist(Parameter.Name) Then
        
            t.Parameters.Item(Parameter.Name).CopyFrom Parameter
            
        Else
        
            t.Parameters.AddInstance Parameter
        End If
    Next
    SetParameter = True
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "SetParameter"
End Function


Public Function RemoveParameter(ByVal strLongIDsCSV As String, strName As String) As Boolean
    
    Dim t               As CTDBItem
    Dim p               As CVariable
    Dim TestsSelected   As CTDBItems
    Dim booLoop         As Boolean
    
    On Error GoTo ErrMgr
    
    Set TestsSelected = BuildTestsCollection(strLongIDsCSV)
   
    For Each t In TestsSelected
        
        t.Parameters.Remove strName
    Next
    RemoveParameter = True
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "RemoveParameter"
End Function


Public Function SkipUnSkip(ByVal strLongIDsCSV As String) As Boolean
    
    Dim t               As CTDBItem
    Dim TestsSelected   As CTDBItems
    Dim booNewSkipStatus As Boolean
    

    
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
    
    
    
    Set TestsSelected = BuildTestsCollection(strLongIDsCSV)
    booNewSkipStatus = Not TestsSelected.Item(1).SkipTestInSession
   
    For Each t In TestsSelected
        t.SkipTestInSession = booNewSkipStatus
    Next
    SkipUnSkip = True
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "SkipUnSkip"
End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function LoadTestInfo() As Boolean
'<Test>
'    <Description></Description>
'    <Id>{0539DCA4-1AEF-4E64-AC3A-AB30C305AD53}</Id>
'    <LastSavedComputer>F-TORRES2</LastSavedComputer>
'    <LastSavedUserName>ftorres</LastSavedUserName>
'    <LastSavedTime>2/25/2002 3:21:35 PM</LastSavedTime>
'    <ReadOnly>False</ReadOnly>
'    <Flags>1</Flags>
'    <UseParameterNameInCommandLine>True</UseParameterNameInCommandLine>
'    <UseGlobalParameterInCommandLine>True</UseGlobalParameterInCommandLine>
'    <Program>createpoppuri.vbs</Program>
'    <Parameters type="collection">
'    </Parameters>
'</Test>

'<Test>
'    <Description></Description>
'    <Id>{D86AF28B-BD40-4FB8-91D7-735147FE7662}</Id>
'    <LastSavedComputer>CHARLIE</LastSavedComputer>
'    <LastSavedUserName>amarshall</LastSavedUserName>
'    <LastSavedTime>11/29/2001 5:05:35 PM</LastSavedTime>
'    <ReadOnly>False</ReadOnly>
'    <Flags>1</Flags>
'    <UseParameterNameInCommandLine>True</UseParameterNameInCommandLine>
'    <UseGlobalParameterInCommandLine>True</UseGlobalParameterInCommandLine>
'    <Program>W3Runner.exe</Program>
'    <Parameters type="collection">
'                <Parameter id="function"><value>TC5_MCM</value></Parameter>
'                <Parameter id="file"><value>%METRATECHTESTDATABASE%\QA\Integration Tests\BCRelative\MCM_BCR_CYCLE_Annual.vbs</value></Parameter>
'    </Parameters>
'</Test>


    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim strUCaseXML                 As String
    Dim lngPOS                      As Long
    Dim strParameterName            As String
    Dim strParameterValue           As String
    Dim strXML                      As String
    Dim strParameterRequired        As String
    Dim strParameterEnumValue       As String
    Dim objTmpParam                 As CTDBParameter


If InStr(UCase$(Me.FullName), UCase$("Test 1.TEST")) Then
'    Debug.Assert 0
End If

    Me.DBInfo.TestInitializationCounter = Me.DBInfo.TestInitializationCounter + 1

    strXML = objTextFile.LoadFile(Me.FullName)
    strUCaseXML = UCase$(strXML)
    lngPOS = 1
    Description = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Description")
    ID = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Id")
    LastSavedComputer = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedComputer")
    LastSavedUserName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedUserName")
    LastSavedTime = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedTime")
    ReadOnly = ReadXMLTag(lngPOS, strUCaseXML, strXML, "ReadOnly")
    Flags = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Flags")
    UseParameterNameInCommandLine = ReadXMLTag(lngPOS, strUCaseXML, strXML, "UseParameterNameInCommandLine")
    UseGlobalParameterInCommandLine = ReadXMLTag(lngPOS, strUCaseXML, strXML, "UseGlobalParameterInCommandLine")
    Program = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Program")
    PopUpDefinition = ReadXMLTag(lngPOS, strUCaseXML, strXML, "PopUpDefinition")
    
    

    Do
        strParameterRequired = "TRUE" ' Default value in case the tag is not defined
        strParameterEnumValue = ""

        strParameterName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Parameter", "Id")
        
        If Len(strParameterName) Then
        
            strParameterValue = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Value")
            lngPOS = lngPOS + Len("Value") + 3
            
            If CheckXMLNextTagExist(lngPOS, strUCaseXML, strXML, "required") Then
            
                strParameterRequired = ReadXMLTag(lngPOS, strUCaseXML, strXML, "required")
                lngPOS = lngPOS + Len("required") + 3
            End If
            If CheckXMLNextTagExist(lngPOS, strUCaseXML, strXML, "enumvalue") Then
            
                strParameterEnumValue = ReadXMLTag(lngPOS, strUCaseXML, strXML, "enumvalue")
                lngPOS = lngPOS + Len("enumvalue") + 3
            End If
            Set objTmpParam = Me.Parameters.Add(strParameterName, strParameterValue, CBool(strParameterRequired), strParameterEnumValue)
            
        Else
            Exit Do
        End If
    Loop
    LoadTestInfo = True
    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadTestSession"
End Function

'
'
'' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'' FUNCTION      :
'' DESCRIPTION   :
'' PARAMETERS    :
'' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
'Public Function LoadTestInfo() As Boolean
'
'    On Error GoTo ErrMgr
'
'    Dim objLoader       As XMLLoader
'    Dim objTranslate    As New CVariables
'
'    objTranslate.Add "test", "CTDBItem"
'    objTranslate.Add "Parameters", "CTDBParameters"
'    objTranslate.Add "Parameter", "CTDBParameter"
'
'    Set objLoader = New XMLLoader
'    LoadTestInfo = objLoader.LoadObjectModelData(Me, FullName, objTranslate, "test")
'
'    Exit Function
'ErrMgr:
'        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadTestInfo"
'End Function



' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function ExportDescriptionToTextFile(ParentForm As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim objChild As CTDBItem
    Dim f As New cTextFile
    Dim strText As String
    

    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
        
        Case TDB_ItemType.TEST_SESSION_ITEM
        
            If Len(m_description) Then
            
                ParentForm.user "WARNING:ExportDescriptionToTextFile()-" & DescriptionTextFile
                strText = "[DESCRIPTION]" & vbNewLine & m_description & vbNewLine & "[END]"
                f.LogFile DescriptionTextFile, strText, True
                Debug.Print DescriptionTextFile
                m_description = ""
                Me.Save

            End If
        Case TDB_ItemType.STATIC_FILE_ITEM

    End Select
    
    For Each objChild In Me.Children
    
        If (Not objChild.ExportDescriptionToTextFile(ParentForm)) Then Exit Function
    Next
    ExportDescriptionToTextFile = True
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ExportDescriptionToTextFile"
End Function

Public Property Get DescriptionTextFile() As String

    Dim strFile As String
    strFile = Me.FullName
    
    'strFile = Mid$(strFile, 1, Len(strFile) - Len(TESTHARNESS_TEST_SESSION_FILE_EXTENSION))
    strFile = strFile & ".Description"
    
    DescriptionTextFile = strFile
    
End Property



Public Function LoadCompareDefnfo() As Boolean
'<CompareDef>
'    <Description>This is my first compare def object</Description>
'    <Id>{FE5D9267-CD25-461C-BB06-66C61D62514353423A45}</Id>
'    <LastSavedComputer>W2KADVSVR</LastSavedComputer>
'    <LastSavedUserName>Administrator</LastSavedUserName>
'    <LastSavedTime>4/23/2004 3:27:34 PM</LastSavedTime>
'    <ReadOnly>False</ReadOnly>
'    <Flags>1</Flags>
'    <PropertyBagName>
'    <ResultFolder>
'    <SQLQuery>
'</CompareDef>


    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    Dim strUCaseXML                 As String
    Dim lngPOS                      As Long
    Dim strParameterName            As String
    Dim strParameterValue           As String
    Dim strXML                      As String
    Dim strParameterRequired        As String
    Dim strParameterEnumValue       As String
    Dim objTmpParam                 As CTDBParameter


    Me.DBInfo.TestInitializationCounter = Me.DBInfo.TestInitializationCounter + 1

    strXML = objTextFile.LoadFile(Me.FullName)
    strUCaseXML = UCase$(strXML)
    lngPOS = 1
    Description = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Description")
    ID = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Id")
    LastSavedComputer = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedComputer")
    LastSavedUserName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedUserName")
    LastSavedTime = ReadXMLTag(lngPOS, strUCaseXML, strXML, "LastSavedTime")
    ReadOnly = ReadXMLTag(lngPOS, strUCaseXML, strXML, "ReadOnly")
    Flags = ReadXMLTag(lngPOS, strUCaseXML, strXML, "Flags")
    
    PropertyBagName = ReadXMLTag(lngPOS, strUCaseXML, strXML, "PropertyBagName")
    ResultFolder = ReadXMLTag(lngPOS, strUCaseXML, strXML, "ResultFolder")
    SQLQuery = ReadXMLTag(lngPOS, strUCaseXML, strXML, "SQLQuery")
    
    LoadCompareDefnfo = True
    Exit Function
ErrMgr:

        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadCompareDefnfo"
End Function



Private Function ExecuteCompareDef(Optional booCopyCommandLine As Boolean = False) As Boolean

    On Error GoTo ErrMgr

    Dim objTOOL         As New cTool
    Dim eWindowStatus   As VbAppWinStyle
    Dim objUnitTestAPI  As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    Dim strCommandLine  As String
    Dim objTextFile     As New cTextFile
    Dim strTmpBatFile   As String
    
    
    If booCopyCommandLine Then
    
        Clipboard.Clear
        strCommandLine = "Not implemented yet"
        Clipboard.SetText strCommandLine
    Else
    
        OutputFileContext.Save Me.ID, Me.ItemType
        
        ' for now simulate that the compare succeed
        objUnitTestAPI.LogResult Me.Name, True, Now(), Now(), "", LOG_RESULT_MODE.LOG_RESULT_MODE_COMPAREDEF


        '  THIS PART NEED TO BE REFACTOR AS IT IS DUPLICATED IN ExecuteTest
        Select Case OutputFileContext.Read(AppOptions("ShowMessageIfTestFail", True), AppOptions("RecordModeOn", False), AppOptions("DatabaseRecordMode"), AppOptions("SQLServerRecodMode"), AppOptions("BuildID"), AppOptions("DBUserName"), AppOptions("DBPassWord"), UCase(AppOptions("CommandLineMode")) = "TRUE")
        
            Case OUTPUT_FILE_CONTEXT_FILE_FAILED
                ExecuteCompareDef = False
                
            Case OUTPUT_FILE_CONTEXT_FILE_OK
                ExecuteCompareDef = True
                
            Case OUTPUT_FILE_CONTEXT_FILE_NOT_FOUND
                ShowError PreProcess(TESTHARNESS_ERROR_7025, "FILENAME", OutputFileContext.FileName), TypeName(Me), "ExecuteCompareDef"
                
            Case OUTPUT_FILE_CONTEXT_FILE_DID_NOT_CHANGED
                ShowError PreProcess(TESTHARNESS_ERROR_7024, "NAME", Me.Name), TypeName(Me), "ExecuteCompareDef"
                
            Case OUTPUT_FILE_CONTEXT_FILE_UNKNOWN
                ShowError PreProcess(TESTHARNESS_ERROR_7026, "NAME", Me.Name), TypeName(Me), "ExecuteCompareDef"
        End Select
    End If
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ExecuteCompareDef"
        
End Function

Public Property Get Description() As String

    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
        
            'If GetProgramType() = VBScript Then
            
                Description = DescriptionParser.Description
                Exit Property
            'End If
            
        Case TDB_ItemType.TEST_SESSION_ITEM
                Description = DescriptionParser.Description
                Exit Property
                
        Case TDB_ItemType.STATIC_FILE_ITEM
    End Select
    
    Description = m_description
End Property

Public Property Let Description(v As String)

    m_description = v
End Property



Public Function GetExternalDescriptionFileName() As String

    GetExternalDescriptionFileName = Me.FullName & ".description"  ' if we have a description file
End Function

Public Property Get DescriptionFileName() As String

    Dim strCommentFile  As String
    Dim f               As New cTextFile
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
            strCommentFile = Me.Path & "\ReadMe.Txt"
        
        Case TDB_ItemType.TEST_ITEM
        
            strCommentFile = GetExternalDescriptionFileName()
            If f.ExistFile(strCommentFile) Then
                
            Else
                If GetProgramType() = VBScript Then
                
                    strCommentFile = Me.FullProgramName(False)
                    
                ElseIf GetProgramType() = EXE Then
                
                    If UCase$(Program) = "W3RUNNER.EXE" Then
                    
                        If Me.Parameters.Exist("file") Then
                        
                            strCommentFile = ProcessEnviron(Me.Parameters.Item("file").Value)
                        End If
                    End If
                Else
                    strCommentFile = Me.FullName & ".description" ' if we have a description file
                End If
            End If
                    
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            strCommentFile = GetExternalDescriptionFileName()
                
        Case TDB_ItemType.STATIC_FILE_ITEM
    End Select
    
    DescriptionFileName = strCommentFile
End Property


Public Property Get DescriptionParser() As MetraTech_QA_TestHarness_CommentParser.IDescriptionParser

    Set m_DescriptionParser = Nothing
    
    Dim v As Variant
    Dim e As String
    Dim f As New cTextFile
    Dim strCommentFile As String
    
    If Not IsValidObject(m_DescriptionParser) Then
    
        Set m_DescriptionParser = New MetraTech_QA_TestHarness_CommentParser.CDescriptionParser
        
        strCommentFile = DescriptionFileName
        
        If f.ExistFile(strCommentFile) Then
        
            If Not m_DescriptionParser.ReadFile(strCommentFile) Then
            
                If m_DescriptionParser.Errors.Count > 0 Then
                
                    For Each v In m_DescriptionParser.Errors
                    
                        e = e & v & vbNewLine
                    Next
                    
                    ShowError PreProcess(TESTHARNESS_ERROR_7035, "ERRORS", m_DescriptionParser.Errors.Count, "FILE", strCommentFile, "ERRORSMSG", e, "CRLF", vbNewLine), Me, "DescriptionParser"
                    
                    Set m_DescriptionParser = Nothing ' Clear it so we can reload the file next time
                    Set DescriptionParser = m_DescriptionParser
                    Exit Property
                End If
            End If
        End If
    End If
    Set DescriptionParser = m_DescriptionParser
End Property


Public Function DescriptionParserRefresh() As Boolean

    Set m_DescriptionParser = Nothing
    DescriptionParserRefresh = True
End Function


Public Function ReLoad() As Boolean

    On Error GoTo ErrMgr

    
  Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
            ReLoad = ReloadTest
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            ReLoad = ReloadSession()
            
        Case TDB_ItemType.STATIC_FILE_ITEM

    End Select
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ReLoad"
End Function

Private Function ReloadTest() As Boolean

'Debug.Assert 0
    Set Children = Nothing
    Set m_Tests = Nothing
    Set m_Parameters = Nothing
    ReloadTest = Me.Initialize(Me.ItemType, Path, Name, False, False, False)
End Function

Private Function ReloadSession() As Boolean

'Debug.Assert 0
    Set Children = Nothing
    Set m_Tests = Nothing
    Set m_Parameters = Nothing
    ReloadSession = Me.Initialize(Me.ItemType, Path, Name, False, False, False)
End Function

Public Property Get Children() As CTDBItems

    If Not IsValidObject(m_Children) Then
        Set m_Children = New CTDBItems
    End If
    Set Children = m_Children
End Property

Public Property Set Children(ByVal vNewValue As CTDBItems)

    Set m_Children = vNewValue
End Property

Public Property Get Parameters() As CTDBParameters

    If Not IsValidObject(m_Parameters) Then
        Set m_Parameters = New CTDBParameters
        Set m_Parameters.Parent = Me
    End If
    Set Parameters = m_Parameters
End Property

'Public Property Set Parameters(ByVal vNewValue As CTDBParameters)
'
'    Set m_Parameters = vNewValue
'End Property


Public Property Get Tests() As CTDBItems

    If Not IsValidObject(m_Tests) Then
    
        Set m_Tests = New CTDBItems
    End If
    Set Tests = m_Tests
End Property



Public Function CloneAs(strNewTestName As String) As Boolean

    On Error GoTo ErrMgr

    Dim NewObect As CTDBItem
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
            Set NewObect = Me.Clone(False, False)
            NewObect.Name = strNewTestName & "." & TESTHARNESS_TEST_FILE_EXTENSION
            
            NewObect.Save
        
        Case TDB_ItemType.TEST_SESSION_ITEM
            
        Case TDB_ItemType.STATIC_FILE_ITEM

    End Select
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CloneAs", "ReLoad"
End Function


Public Function ContinueDoNotContinueTestSessionIfFailed(ByVal strLongIDsCSV As String) As Boolean
    
    Dim t               As CTDBItem
    Dim TestsSelected   As CTDBItems
    Dim booNewSkipStatus As Boolean
        
    On Error GoTo ErrMgr
    
'    Debug.Assert 0
        
    Set TestsSelected = BuildTestsCollection(strLongIDsCSV)
    booNewSkipStatus = Not TestsSelected.Item(1).ContinueTestSessionIfFailed
   
    For Each t In TestsSelected
    
        t.ContinueTestSessionIfFailed = booNewSkipStatus
    Next
    ContinueDoNotContinueTestSessionIfFailed = True
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), Me, "ContinueDoNotContinueTestSessionIfFailed"
End Function





' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function EditDescription(strEditor As String) As Boolean
  
    On Error GoTo ErrMgr

    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM

            EditDescription = EditTestDescription(strEditor)
        
        Case TDB_ItemType.TEST_ITEM
        
            EditDescription = EditTestDescription(strEditor)
        
        Case TDB_ItemType.TEST_SESSION_ITEM
        
            EditDescription = EditSessionDescription(strEditor)
            
        Case TDB_ItemType.STATIC_FILE_ITEM
    End Select
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "EditDescription"
End Function

Public Function EditSessionDescription(strEditor As String) As Boolean

    On Error GoTo ErrMgr

    Dim t           As New cTextFile
    Dim strCommand  As String
    Dim s           As String
    Dim w           As New cWindows
    Dim pp          As New CPreProcessor
    Dim tool        As New cTool
    
    If Not t.ExistFile(DescriptionFileName) Then
    
        pp.Add "CRLF", vbCrLf
        pp.Add "AUTHOR", w.UserName
        pp.Add "CREATIONDATE", Now()
        s = pp.Process(TESTHARNESS_MESSAGE_7035, "%", "%")
        t.LogFile DescriptionFileName, s, True
    End If
    
    strCommand = """" & DescriptionFileName & """"
    
    tool.execPrgSyncrone """" & strEditor & """", strCommand, vbNormalFocus
    
    EditSessionDescription = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "EditSessionDescription"
End Function



Public Function EditTestDescription(strEditor As String) As Boolean

    On Error GoTo ErrMgr

    Dim t           As New cTextFile
    Dim strCommand  As String
    Dim s           As String
    Dim w           As New cWindows
    Dim pp          As New CPreProcessor
    Dim tool        As New cTool
    
    If Not t.ExistFile(DescriptionFileName) Then
    
        pp.Add "CRLF", vbCrLf
        pp.Add "AUTHOR", w.UserName
        pp.Add "CREATIONDATE", Now()
        
        If Me.ItemType = FOLDER_ITEM Then
            s = pp.Process("", "%", "%") '  readme.txt folder have no format
        Else
            s = pp.Process(TESTHARNESS_MESSAGE_7036, "%", "%")
        End If

        t.LogFile DescriptionFileName, s, True
    End If
    
    strCommand = """" & DescriptionFileName & """"
    tool.execPrgSyncrone """" & strEditor & """", strCommand, vbNormalFocus
    EditTestDescription = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "EditSessionDescription"
End Function


Public Function ReadTeamplate() As Boolean

    Dim i   As Long
    Dim DP  As MetraTech_QA_TestHarness_CommentParser.IParameter
    
    On Error GoTo ErrMgr
    
    If Me.DescriptionParser.Parameters.Count Then
    
        Me.Parameters.Clear
        
        For i = 0 To Me.DescriptionParser.Parameters.Count - 1
        
            Set DP = Me.DescriptionParser.Parameters.Item(i)
            Me.Parameters.AddDescriptionParameter DP
        Next
    Else
        ShowError TESTHARNESS_ERROR_7038, Me, "ReadTeamplate"
    End If
    ReadTeamplate = True

Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ReadTeamplate"
End Function




Public Function LoadDictionary() As Boolean

    On Error GoTo ErrMgr
    
    Dim i                   As Long
    Dim strExternalDataBase As String
    
    Set Dictionary = CreateObject("MTMSIX.Dictionary")
    
    Dictionary.LoadFolder Environ("METRATECHTESTDATABASE") & "\Dictionary", True
    
    i = 1
    Do
        strExternalDataBase = Environ("METRATECHTESTDATABASE" & i)
        
        If Len(strExternalDataBase) Then
        
            Dictionary.LoadFolder strExternalDataBase & "\Dictionary", True
            i = i + 1
        Else
            Exit Do
        End If
    Loop
    Dictionary.Render
    Me.DBInfo.DictionaryEntryCount = Me.Dictionary.Count
    LoadDictionary = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadDictionary"
End Function




Public Function VerifyAllVBScriptComment(ParentForm As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim objChild As CTDBItem
    Dim f As New cTextFile
    Dim strText As String
    
    Dim DP As MetraTech_QA_TestHarness_CommentParser.IDescriptionParser
    
    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        
        Case TDB_ItemType.TEST_ITEM
            If GetProgramType = VBScript Then
            
                Set DP = Me.DescriptionParser
                If IsValidObject(DP) Then
                    
                Else
                
                    f.LogFile "c:\testharness.bad.comment.txt", QuotedFullProgramName()
                    ParentForm.user "BADCOMMENT:" & QuotedFullProgramName()
                End If
            End If
            
        Case TDB_ItemType.TEST_SESSION_ITEM

        Case TDB_ItemType.STATIC_FILE_ITEM

    End Select
    
    For Each objChild In Me.Children
    
        If (Not objChild.VerifyAllVBScriptComment(ParentForm)) Then Exit Function
    Next
    VerifyAllVBScriptComment = True
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "VerifyAllVBScriptComment"
End Function



Public Function ReportToQARepository() As Boolean

End Function


' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        : TRUE if the function succeeds else false. Errors should be logged in the MTLog.txt file...
Public Function CreateExternalDescriptionFile() As Boolean
  
    On Error GoTo ErrMgr
    
    Dim t   As New cTextFile
    Dim pp  As New CPreProcessor

    Select Case ItemType
    
        Case TDB_ItemType.FOLDER_ITEM
        Case TDB_ItemType.TEST_ITEM
            
            If Not t.ExistFile(GetExternalDescriptionFileName()) Then
            
                pp.Add "CRLF", vbCrLf
                t.LogFile GetExternalDescriptionFileName(), pp.Process(TESTHARNESS_MESSAGE_7047, "%", "%"), True
                
            End If
            
        Case TDB_ItemType.TEST_SESSION_ITEM
        Case TDB_ItemType.STATIC_FILE_ITEM
    End Select
    CreateExternalDescriptionFile = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "CreateExternalDescriptionFile"
End Function



Public Function ShowDictionary() As Boolean

    On Error GoTo ErrMgr

    Dim t As New cTextFile
    
    t.LogFile Environ("temp") & "\TestHarness.dictionary.txt", Me.Dictionary.ToString(), True
    Shell "notepad.exe """ & Environ("temp") & "\TestHarness.dictionary.txt""", vbNormalFocus
    ShowDictionary = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "LoadDictionary"
End Function




Public Function GenerateSessionSummaryDocumentation(strDocPath As String, booHTML As Boolean) As Boolean

    On Error GoTo ErrMgr
    
    Dim strHTMLFileName     As String
    Dim t                   As CTDBItem
    Dim tt                  As CTDBItem
    Dim OutPut              As New cStringConcat
    Dim tools               As New cTool
    Dim f                   As New cTextFile
    Dim strHTML             As String
    Dim strExtension        As String
    
    strExtension = IIf(booHTML, ".htm", ".txt")
    
    strHTMLFileName = Me.FullName & strExtension
    
    OutPut.AutomaticCRLF = True
    OutPut.Init 16384
    
    strHTML = f.LoadFile(strDocPath & "\Session.Summary.Header" & strExtension)

    OutPut.Concat PreProcess(strHTML, "TITLE", Me.Caption, "DESCRIPTION", Me.Description, "PATH", Me.Path, "TEST.COUNT", Me.Tests.Count)
    
    For Each tt In Me.Tests
    
        Set t = Me.Root.Find(tt.ID)
        strHTML = f.LoadFile(strDocPath & "\Session.Summary.Test" & strExtension)
        OutPut.Concat PreProcess(strHTML, "TITLE", t.Caption, "DESCRIPTION", Replace(t.Description, vbNewLine, "<br>"), "PATH", t.Path)
    Next

    OutPut.Concat "<hr>"
    OutPut.Concat Now()
    
    OutPut.Concat f.LoadFile(App.Path & "\doc\Session.Summary.Footer" & strExtension)
    
    f.LogFile strHTMLFileName, OutPut.GetString(), True
    
    tools.ExecFile strHTMLFileName
    
    GenerateSessionSummaryDocumentation = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "GenerateSessionSummaryDocumentation"
End Function
 
Friend Function CopyExecutionInfoTo(TestDestination As CTDBItem) As Boolean

    On Error GoTo ErrMgr

    TestDestination.Program = Me.Program
    TestDestination.Path = Me.Path
    Set TestDestination.Parent = Me.Parent
    
    CopyExecutionInfoTo = True
    Exit Function
ErrMgr:

    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "CopyExecutionInfoTo"
End Function

Public Function ReOrderAllTests(StartIndex As Long, StepIndex As Long) As Boolean

    On Error GoTo ErrMgr
    
    Dim c               As CTDBItem
    Dim p               As Long
    Dim strNameNoIndex  As String
    Dim CurrentIndex
    
    
    For Each c In Me.Children
    
        If c.ItemType = TEST_ITEM Then
        
            p = InStr(Name, " ")
            If p > 0 Then
                strNameNoIndex = Mid(Name, p)
            End If
        End If
    Next
    ReOrderAllTests = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "ReOrderAllTests"
End Function

Public Function IsExternalDescriptionFileNameExist() As Boolean

    Dim t As New cTextFile
    IsExternalDescriptionFileNameExist = t.ExistFile(Me.GetExternalDescriptionFileName)
End Function

Public Function UpdateNameInSession(objStartNode As CTDBItem) As Boolean

    On Error GoTo ErrMgr
    
    Dim t   As CTDBItem
    Dim tt  As CTDBItem
    Dim booMustSaveSession As Boolean
    
    For Each t In objStartNode.Children
    
        If t.ItemType = TEST_SESSION_ITEM Then
        
            booMustSaveSession = False
            
            For Each tt In t.Tests
                
                If Me.ID = tt.ID Then
                
                    tt.Name = Me.Name
                    booMustSaveSession = True
                End If
            Next
            
            If booMustSaveSession Then t.Save
            
        ElseIf t.ItemType = FOLDER_ITEM Then
            Me.UpdateNameInSession t
        End If
    Next
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBItem", "UpdateNameInSession"
End Function



