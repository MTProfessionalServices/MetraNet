VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBOutputFileContext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public FileName     As String
Public FileLength   As Long
Public Lines        As Collection
Public OwnerID      As String
Public OwnerType    As TDB_ItemType

Public Enum TDB_OutPutFileContext

    OUTPUT_FILE_CONTEXT_FILE_UNKNOWN = 0
    OUTPUT_FILE_CONTEXT_FILE_NOT_FOUND = 1
    OUTPUT_FILE_CONTEXT_FILE_DID_NOT_CHANGED = 2
    OUTPUT_FILE_CONTEXT_FILE_OK = 4
    OUTPUT_FILE_CONTEXT_FILE_FAILED = 8
    
End Enum

Private Sub Class_Initialize()

    On Error GoTo ErrMgr


    Dim objUnitTestAPI As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    FileName = objUnitTestAPI.GetLogResultFileName()
    Clear

    Exit Sub
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "Class_Initialize"
End Sub

Public Function Save(ByVal strOwnerID As String, ByVal eOwnerType As TDB_ItemType) As TDB_OutPutFileContext

    On Error GoTo ErrMgr

    Dim objTextFile As New cTextFile
    
    OwnerType = eOwnerType
    OwnerID = strOwnerID
    FileLength = GetLength()

    Save = OUTPUT_FILE_CONTEXT_FILE_OK

    Exit Function
ErrMgr:
    ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "Save"
End Function

Public Function Read(booShowMessageIfTestFail As Boolean, booRecordMode As Boolean, DatabaseName As String, ServerName As String, BuildID As String, strUserName As String, strPassWord As String, booCommandLineMode As Boolean) As TDB_OutPutFileContext

    On Error GoTo ErrMgr

    Dim objTextFile         As New cTextFile
    Dim s                   As String
    Dim objUnitTestAPI      As Object: Set objUnitTestAPI = GetNewTestApiInstance()
    Dim status              As Boolean
    Dim Fields              As Variant
    
    ' The Test did not write in the output file
    If (FileLength = GetLength()) Then
    
        Read = OUTPUT_FILE_CONTEXT_FILE_DID_NOT_CHANGED
        Exit Function
    End If
    
    If (objTextFile.ExistFile(FileName)) Then
        
        If (objTextFile.OpenFile(FileName)) Then ' Open the Result log file and get the last string.
        
            Do While Not objTextFile.EOF()
            
                s = objTextFile.ReadLn()
            Loop
            objTextFile.CloseFile
            
            Lines.Add s ' , OwnerID ' Add the last string in our memory collection - We cannot store the key because of twice the same test in a session
            
            Read = OUTPUT_FILE_CONTEXT_FILE_OK
            objUnitTestAPI.TRACE s      ' Trace the string. the string will be displayed in the main windows.
            EmailMsg = EmailMsg & s & vbCrLf    ' Add the result string of the test to the email message
            
            If (booRecordMode) Then status = WriteToCoverageDatabase(s, DatabaseName, ServerName, BuildID, strUserName, strPassWord)
    
            Fields = Split(s, ",", 8)
            
            If CBool(InStr(Fields(1), "SUCCEED")) Or CBool(InStr(Fields(1), "SKIPPED")) Then

                Read = OUTPUT_FILE_CONTEXT_FILE_OK
                
            ElseIf CBool(InStr(Fields(1), "FAILED")) Then
            
                Read = OUTPUT_FILE_CONTEXT_FILE_FAILED
            Else
                ShowError TESTHARNESS_ERROR_7051, "CTDBOutputFileContext", "Read"
                Read = OUTPUT_FILE_CONTEXT_FILE_FAILED
            End If
        
        End If
    End If
    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "Read"
End Function

Public Function GetLength() As Long

    On Error GoTo ErrMgr


    Dim objTextFile As New cTextFile
    
    If (objTextFile.ExistFile(FileName)) Then
        GetLength = FileLen(FileName)
    Else
        GetLength = 0
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "GetLength"
End Function

Public Function Clear() As Boolean

    On Error GoTo ErrMgr

    Set Lines = New Collection

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "Clear"
End Function

Public Function TestSucceed() As Boolean

    On Error GoTo ErrMgr

    Dim s As String
    s = Lines(Lines.Count) ' get the last row
    TestSucceed = CBool(InStr(s, ",""[SUCCEED]"","))

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "TestSucceed"
End Function

Public Function WriteToCoverageDatabase(ByVal s As String, ByVal DatabaseName As String, ByVal ServerName As String, ByVal BuildID As String, ByVal strUserName As String, ByVal strPassWord As String) As Boolean

    Dim TestID              As String
    Dim StartTime           As String
    Dim EndTime             As String
    Dim TestName            As String
    Dim TestDescription     As String
    Dim TestResult          As String * 1
    Dim ResultDescription   As String
    Dim ComputerName        As String
    Dim UserName            As String
    Dim mySQLQuery          As String
    Dim Fields              As Variant
    Dim lngCounter          As Long
    Dim tmplen              As Long
    Dim dbconnect           As New Database
    Dim status              As Boolean
    Dim objPreProcessor     As New CPreProcessor
        
    On Error GoTo ErrMgr
    
    TestID = Me.OwnerID

    ' 1  - Need to parse the string
    ' Syntax:  TestName, Result, Description,UserName,Machine Name,StartDate,EndDate, optional ReasonForFailure
    ' Sample:  "Failer","FAILED","","FTorres","F-TORRES","3/19/2001 12:23:54 PM","3/19/2001 12:23:55 PM"
   
    Fields = Split(s, ",", 8)
    
    For lngCounter = 0 To UBound(Fields) ' Remove the quote marks from around the strings
    
        Fields(lngCounter) = Mid(Fields(lngCounter), 2, Len(Fields(lngCounter)) - 2)
    Next
    
    TestName = Fields(0)
    TestResult = IIf(InStr(Fields(1), "SUCCEED"), "Y", "N")
    TestDescription = Fields(2)
    UserName = Fields(3)
    ComputerName = Fields(4)
    StartTime = Fields(5)
    EndTime = Fields(6)
    If (UBound(Fields) > 6) Then If (Fields(7) <> "") Then ResultDescription = Fields(7)
    
    
    'now open database connection and insert the row into the results table.
    status = dbconnect.Init(eDBA_CONNECTION_ADO, eDBA_SERVER_MS_SQL_70, eDBA_SECURITY_SQL_CONNECTION, DatabaseName, strUserName, strPassWord, , ServerName)
    status = dbconnect.OpenConnection
    
    'Escape the single quotes for buiding the SQL query.
    
    ResultDescription = Replace(ResultDescription, "'", "''")
    TestDescription = Replace(TestDescription, "'", "''")
    TestID = Replace(TestID, "'", "''")
    
    objPreProcessor.Add "TESTID", TestID
    objPreProcessor.Add "STARTTIME", StartTime
    objPreProcessor.Add "ENDTIME", EndTime
    objPreProcessor.Add "TESTNAME", TestName
    objPreProcessor.Add "TESTDESCRIPTION", TestDescription
    objPreProcessor.Add "TESTRESULT", TestResult
    objPreProcessor.Add "RESULTDESCRIPTION", ResultDescription
    objPreProcessor.Add "COMPUTERNAME", ComputerName
    objPreProcessor.Add "USERNAME", UserName
    objPreProcessor.Add "BUILDID", BuildID
    objPreProcessor.Add "TYPE", IIf(OwnerType = TEST_SESSION_ITEM, "S", "T")
    
    mySQLQuery = objPreProcessor.Process("insert into Results values ('[TESTID]', '[STARTTIME]', '[ENDTIME]', '[TESTNAME]', '[TESTDESCRIPTION]', '[TESTRESULT]', '[RESULTDESCRIPTION]', '[COMPUTERNAME]', '[USERNAME]', '[BUILDID]','[TYPE]')")
    
    status = dbconnect.SqlRun(mySQLQuery, , , True, False)

    status = dbconnect.CloseConnection
    WriteToCoverageDatabase = status
    
Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "CTDBOutputFileContext", "WriteToCoverageDatabase"
End Function




