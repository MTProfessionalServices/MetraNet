Attribute VB_Name = "Module1"
' **************************************************************************************************************************************************************************************
' * Module: TestHarness - main module
' * Application : Metratech Test Harness
' * Version : 1.0
' * Author : Frederic Torres, Anagha Rangarajan
' * Creation Date :
' *
' *
' *
' *
' *
' *
' *
' **************************************************************************************************************************************************************************************

Option Explicit


Public Const MT_DATABASE_TEST_URL = "http://localhost/metratechtestdatabase/VBScript.Library/CTest.vbs"

Public g_objIniFile     As New cIniFile
Public g_objTDB         As CTDBItem

Public g_booCommandLineMode As Boolean

'object used for logging test results in correct format
Public g_objUnitTestAPI As Object

Public EmailTo          As String

Private Const TREVIEW_STATE_FILE_SELECTED_ITEM_PREFIX = "#TREEVIEW_SELECTED_ITEM="
Private Const TREVIEW_STATE_FILE_FOLDER_OPEN_PREFIX = "#TREEVIEW_OPEN_FODLER="

Public Enum eAPP_ACTION
    LOAD_DATA
    SAVE_DATA
    LOAD_LISTVIEW_COLUMS_SIZE
End Enum

Public Sub Main()

    On Error GoTo ErrMgr

    Dim commandline As String
    Dim objTool As New cTool
    
    Set g_objUnitTestAPI = GetNewTestApiInstance()
    

       
    g_booLogWithoutCOMLogger = True
    
    g_objUnitTestAPI.TestHarnessMode = True
     
    g_objIniFile.InitAutomatic App
    
    'Initialize the email to field from the options dialog
    EmailTo = AppOptions("TxtEmail")
    commandline = Command
  
    If IsCommandLineMode() Then
        
        If InStr(UCase(Command), "/I") Then
        
            FinishInstall
            
        ElseIf InStr(UCase(Command), "/D") Then
        
            OpenDashBoard
        Else
            g_booCommandLineMode = True
            ExecuteInCommandLineMode commandline 'commandline execution now.
        End If
    Else
          
        
          CheckIfiniFileIsOK
          
          CheckTDrive
          
          frmMain.Show: DoEvents
          
          frmSplash.Show , frmMain: DoEvents
          
          frmMain.LoadAll
          
          Unload frmSplash
          
          If AppOptions("ShowTips", True) Then frmTip.Show vbModal
          
          If (AppOptions("Version") <> objTool.appVersion(App)) Then
                
                DoEvents
                AppOptions("Version") = objTool.appVersion(App)
                frmMain.mnuHelpContent_Click
          End If
    End If
    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "Main"
End Sub


Public Function CheckTDrive()

    If Not DetectTDrive() Then SubstTDrive
End Function


Public Function SubstTDrive() As Boolean

    On Error GoTo ErrMgr
    
    Dim strBatch As String
    
    If MsgBox(TESTHARNESS_MESSAGE_7057, vbYesNo + vbQuestion) = vbYes Then
    
        strBatch = "cmd.exe /c subst T: """ & Environ("METRATECHTESTDATABASE") & """"
        Shell strBatch, vbHide
        SubstTDrive = True
    End If
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "SubstTDrive"
End Function


Public Function DetectTDrive()
    On Error GoTo ErrMgr
    
    Dim strFileName As String
    Dim f           As New cTextFile
    
    strFileName = "t:\TestHarnessDetectTDriveFile.txt"
    f.LogFile strFileName, "hello", True
    DetectTDrive = f.LoadFile(strFileName) = "hello" & vbNewLine
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "DetectTDrive"
End Function





Public Function InitTreeViewData(tvTests As Control)

    On Error GoTo ErrMgr

    '1
    tvAddNode tvTests, "", "#ROOT", "MetraTech Test Harness", "Root", "Root"
    
    '2
    tvAddNode tvTests, "#ROOT", "#UT", "Unit Tests", "Folder", "Folder"
    tvAddNode tvTests, "#ROOT", "#MT", "Module Tests", "Folder", "Folder"
    tvAddNode tvTests, "#ROOT", "#AT", "Application Tests", "Folder", "Folder"
    tvAddNode tvTests, "#ROOT", "#ST", "System Tests", "Folder", "Folder"
    
    '3
    tvAddNode tvTests, "#UT", "#BACKENDCOMOBJECT", "Back End COM Object", "Folder", "Folder"
    tvAddNode tvTests, "#BACKENDCOMOBJECT", GetUnicID(), "DataAccessor Object Full Test", "Test", "Test"
   
    tvAddNode tvTests, "#UT", "#UICOMOBJECT", "UI COM Object", "Folder", "Folder"
    tvAddNode tvTests, "#UICOMOBJECT", "#MTVBLIB", "MTVBLib Object Full Test", "Folder", "Folder"
    
    tvAddNode tvTests, "#MTVBLIB", GetUnicID(), "MTVBLib Full Unit Test Session", "TestSession", "Test"
    tvAddNode tvTests, "#MTVBLIB", "#CVARIABLES_UNIT_TEST", "CVariables Class", "Test", "Test"
    tvAddNode tvTests, "#MTVBLIB", GetUnicID(), "CStringConcat Class", "Test", "Test"
    tvAddNode tvTests, "#MTVBLIB", GetUnicID(), "CByteSyntaxAnalyser Class", "Test", "Test"
    
    tvAddNode tvTests, "#UICOMOBJECT", "#MTMSIX", "MTMSIX Object (MDM Objects)", "Folder", "Folder"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXHandler", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXProperty", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXProperties", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXEnumType", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXEnumTypeEntryItem", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXEnumTypeEntries", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXTools", "Test", "Test"
    tvAddNode tvTests, "#MTMSIX", GetUnicID(), "MSIXCache", "Test", "Test"
    
    
    tvAddNode tvTests, "#UT", GetUnicID(), "Core COM Object", "Folder", "Folder"
    
    
    
    tvTests.Nodes("#CVARIABLES_UNIT_TEST").Selected = True
    

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "InitTreeViewData"
End Function



Public Property Get AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS") As String

    On Error GoTo ErrMgr


    AppOptions = g_objIniFile.getVar(strSection, strOptionName, strDefaultValue)

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "AppOptions"
End Property


Public Property Let AppOptions(ByVal strOptionName As String, Optional strDefaultValue As String, Optional ByVal strSection = "frmOPTIONS", ByVal v As String)

    On Error GoTo ErrMgr

    g_objIniFile.SetVar strSection, strOptionName, v

    Exit Property
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "AppOptions"
End Property



Public Function TreeViewStateFileName() As String

    On Error GoTo ErrMgr


    TreeViewStateFileName = App.Path & "\" & "TreeView.State.Info"

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "TreeViewStateFileName"
End Function

Public Function TreeViewSaveState(tv As TreeView, ByVal strFileName As String) As Boolean

    On Error GoTo ErrMgr


    Dim i       As Long
    Dim objCat  As New cStringConcat
    
    objCat.Init 64000
    
    For i = 1 To tv.Nodes.Count
    
        If (tv.Nodes.Item(i).Expanded) And (tv.Nodes.Item(i).Tag = "FOLDER") Then
        
            objCat.Concat TREVIEW_STATE_FILE_FOLDER_OPEN_PREFIX & tv.Nodes.Item(i).key & vbNewLine
        End If
    Next
    
    If IsValidObject(tv.SelectedItem) Then
        ' Must inserted at the end
        objCat.Concat TREVIEW_STATE_FILE_SELECTED_ITEM_PREFIX & tv.SelectedItem.key
    End If
    
    Dim objTextFile As New cTextFile
    TreeViewSaveState = objTextFile.LogFile(strFileName, objCat.GetString(), True)

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "TreeViewSaveState"
End Function


Public Function TreeViewReadState(tv As TreeView, ByVal strFileName As String) As Boolean

    Dim i                   As Long
    Dim strS                As String
    Dim lngSelectedItemPos  As Long
    Dim strSelectedKey      As String
    Dim objTextFile         As New cTextFile
    
    
    
    strS = objTextFile.LoadFile(strFileName)
    
    For i = 1 To tv.Nodes.Count
    
        If (InStr(strS, tv.Nodes.Item(i).key)) Then
        
            tv.Nodes.Item(i).Expanded = True
        Else
            tv.Nodes.Item(i).Expanded = False
        End If
    Next
    
    lngSelectedItemPos = InStr(strS, TREVIEW_STATE_FILE_SELECTED_ITEM_PREFIX)
    
    If (lngSelectedItemPos) Then
            
        strSelectedKey = Mid(strS, lngSelectedItemPos + Len(TREVIEW_STATE_FILE_SELECTED_ITEM_PREFIX))
        If (Len(strSelectedKey)) Then
        
            On Error Resume Next
            tv.Nodes.Item(strSelectedKey).Selected = True
        End If
    End If
    TreeViewReadState = True
End Function

Public Function OpenTDB() As Boolean

    On Error GoTo ErrMgr

    Dim DatabasePath                As String
    Dim ExternalTestDatabaseName    As String
    Dim objTool                     As New cTool
    Dim objTextFile                 As New cTextFile
    
    
    frmMain.Status TESTHARNESS_MESSAGE_7017
    g_lngMaxItemInitializedInPreviousLoad = AppOptions("MaxItemInitializedInPreviousLoad", 0)
    
    CloseTDB
    
    frmMain.Status TESTHARNESS_MESSAGE_7000
    
    Set g_objTDB = New CTDBItem
    Set g_objTDB.IniFile = g_objIniFile
    

    g_objTDB.ShowStaticFile = AppOptions("ShowStaticFile", False)
    g_objTDB.DBInfo.Reset
    
    'get the database path from the METRATECHTESTDATABASE environment variable
    'or the temp environment variable
    
    DatabasePath = GetMetraTechDatabasePath()
    If (Len(DatabasePath) = 0) Then
    
        ShowError TESTHARNESS_ERROR_7016
        Exit Function
    End If
    
    If Not IsCommandLineMode() Then
    
        Set g_objTDB.MainForm = frmMain
        objTool.progressBarForStatusBarShow frmMain.ProgressBar1, frmMain.sbStatusBar, 2
        DoEvents
    End If
    
'    Debug.Assert 0
    'frmSplash.Hide
    
    
    
    
    
    g_objTDB.DBInfo.LoadDatabaseTime = GetTickCount()
    
    
    If (Not g_objTDB.Initialize(FOLDER_ITEM, DatabasePath, , True, , , True, AppOptions("IgnorePaths"))) Then
    
        ShowError TESTHARNESS_ERROR_7004
    Else
    
        g_objTDB.DBInfo.LoadDatabaseTime = GetTickCount() - g_objTDB.DBInfo.LoadDatabaseTime
       
        frmMain.Status TESTHARNESS_MESSAGE_7018
        
        g_objTDB.DBInfo.ValidateInterityTime = GetTickCount()
        
        OpenTDB = g_objTDB.ValidateIntegrity(False)
            
        g_objTDB.DBInfo.ValidateInterityTime = GetTickCount() - g_objTDB.DBInfo.ValidateInterityTime
        
        frmMain.Status PreProcess(TESTHARNESS_MESSAGE_7019, "TIME", g_objTDB.DBInfo.LoadDatabaseTime, "INTEGRITY_TIME", g_objTDB.DBInfo.ValidateInterityTime), 2
        
    End If
        
    If Not IsCommandLineMode() Then
    
        frmMain.ProgressBar1.Visible = False
    End If
    
    
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "OpenTDB"
End Function

Public Function CloseTDB() As Boolean

    On Error GoTo ErrMgr
    
    

    If IsValidObject(g_objTDB) Then Set g_objTDB.MainForm = Nothing
    ' If the database was previously loaded we free all the memory
    If (IsValidObject(g_objTDB)) Then g_objTDB.Free
    Set g_objTDB = Nothing ' Free the COM Instance
    CloseTDB = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "CloseTDB"
End Function

Public Function CheckIfiniFileIsOK() As Boolean
    If Len(AppOptions("ScriptingExecutable")) = 0 Then
        Unload frmSplash
        MsgBox TESTHARNESS_MESSAGE_7022, vbExclamation
        frmOptions.OpenDialog g_objIniFile
    End If
End Function

Public Function GetMetraTechDatabasePath() As String

    GetMetraTechDatabasePath = Environ("METRATECHTESTDATABASE")
End Function


Public Function TreeViewCloseALL(tv As TreeView) As Boolean

    On Error GoTo ErrMgr

    Dim i       As Long
    
   
    For i = 1 To tv.Nodes.Count
    
        tv.Nodes.Item(i).Expanded = False
    Next
    tv.Nodes.Item(1).Expanded = True

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "TreeViewCloseALL"
End Function

Public Function FinishInstall() As Boolean
    Dim IIS             As New cIs
    Dim objWinApi       As New cWindows
    Dim strPath         As String
    Dim i               As Long
    Debug.Assert 0
    
    RegisterAssemblies
    
    MsgBox TESTHARNESS_ERROR_7021, vbInformation

    ' MetraTechTestDatabase environment variable
    
    strPath = objWinApi.getBrowseDirectory(0, TESTHARNESS_MESSAGE_7037)
    If IIS.Initialize() Then
        IIS.CreateVirtualDir "MetraTechTestDatabase", strPath, "READ=TRUE;SCRIPT=TRUE;"
    Else
        MsgBox "Cannot find IIs " & IIS.iisName
    End If
    
    g_objUnitTestAPI.Environ("METRATECHTESTDATABASE") = strPath
    If (g_objUnitTestAPI.Environ("METRATECHTESTDATABASE") <> strPath) Then
    
        MsgBox TESTHARNESS_ERROR_7022
    End If
    
    ' MetraTechTestDatabaseTemp environment variable
     
    g_objUnitTestAPI.Environ("METRATECHTESTDATABASETEMP") = strPath & "\Temp"
    
    If g_objUnitTestAPI.Environ("METRATECHTESTDATABASETEMP") <> strPath & "\Temp" Then
    
        MsgBox TESTHARNESS_ERROR_7028
    End If
    
    
    ' MetraTechResultDatabase environment variable
    
    If MsgBox(TESTHARNESS_MESSAGE_7038, vbQuestion + vbYesNo) = vbYes Then
    
        strPath = objWinApi.getBrowseDirectory(0, TESTHARNESS_MESSAGE_7039)
        g_objUnitTestAPI.Environ("METRATECHTRESULTDATABASE") = strPath
        
        If (g_objUnitTestAPI.Environ("METRATECHTRESULTDATABASE") <> strPath) Then
    
            MsgBox TESTHARNESS_ERROR_7040
        End If
    End If
    
    
    i = 1
    Do
        If MsgBox(TESTHARNESS_MESSAGE_7023, vbQuestion + vbYesNo) = vbNo Then Exit Do
        strPath = objWinApi.getBrowseDirectory(0, "Select the path to the external database " & i)
        
        If Len(strPath) Then
        
            g_objUnitTestAPI.Environ("METRATECHTESTDATABASE" & i) = strPath
            If (g_objUnitTestAPI.Environ("METRATECHTESTDATABASE" & i) <> strPath) Then
                MsgBox PreProcess(TESTHARNESS_ERROR_7027, "INDEX", i)
                Exit Do
            Else
                i = i + 1
            End If
        Else
            Exit Do
        End If
    Loop
    
    TestVirtualLink
    
    AddShortcutToDesktop
    
    If MsgBox(TESTHARNESS_MESSAGE_7040, vbQuestion + vbYesNo) = vbYes Then
    
        AppOptions("IgnorePaths") = Replace(g_objUnitTestAPI.Environ("METRATECHTESTDATABASE") & "\QA", "\\", "\")
    End If
    
    CheckTDrive
    
    MsgBox TESTHARNESS_ERROR_7019, vbInformation
    
 ' we cannot re start the test harness because the environment variable though created is not available to this process...
'    ReStartTestHarness
    
End Function



Public Function AddShortcutToDesktop() As Boolean

    Dim WshShell, oShellLink
    Dim strDesktop          As String
    Dim strLnkFileName      As String
    
    On Error GoTo ErrMgr
    
    AddShortcutToDesktop = True
        
    
    Set WshShell = CreateObject("Wscript.Shell")
    strDesktop = WshShell.SpecialFolders("Desktop")
    
    strLnkFileName = strDesktop + "\TestHarness" & App.Major & "." & App.Minor & ".lnk"
    
    Set oShellLink = WshShell.CreateShortcut(strLnkFileName) 'Create a WshShortcut Object
    
    oShellLink.TargetPath = Replace(App.Path & "\" & App.EXEName & ".exe", "\\", "\")
        
    'Set the additional parameters for the shortcut
    'oShellLink.Arguments = App.Path & "\" & App.EXEName & ".exe"
    
    'Save the shortcut
    oShellLink.Save
    
    Dim t As New cTextFile
    
    If Not t.ExistFile(strLnkFileName) Then
    
        MsgBox TESTHARNESS_ERROR_7041, vbCritical
    End If
    
    'Clean up the WshShortcut Object
    Set oShellLink = Nothing
    Exit Function
ErrMgr:

End Function


Private Function RegisterAssemblies()

    Dim strAssembly     As String
    Dim strCommandLine  As String
    
    strAssembly = App.Path & "\MetraTech.QA.TestHarness.CommentParser.dll"
    strCommandLine = "regasm.exe """ + strAssembly + """"
    
    Shell strCommandLine, vbNormalFocus
    
End Function


Public Function TestVirtualLink() As Boolean
    
    On Error GoTo ErrMgr
    
    
    
    frmTip.HttpBGDownLoader.DownLoad MT_DATABASE_TEST_URL, Environ("temp") & "\TestHarness.test.virtuallink.txt"
    TestVirtualLink = True
theExit:
    Unload frmTip

    Exit Function
ErrMgr:
    ShowError PreProcess(TESTHARNESS_ERROR_7018, "URL", MT_DATABASE_TEST_URL) & vbNewLine & GetVBErrorString(), "frmMain", "RefreshUI"
    GoTo theExit
End Function



Private Function ExecuteTestOrTestSession(strFileName As String, strOrder As String) As Boolean

    Dim objSelectedTest         As CTDBItem
    Dim objTextFile             As New cTextFile
    Dim XMLDoc                  As Object
    Dim strGUID                 As String
    Dim objCurrNode             As IXMLDOMNode
    
    On Error GoTo ErrMgr

    If (objTextFile.ExistFile(strFileName)) Then
     
         Set XMLDoc = CreateObject("Microsoft.XMLDOM")
         XMLDoc.async = False
         
         If Not XMLDoc.Load(strFileName) Then
                
                ShowError Replace(TESTHARNESS_ERROR_7023, "[NAME]", strFileName)
         End If
         
         If (UCase(strOrder) = "-TEST") Then
            Set objCurrNode = XMLDoc.selectSingleNode("Test/Id")
         Else
            Set objCurrNode = XMLDoc.selectSingleNode("Session/Id") 'it is a test session
         End If
         
         If (IsValidObject(objCurrNode)) Then
         
            strGUID = objCurrNode.Text
            
            If (Not OpenTDB()) Then Exit Function ' The function display an error if then database cannot be open
            
            Set objSelectedTest = g_objTDB.Find(strGUID)
            
            If (Not objSelectedTest.Execute(AppOptions("ScriptingExecutable"), AppOptions("ShowScriptEngineWindow"))) Then
            
                '''+++ShowError Replace(TESTHARNESS_ERROR_7001, "[NAME]", objSelectedTest.Name)
            End If
            CloseTDB
         End If
     Else
        ShowError Replace(TESTHARNESS_ERROR_7015, "[NAME]", strFileName)
     End If
     ExecuteTestOrTestSession = True
     Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "Module1", "@VbAddCode"
End Function


'Parse the commandline, first check if it is test or a testsession
Public Sub ExecuteInCommandLineMode(ByVal commandline As String)

    Dim objCommandLine          As New CCommandLine
    Dim i                       As Long
    
    On Error GoTo ErrMgr
    
    AppOptions("CommandLineMode") = True
    
    objCommandLine.Init Command
    i = 1
    Do While i <= objCommandLine.Count
    
        Select Case UCase(objCommandLine.Item(i))
        
            Case "-TEST", "-TESTSESSION"
                ExecuteTestOrTestSession objCommandLine.Item(i + 1), objCommandLine.Item(i)
            Case Else
                ShowError TESTHARNESS_MESSAGE_7015
        End Select
        i = i + 2
    Loop
theExit:
    AppOptions("CommandLineMode") = False
    Exit Sub
ErrMgr:
 GoTo theExit
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "MetaTestHarness.bas", "ExecuteInCommandLineMode"
End Sub

Public Function ReStartTestHarness() As Boolean
    
    On Error GoTo ErrMgr
    
    Shell App.Path & "\" & App.EXEName & ".exe", vbNormalFocus
    ReStartTestHarness = True
    Exit Function
ErrMgr:
End Function

Public Function OpenDashBoard() As Boolean
    On Error GoTo ErrMgr
    frmTestStatusView.OpenDialog
    OpenDashBoard = True
    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "MetaTestHarness.bas", "OpenDashBoard"
End Function

Public Sub QuitApp()
    AppOptions("MaxItemInitializedInPreviousLoad") = g_lngItemInitialized
End Sub

Public Function IsCommandLineMode() As Boolean
    IsCommandLineMode = Len(Command)
End Function



Public Function ReplaceTab(s As String) As String

    Dim lngNumber As Long
    lngNumber = AppOptions("DescriptionTabSize", 2)
    ReplaceTab = Replace(s, vbTab, String(lngNumber, " "))
End Function



Public Function SetDescriptionFont(t As Object)
    g_objIniFile.FontSaveRestore "DescriptionFont", t.Font, False
End Function
