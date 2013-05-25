Attribute VB_Name = "MTTestDatabaseModule"
Option Explicit


Public g_lngGetUnicLongID As Long

' Errors
Public Const TESTHARNESS_ERROR_7000 = "[ERROR] A VB RunTime occurs."
Public Const TESTHARNESS_ERROR_7001 = "[ERROR] The execution of the test [NAME] failed."
Public Const TESTHARNESS_ERROR_7002 = "[ERROR] The test [NAME] did not create the output text file [FILE]!"
Public Const TESTHARNESS_ERROR_7003 = "[ERROR] The Test Database path is not valid [PATH]"
Public Const TESTHARNESS_ERROR_7004 = "[ERROR] The Test Database cannot be initialized. Check METRATECHTESTDATABASE environment variable for valid path."
Public Const TESTHARNESS_ERROR_7005 = "[ERROR] The Global TDBItem cannot be found inthe database"
Public Const TESTHARNESS_ERROR_7006 = "[ERROR] The test [TEST_NAME] used in the test session [TEST_SESSION_NAME] cannot be found in the database. (Test.ID=[TEST_ID]). "
Public Const TESTHARNESS_ERROR_7007 = "[ERROR] The Name cannot be a numeric value."
Public Const TESTHARNESS_ERROR_7008 = "[ERROR] The item [NAME] is read-only and cannot be changed."
Public Const TESTHARNESS_ERROR_7009 = "[ERROR] Invalid char for a parameter name."
Public Const TESTHARNESS_ERROR_7010 = "[ERROR] Test [NAME] cannot be deleted, it is used by the test session [TEST_SESSION_FULL_NAME]"
Public Const TESTHARNESS_ERROR_7011 = "[ERROR] Test session [TEST_SESSION_NAME] abandoned due to the failure of the test [TEST_NAME]"
Public Const TESTHARNESS_ERROR_7012 = "[ERROR] Cannot find test executable [NAME]"
Public Const TESTHARNESS_ERROR_7013 = "[ERROR] The field 'Value' must be set is the parameter is not required"
Public Const TESTHARNESS_ERROR_7014 = "[ERROR] Cannot send email. Check SMTP Server"
Public Const TESTHARNESS_ERROR_7015 = "[ERROR] Cannot find test/testsession [NAME]"
Public Const TESTHARNESS_ERROR_7016 = "[ERROR] The Environment variable MetraTechTestDatabase is not set"
Public Const TESTHARNESS_ERROR_7017 = "[ERROR] The test file [TEST1] and [TEST2] have the same id. The second test file is not loaded. Please correct manually the database."
Public Const TESTHARNESS_ERROR_7018 = "[ERROR] Cannot download url [URL]. Check if IIS is running and the MetraTechTestDataBase is created. You can run TestHarness.exe /I to create the virtual link."
Public Const TESTHARNESS_ERROR_7019 = "[INFO] TestHarness Install Mode Done."
Public Const TESTHARNESS_ERROR_7020 = "[ERROR] Cannot create COM Object MTTestAPI.TestAPI"
Public Const TESTHARNESS_ERROR_7021 = "[INFO] The TestHarness install mode will now create the METRATECHTESTDATABASE Virtual Folder, test it, and then create the METRATECHTESTDATABASE environment variable."
Public Const TESTHARNESS_ERROR_7022 = "[ERROR] Cannot create the Environment Variable METRATECHTESTDATABASE. Please do it manually."
Public Const TESTHARNESS_ERROR_7023 = "[ERROR] Cannot load xml file [NAME]"
Public Const TESTHARNESS_ERROR_7024 = "The test [NAME] did not update the Result log file."
Public Const TESTHARNESS_ERROR_7025 = "Result file name [FILENAME] not found"
Public Const TESTHARNESS_ERROR_7026 = "Unknown error reading the result log file"
Public Const TESTHARNESS_ERROR_7027 = "[ERROR] Cannot create the Environment Variable METRATECHTESTDATABASE[INDEX]. Please do it manually."
Public Const TESTHARNESS_ERROR_7028 = "[ERROR] Cannot create the Environment Variable METRATECHTESTDATABASETEMP. Please do it manually."
Public Const TESTHARNESS_ERROR_7029 = "[ERROR] The Test Session '[SESSION]' was already loaded. It is possible that the test session file was duplicated."
Public Const TESTHARNESS_ERROR_7030 = "The test '[TEST]' has an GUID already existing"
Public Const TESTHARNESS_ERROR_7031 = "The test or test session '[NAME]' failed!"
Public Const TESTHARNESS_ERROR_7032 = "Too many Tests are selected, select only one"
Public Const TESTHARNESS_ERROR_7033 = "[ERROR] The field Value is required"
Public Const TESTHARNESS_ERROR_7034 = "[ERROR] Parameter Integrity issue Parameter:[PARAMETER], Test:[TEST_NAME], Session:[TEST_SESSION_NAME]. (Test.ID=[TEST_ID]). "
Public Const TESTHARNESS_ERROR_7035 = "[ERROR] [ERRORS] error(s) found parsing the description of the file [FILE][CRLF][ERRORSMSG]"
Public Const TESTHARNESS_ERROR_7036 = "[ERROR] Cannot edit this object from here"
Public Const TESTHARNESS_ERROR_7037 = "[ERROR] There is no script associated with this test"
Public Const TESTHARNESS_ERROR_7038 = "[ERROR] There is no parameter description defined in the description file."
Public Const TESTHARNESS_ERROR_7039 = "[ERROR] Parameter '[P]' does exist in the test"
Public Const TESTHARNESS_ERROR_7040 = "[ERROR] Cannot create the Environment Variable METRATECHRESULTDATABASE. Please do it manually."
Public Const TESTHARNESS_ERROR_7041 = "[ERROR] Application desktop shortcut creation failed"
Public Const TESTHARNESS_ERROR_7042 = "[ERROR] The test '[NAME]' in the session cannot be found. You should fix the problem before going forward."
Public Const TESTHARNESS_ERROR_7043 = "[ERROR] Cannot open the QARepository database, check connection parameters"
Public Const TESTHARNESS_ERROR_7044 = "[ERROR] Reporting to the QARepository failed!"
Public Const TESTHARNESS_ERROR_7045 = "[ERROR] A description is required!"
Public Const TESTHARNESS_ERROR_7046 = "[ERROR] Session already registered!"
Public Const TESTHARNESS_ERROR_7047 = "[ERROR] Session not registered!"
Public Const TESTHARNESS_ERROR_7048 = "[ERROR] A build number or patch is required!"
Public Const TESTHARNESS_ERROR_7049 = "[ERROR] Cannot remove a required parameter!"
Public Const TESTHARNESS_ERROR_7050 = "[ERROR] The test name '[TEST]' contains a coma, this char is not supported. Please remove the invalid char with the Explorer"
Public Const TESTHARNESS_ERROR_7051 = "[ERROR] Cannot parse the last line of the file Result.csv."
Public Const TESTHARNESS_ERROR_7052 = "[ERROR] The test name '[TEST]' in session '[SESSION]' contains a coma, this char is not supported. Please remove the invalid char with the Explorer"




' Messages
Public Const TESTHARNESS_MESSAGE_7000 = "Loading the database."
Public Const TESTHARNESS_MESSAGE_7001 = "Test '[NAME]'"
Public Const TESTHARNESS_MESSAGE_7002 = "Session '[NAME]'"
Public Const TESTHARNESS_MESSAGE_7003 = "New Folder Name"
Public Const TESTHARNESS_MESSAGE_7004 = "Executing [NAME]..."
Public Const TESTHARNESS_MESSAGE_7005 = "Test [NAME] Executed"
Public Const TESTHARNESS_MESSAGE_7006 = "Test DataBase Path"
Public Const TESTHARNESS_MESSAGE_7007 = "Test Session Name"
Public Const TESTHARNESS_MESSAGE_7008 = "The field [NAME] is required"
Public Const TESTHARNESS_MESSAGE_7009 = "Delete [NAME] ?"
Public Const TESTHARNESS_MESSAGE_7010 = "Cannot read the id tag in the xml file [NAME]"
Public Const TESTHARNESS_MESSAGE_7011 = "Test Name"
Public Const TESTHARNESS_MESSAGE_7012 = "Execution Test Name"
Public Const TESTHARNESS_MESSAGE_7013 = "Test [NAME]"
Public Const TESTHARNESS_MESSAGE_7014 = "Miscellaneous Test [NAME]"
Public Const TESTHARNESS_MESSAGE_7015 = "Correct Usage is: Testharness -test/testsession completePath"
Public Const TESTHARNESS_MESSAGE_7016 = "Test [TEST] failed!"
Public Const TESTHARNESS_MESSAGE_7017 = "Closing database"
Public Const TESTHARNESS_MESSAGE_7018 = "Validating Integrity"
Public Const TESTHARNESS_MESSAGE_7019 = "Tests Database Loading Time [TIME] ms, Verifying integrity [INTEGRITY_TIME] ms"
Public Const TESTHARNESS_MESSAGE_7020 = "The bound checker reference dump file has not been found in the Test Database for the test [NAME]"
Public Const TESTHARNESS_MESSAGE_7021 = "The bound checker reference dump file does not match the temp file for the test [NAME].[CRLF]You may have some memory leak(s)"
Public Const TESTHARNESS_MESSAGE_7022 = "The TestHarness.ini file has not been found please review your options"
Public Const TESTHARNESS_MESSAGE_7023 = "Do you want to add another external test data base ?"
Public Const TESTHARNESS_MESSAGE_7024 = "Item not found [QUERY]"
Public Const TESTHARNESS_MESSAGE_7025 = "Warning:Test [TEST] was skipped"
Public Const TESTHARNESS_MESSAGE_7026 = "[NUMBER] Tests Selected"
Public Const TESTHARNESS_MESSAGE_7027 = "Warning:Session '[SESSION_IN]' in session '[SESSION_PARENT]' skipped"
Public Const TESTHARNESS_MESSAGE_7028 = "Populating the treeview..."
Public Const TESTHARNESS_MESSAGE_7029 = "Executing '[NAME]'"
Public Const TESTHARNESS_MESSAGE_7030 = "Session [NAME]"
Public Const TESTHARNESS_MESSAGE_7031 = "The parameter '[P]' has been defined as required in the test, you must now enter a value."
Public Const TESTHARNESS_MESSAGE_7032 = "The parameter '[P]' has been defined as optional and has been assigned the following default value '[DEFAULTVALUE]'. You may change the value."
Public Const TESTHARNESS_MESSAGE_7033 = "No description for the parameter [P]."
Public Const TESTHARNESS_MESSAGE_7034 = "MetraTech Engineering Team 2001-2004"
Public Const TESTHARNESS_MESSAGE_7035 = " -----------------------------------------------------------------------------------------------------------------------------------------%CRLF% %CRLF% [DESCRIPTION]%CRLF%%CRLF% [CREATIONDATE]           %CREATIONDATE%%CRLF%%CRLF% [AUTHOR]           %AUTHOR%%CRLF%%CRLF% [DEPENDENCIES]%CRLF%%CRLF% [END]%CRLF% -----------------------------------------------------------------------------------------------------------------------------------------%CRLF%"
Public Const TESTHARNESS_MESSAGE_7036 = " -----------------------------------------------------------------------------------------------------------------------------------------%CRLF% %CRLF% [DESCRIPTION]%CRLF%%CRLF% [CREATIONDATE]           %CREATIONDATE%%CRLF%%CRLF% [AUTHOR]           %AUTHOR%%CRLF%%CRLF% [DEPENDENCIES]%CRLF%%CRLF% [PARAMETER]%CRLF%      {Name}%CRLF%      {Description}%CRLF%      {Required}      True%CRLF%      {Type}%CRLF%      {DefaultValue}%CRLF%      {Enum:}%CRLF%%CRLF% [END]%CRLF% -----------------------------------------------------------------------------------------------------------------------------------------%CRLF%"
Public Const TESTHARNESS_MESSAGE_7037 = "Select the path to the Main Test DataBase"
Public Const TESTHARNESS_MESSAGE_7038 = "Do you want to install the Results Database folder environment variable ?"
Public Const TESTHARNESS_MESSAGE_7039 = "Select the path Results Database"
Public Const TESTHARNESS_MESSAGE_7040 = "Do you want to ignore the QA folder ?"
Public Const TESTHARNESS_MESSAGE_7041 = "Running test '[T]' from session '[S]'"
Public Const TESTHARNESS_MESSAGE_7042 = "Report to QARepository session '[S]'"
Public Const TESTHARNESS_MESSAGE_7043 = "Register to QARepository session '[S]'"
Public Const TESTHARNESS_MESSAGE_7044 = "The system '[SYSTEM]' is not registered in the QARepository. Do you want to register it ?"
Public Const TESTHARNESS_MESSAGE_7045 = "Register system '[SYSTEM]' to the QA Repository"
Public Const TESTHARNESS_MESSAGE_7046 = "System Name already registered"
Public Const TESTHARNESS_MESSAGE_7047 = "[DESCRIPTION]%CRLF%[END]%CRLF%"
Public Const TESTHARNESS_MESSAGE_7048 = "Register Engineer"
Public Const TESTHARNESS_MESSAGE_7049 = "Delete Engineer"
Public Const TESTHARNESS_MESSAGE_7050 = "Delete Engineer '[NAME]' ?"
Public Const TESTHARNESS_MESSAGE_7051 = "Update system '[SYSTEM]' to the QA Repository"
Public Const TESTHARNESS_MESSAGE_7052 = "Delete Engineer"
Public Const TESTHARNESS_MESSAGE_7055 = "ReOrder Tests Folder '[NAME]'"
Public Const TESTHARNESS_MESSAGE_7056 = "Re Order the tests?"
Public Const TESTHARNESS_MESSAGE_7057 = "The T: drive has not been detected! Do you want to create it via Subst ?"
Public Const TESTHARNESS_MESSAGE_7058 = "Starting test '[TEST]'..."
Public Const TESTHARNESS_MESSAGE_7059 = "Test completed '[TEST]' Status='[STATUS]' "



' Public constants
Public Const TESTHARNESS_TITLE = "Test Harness"
Public Const TESTHARNESS_TEST_FILE_EXTENSION = "TEST"
Public Const TESTHARNESS_TEST_SESSION_FILE_EXTENSION = "SESSION"
Public Const TESTHARNESS_COMPAREDEF_EXTENSION = "COMPAREDEF"
Public Const TESTHARNESS_TEST_FOLDER_INFO_FILE_NAME = "FOLDER.INFO.XML"
Public Const TESTHARNESS_GLOBAL_ID = "GLOBAL"
Public Const TESTHARNESS_TEST_FILE_XML_ID_TAG = "<ID>"
Public Const TESTHARNESS_EXECUTION_TEST_SELECTOR_STRING = "VBScript|*.vbs;*.wsf;*.wsh|Executable|*.exe;*.com|Batch|*.bat|All Files(*.*)|*.*"
Public Const TESTHARNESS_PARAMETER_VALID_CHARS = "_-.@ABCDEFGHIJKLMNOPQRSTVWUXYZ0123456789"
Public Const TESTHARNESS_EMAIL_SUBJECT = "TestHarness Test Session Status"

Public static_CTDBItem_StrParametersValidChars  As Variant
Public static_DBOutputFileContext               As New CTDBOutputFileContext
Public static_MTTestDataBaseIniFile             As cIniFile
Public static_objDBInfo                         As New CTDBInfo
Public static_Stack                             As CVariantStack

Public g_static_booShowStaticFile               As Boolean

Public g_static_booMainForm                     As Form
Public g_lngItemInitialized                     As Long
Public g_lngMaxItemInitializedInPreviousLoad    As Long
Public m_static_arrayPathsToIgnore              As Variant

Public g_static_IntegrityGUIDList               As Collection
Public g_static_MainDataBaseLoading             As Boolean



Public g_static_TestsClipBoard     As CTDBItems

Public Const g_static_lngRefreshEveryItem = 50

Public EmailMsg As String




Public Function SendEmailMsg(ByVal EmailMsg As String, ByVal EmailTo As String) As Boolean

'Dim mailmsg As New CDONTS.NewMail
'Dim objWinApi As New cWindows
'Dim UserName As String
'
'SendEmailMsg = True
'
'Set mailmsg = CreateObject("CDONTS.NewMail")
'mailmsg.Body = EmailMsg
'mailmsg.Subject = TESTHARNESS_EMAIL_SUBJECT
'mailmsg.To = EmailTo
'
'UserName = objWinApi.UserName()
'mailmsg.From = UserName & "@metratech.com"
'
'On Error GoTo ErrMgr
'
'mailmsg.send
'
'Set mailmsg = Nothing
'Exit Function
'
'ErrMgr: TRACE (TESTHARNESS_ERROR_7014)
'        SendEmailMsg = False

End Function



Public Function MakeString(ByVal varValue As Variant, lngMaxSize As Long) As String

    On Error GoTo ErrMgr

    Dim strS As String
    
    If (IsNull(varValue)) Then varValue = "NULL"
    
    strS = CStr(varValue)
    If (Len(strS) < lngMaxSize) Then
    
        MakeString = strS & Space(lngMaxSize - Len(strS))
    Else
        MakeString = Mid(strS, 1, lngMaxSize)
    End If

    Exit Function
ErrMgr:
        ShowError TESTHARNESS_ERROR_7000 & " " & GetVBErrorString(), "MTTestDatabaseModule", "MakeString"
End Function
