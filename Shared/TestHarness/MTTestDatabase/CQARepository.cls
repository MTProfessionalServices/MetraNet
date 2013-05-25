VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CQARepository"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private QADB

Public Function OpenRepository(IniFile As cIniFile) As Boolean

      Set QADB = New CDB
    
      QADB.Server = IniFile.getVar("frmOptions", "RepositoryServer")
      QADB.Login = IniFile.getVar("frmOptions", "RepositoryLogin")
      QADB.PassWord = IniFile.getVar("frmOptions", "RepositoryPassWord")
      QADB.Database = IniFile.getVar("frmOptions", "RepositoryDatabase")
      QADB.DefaultTimeOut = 30
      
      OpenRepository = QADB.OpenDB()
      
   
End Function

Public Function IsRegister(SessionName) As Boolean
    
    Dim r       As Object
    Dim strSQL  As String
    
    strSQL = "Select * from t_test where nm_automation = upper('[SESSIONNAME]')"
    strSQL = PreProcess(strSQL, "SESSIONNAME", SessionName)
    
    Set r = QADB.SqlRun(strSQL, QADB.NewRecordset())
    
    IsRegister = r.RecordCount > 0
    

End Function

Public Function RegisterInQARepository(SessionName, TestOwner, NumberOfTestCases, Description, tx_test_mode) ' As Variant

       RegisterInQARepository = False

       Dim strSQL

       If Len(SessionName) Then

         strSQL = "RegisterTest '[NM_AUTOMATION]' , '[DESCRIPTION]' , [NUMBEROFTESTCASE] , '[OWNER]', '[TEST_MODE]'"
         strSQL = PreProcess(strSQL, "NM_AUTOMATION", SessionName, "DESCRIPTION", Description, "NUMBEROFTESTCASE", NumberOfTestCases, "OWNER", TestOwner, "TEST_MODE", tx_test_mode)

         RegisterInQARepository = QADB.SqlRun(strSQL, Empty)
       End If

End Function



  ' ---------------------------------------------------------------------------------------------------------------------------------------
  ' FUNCTION     : ReportToQARepository
  ' PARAMETERS   :
  ' DESCRIPTION  : Report results of the test run to the QA Repository
  ' RETURNS      :

  Public Function ReportToQARepository(SessionName, Build, engineer, FailedCases, TestStatus, Description, SystemName) ' As Variant

         ReportToQARepository = False
         Dim strSQL

         

         If Len(SessionName) Then

           strSQL = "ReportToQARepository '[NM_AUTOMATION]','[BUILD]','[ENGINEER]',[FAILED_CASES],'[STATUS]','[DESCRIPTION]','[SYSTEMNAME]'"
           strSQL = PreProcess(strSQL, "NM_AUTOMATION", SessionName, "BUILD", Build, "ENGINEER", engineer, "FAILED_CASES", FailedCases, "STATUS", TestStatus, "DESCRIPTION", Description, "SYSTEMNAME", SystemName)

           ReportToQARepository = QADB.SqlRun(strSQL, Empty)
         End If

  End Function

Public Function PopulateEngineerComboBox(cb, Optional ByVal strDefaultValue As String) As Boolean

    Dim r As Object
    
    Set r = QADB.SqlRun("select * from t_engineers order by nm_engineer", QADB.NewRecordset())
    
    Do While Not r.EOF
    
        cb.AddItem r.Fields("nm_engineer").value
        cb.itemData(cb.NewIndex) = r.Fields("id_engineer").value
        If LCase$(strDefaultValue) = LCase$(r.Fields("nm_engineer").value) Then
            cb.ListIndex = cb.NewIndex
        End If
        r.MoveNext
    Loop
    If cb.ListIndex = -1 Then cb.ListIndex = 0
    PopulateEngineerComboBox = True
End Function


Public Function PopulateSystemNameComboBox(cb As Variant, Optional ByVal strDefaultValue As String) As Boolean

    Dim r As Object
    
    Set r = QADB.SqlRun("select * from t_system order by nm_system", QADB.NewRecordset())
    
    Do While Not r.EOF
    
        cb.AddItem r.Fields("nm_system").value
        If LCase$(strDefaultValue) = LCase$(r.Fields("nm_system").value) Then
            cb.ListIndex = cb.NewIndex
        End If
        r.MoveNext
    Loop
    If cb.ListIndex = -1 Then cb.ListIndex = 0
    PopulateSystemNameComboBox = True
End Function



Public Function GetMetraNetBuild() As String

    Dim r As New MTVBLib.cRegistry
    Dim foo As Boolean
    foo = r.OpenSection(r.HKEY_LOCAL_MACHINE(), "SOFTWARE\MetraTech\MetraNet")
    GetMetraNetBuild = r.getSubVar("Build")

End Function



Public Function GetMetraNetVersion() As String

    Dim r As New MTVBLib.cRegistry
    Dim foo As Boolean
    foo = r.OpenSection(r.HKEY_LOCAL_MACHINE(), "SOFTWARE\MetraTech\MetraNet")
    GetMetraNetVersion = r.getSubVar("Version")
    
End Function



Public Function CheckSystemNameExist(strSystemName As String) As Boolean

    Dim r As Object
    Dim strSQL As String
    
    strSQL = "select * from t_system where nm_system='[SYSTEMNAME]'"
    strSQL = PreProcess(strSQL, "SYSTEMNAME", strSystemName)
    
    Set r = QADB.SqlRun(strSQL, QADB.NewRecordset())
    
    CheckSystemNameExist = r.RecordCount > 0
    
End Function


Public Function CheckCurrentSystemNameExist() As Boolean
    CheckCurrentSystemNameExist = CheckSystemNameExist(CreateObject("MTVBLIB.CWindows").ComputerName())
End Function


Public Function RegisterSystem(booUpdate As Boolean, strSystemName As String, strCPU, strRAM, lngPhysicalCPU As Long, strHyperThreaded As String) As Boolean

        Dim strSQL
        
        If (booUpdate) Then
            strSQL = "update t_system set tx_CPU_speed='[CPU]',tx_RAM='[RAM]',ct_physical_CPU=[PHY_CPU],is_hyperthreaded='[HT]' where nm_system='[SYSTEM]'"
        Else
            strSQL = "insert into t_system (nm_system,tx_CPU_speed,tx_RAM,ct_physical_CPU,is_hyperthreaded)values('[SYSTEM]','[CPU]','[RAM]',[PHY_CPU],'[HT]')"
        End If
        
        strSQL = PreProcess(strSQL, "SYSTEM", strSystemName, "CPU", strCPU, "RAM", strRAM, "PHY_CPU", lngPhysicalCPU, "HT", strHyperThreaded)
        RegisterSystem = QADB.SqlRun(strSQL, Empty)
    
End Function



Public Function GetMetraNetPatchList() As String

    Dim t       As Object: Set t = CreateObject("MTMSIX.MSIXTools")
    Dim f               As New cTextFile
    Dim Files           As New CVariables
    Dim strInstallDir   As String
    Dim PatchFolder     As String
    Dim s               As String
    Dim objFile         As CVariable
    
    strInstallDir = t.GetMTInstallDir()
    PatchFolder = strInstallDir & "\Config\PatchInfo"
    
    If f.GetFilesList(PatchFolder, "*.xml", Files) Then
    
        For Each objFile In Files
        
            s = s & Replace(UCase$(objFile.Name), ".XML", "") & ","
        Next
    End If
    GetMetraNetPatchList = Mid(s, 1, Len(s) - 1)

End Function


Public Function GetMetraNetLastPatch() As String

    Dim t               As New cTool
    Dim f               As New cTextFile
    Dim msixt           As Object: Set msixt = CreateObject("MTMSIX.MSIXTools")
    Dim strInstallDir   As String
    Dim PatchFolder     As String
    Dim s               As String
    Dim strBatch        As String
    Dim strOutPutFileName As String
    
    strInstallDir = msixt.GetMTInstallDir()
    PatchFolder = strInstallDir & "\Config\PatchInfo"
    
    'dir  "C:\MetraTech\RMP\Config\PatchInfo\*.xml" /b /o:d >%temp%\patchinfo.txt
    strBatch = PreProcess("/c dir ""[PATH]\*.xml"" /b /o:d >""%temp%\patchinfo.txt""", "PATH", PatchFolder)
    
    t.execPrgSyncrone "cmd.exe", strBatch, vbHide
    
    strOutPutFileName = Environ("temp") & "\patchinfo.txt"
    
    If f.OpenFile(strOutPutFileName) Then
        Do While Not f.EOF
            s = f.ReadLn()
        Loop
        f.CloseFile
        GetMetraNetLastPatch = Replace(UCase$(s), ".XML", "")
    End If
End Function


Public Function PopulateBuildComboBox(cb As Variant, Optional ByVal strDefaultValue As String) As Boolean

    Dim r As Object
    
    Set r = QADB.SqlRun("select * from t_build order by  nm_build", QADB.NewRecordset())
    
    cb.AddItem "" ' in case the default value is not found
    
    Do While Not r.EOF
    
        cb.AddItem r.Fields("nm_build").value
        If LCase$(strDefaultValue) = LCase$(r.Fields("nm_build").value) Then
            cb.ListIndex = cb.NewIndex
        End If
        r.MoveNext
    Loop
    If cb.ListIndex = -1 Then cb.ListIndex = 0
    PopulateBuildComboBox = True
End Function



Public Function RegisterEngineers(eName As String, Department As String) As Boolean

        Dim strSQL
        
        strSQL = "insert into t_engineers (nm_engineer,tx_department)values('[NAME]','[DEPARTMENT]')"
        strSQL = PreProcess(strSQL, "NAME", eName, "DEPARTMENT", Department)
        RegisterEngineers = QADB.SqlRun(strSQL, Empty)
    
End Function





Public Function PopulateEngineersDepartmentComboBox(cb As Variant, Optional ByVal strDefaultValue As String) As Boolean

    Dim r As Object
    
    Set r = QADB.SqlRun("select  distinct tx_department from t_engineers", QADB.NewRecordset())
    
    Do While Not r.EOF
    
        cb.AddItem r.Fields("tx_department").value
        If LCase$(strDefaultValue) = LCase$(r.Fields("tx_department").value) Then
            cb.ListIndex = cb.NewIndex
        End If
        r.MoveNext
    Loop
    If cb.ListIndex = -1 Then cb.ListIndex = 0
    PopulateEngineersDepartmentComboBox = True
End Function





Public Function DeleteTable(strTable As String, strIDColumn As String, strID As String) As Boolean

        Dim strSQL
        
        strSQL = "delete from [TABLE] where [IDCOL]=[IDVALUE]"
        strSQL = PreProcess(strSQL, "TABLE", strTable, "IDCOL", strIDColumn, "IDVALUE", strID)
        DeleteTable = QADB.SqlRun(strSQL, Empty)
    
End Function




Public Function GetSystem(strSystemName As String) As Variant

        Dim strSQL, r
        strSQL = "select * from t_system where nm_system = '[SYSTEM]'"
        strSQL = PreProcess(strSQL, "SYSTEM", UCase$(strSystemName))
        Set r = QADB.SqlRun(strSQL, QADB.NewRecordset())
        If r.RecordCount = 1 Then
            Set GetSystem = r
        End If
End Function



Public Function PopulateTestModeComboBox(cb As Variant, Optional ByVal strDefaultValue As String) As Boolean

    Dim r As Object
    
    Set r = QADB.SqlRun("select  distinct tx_test_mode  from t_test", QADB.NewRecordset())
    
    Do While Not r.EOF
    
        cb.AddItem r.Fields("tx_test_mode").value
        If LCase$(strDefaultValue) = LCase$(r.Fields("tx_test_mode").value) Then
            cb.ListIndex = cb.NewIndex
        End If
        r.MoveNext
    Loop
    If cb.ListIndex = -1 Then cb.ListIndex = 0
    PopulateTestModeComboBox = True
End Function
