' --------------------------------------------------------------------------------------------------------------------------------------------
' MetraTech Standard VBScript Test File Client
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
'
' TEST NAME     :  System Check
' AUTHOR        :  Stephen Boyer
' CREATION_DATE :  07/24/2003
' DESCRIPTION   :Checks system for requirements to install MetraNet
' PARAMETERS   :
' --------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit

PUBLIC my_Drive

PUBLIC CONST SHARED_DLLS_PATH		= "MetraTech\RMP\SharedDlls"
PUBLIC CONST DOT_NET_FRAME_PATH		= "WINNT\Microsoft.NET\Framework\v1.0.3705"
PUBLIC CONST PAYMENTSRV_PATH		= "MetraTech\RMP\extensions\paymentsvr\config\verisign\certs"
PUBLIC CONST REG_ENHANCED_SECURITY	= "HKLM\SOFTWARE\Microsoft\Cryptography\Defaults\Provider\Microsoft Enhanced Cryptographic Provider v1.0\Image Path"
PUBLIC CONST REG_NET_FRAMEWORK		= "HKLM\SOFTWARE\Microsoft\.NETFramework\InstallRoot"
PUBLIC CONST REG_SQL				= "HKLM\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\CurrentVersion\CSDVersion"
PUBLIC CONST VER_SQL				= "8.00.760"
PUBLIC CONST  REG_OS_VERSION		= "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CurrentVersion"
PUBLIC CONST VER_OS					= "5"
PUBLIC CONST REG_OS_SERVICE_PK		= "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CSDVersion"
PUBLIC CONST VER_OS_SERVICE_PK		= "3"
PUBLIC CONST REG_IE_VERSION			= "HKLM\SOFTWARE\Microsoft\Internet Explorer\Version"
PUBLIC CONST VER_IE					= "6.0"
PUBLIC CONST REG_MSMQ				= "HKLM\SOFTWARE\Microsoft\MSMQ\Setup\InstalledComponents"

Main() 

'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@ MAIN FUNCTION @@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PUBLIC FUNCTION Main() ' As Boolean
	my_Drive = InputBox ("Please Enter The Drive MetraNet Is To Be Installed On.  "& vbCrLf & vbCrLf& "Note: Do not enter a colon and slash just the letter", "Drive Box","C")
	my_Drive =  UCASE(my_Drive) &":\"
    Main = FALSE
     If Not check("Windows 2000")	then exit function
     If Not checkPermision()		then exit function
     If Not checkMSMQ()				then exit function
     If Not check128()				then exit function
     If Not checkDotNet()			then exit function
     If Not checkPFPRO()			then exit function
     If Not checkSysPath()			then exit function
    Main = TRUE ' Return True if we reached this point.
    If Main then MsgBox "System Check Completed Successfully"

END FUNCTION

'---------------------------------------------------------
'Function to check 128 security
'--------------------------------------------------------
PUBLIC FUNCTION check128()
	check128 = False
	Dim WshShell
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("Set WshShell = CreateObject(WScript.Shell)")  then exit function
	WshShell.RegRead(REG_ENHANCED_SECURITY)
	If checkErrors ("Check to see if 128 BIT SECURITY is in registry") then 
		exit function
		WSCRIPT.ECHO "			***FAILED***"
	End IF
	WSCRIPT.ECHO "128 BIT SECURITY was detected in the System registry"
	WSCRIPT.ECHO "			PASS"
	check128 = true
END FUNCTION
'--------------------------------------------
'Function to check MSMQ
'--------------------------------------------
PUBLIC FUNCTION checkMSMQ()
	checkMSMQ = False
	Dim WshShell
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("Set WshShell = CreateObject(WScript.Shell)")  then exit function
	WshShell.RegRead(REG_MSMQ)
	If checkErrors ("****Check to see if MSMQ is in registry") then 
		exit function
		WSCRIPT.ECHO "			***FAILED***"
	End If
	WSCRIPT.ECHO "MSMQ was detected in the System registry"
	WSCRIPT.ECHO "			PASS"
	checkMSMQ = true
END FUNCTION
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'One Function to Check Various Requirements: Operating System, OS Service Pack, Internet explorer, 
'SQL Server and SP3 --------------------------------------------------------------------------------------------------------------------------------------------------
'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PUBLIC FUNCTION check(my_string)
	check = False
	Dim strValue, intCompare, trimmedStr, nextStr, WshShell, regComponent, verComponent
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("Set WshShell = CreateObject(WScript.Shell)")  then exit function
	select case my_string
		Case "Windows 2000"
			verComponent = VER_OS
			strValue = WshShell.RegRead(REG_OS_VERSION)
			strValue = Left(strValue, 1)
			nextStr = "Service Pack"
		Case "Service Pack"
			verComponent = VER_OS_SERVICE_PK
			strValue = WshShell.RegRead(REG_OS_SERVICE_PK)
			strValue = Right(strValue, 1)
			nextStr = "Internet Explorer"
		Case "Internet Explorer"
			verComponent = VER_IE
			strValue = WshShell.RegRead(REG_IE_VERSION)
			nextStr = "SQL"
		Case "SQL"
			verComponent = VER_SQL
			strValue = WshShell.RegRead(REG_SQL)
			nextStr = ""
	End Select
	intCompare = StrComp(strValue, verComponent)
	Select case intCompare
		Case -1
			WSCRIPT.ECHO "The Version of "  &  my_string & " (" & strValue &") is earlier than the minimum requirement (" & verComponent &")"
			WSCRIPT.ECHO "			***FAILED***"
			Exit Function
		Case 0
			WSCRIPT.ECHO "The Version of "  &  my_string & " (" & strValue &") is equal to the minimum requirement (" & verComponent &")"
			WSCRIPT.ECHO "			PASS"
		Case 1
			WSCRIPT.ECHO "The Version of "  &  my_string & " (" & strValue &") is better than the minimum requirement (" & verComponent &")"			
			WSCRIPT.ECHO "			PASS"
		Case else
			WSCRIPT.ECHO "****Unexpected return Value from Version Comparison" & intCompare
			WSCRIPT.ECHO "			***FAILED***"
			Exit Function
	End Select
	If Not (nextStr = "")  then  check(nextStr)
	check = True
END FUNCTION

'-----------------------------------------------------------------------------------------------------------
'Function to make sure mahine has write capabilities to Winnt temp folder 
'-------------------------------------------------------------------------------------------------------------

PUBLIC FUNCTION checkPermision()
	checkPermision = False
	Dim objFolder
	Dim my_path 
	Dim my_Folder
	my_path  = my_Drive & "WINNT\Temp" 
	Set my_Folder = createObject("Scripting.FileSystemObject")
	If Not (my_Folder.FolderExists(my_path)) Then 
		WSCRIPT.ECHO "WINNT Folder does not exist"
		WSCRIPT.ECHO "			***FAILED***"
		Exit Function
	End if
	Dim strTmpFile, booExist
	strTmpFile = my_Drive & "WINNT\Temp\CheckAccess.txt"
	booExist = CreateObject("MTVBLIB.CTEXTFILE").LogFile(strTmpFile,"blabla",TRUE)
	'Set objFolder =  my_Folder.GetFolder("C:\WINNT\Temp")
	'Msgbox objFolder.Attributes 
	checkPermision = booExist
	WSCRIPT.ECHO "Permission on temp folder ok."
	WSCRIPT.ECHO "			PASS"
End Function

'--------------------------------------------
'Function to check for errors
'--------------------------------------------
PUBLIC FUNCTION checkErrors(sText)
	If (Err.Number <> 0) then
		If (sText <> "") Then
			WSCRIPT.ECHO sText & " : Err.Number=" & Err.Number &" : Err.Description " & Err.Description
		End If
	checkErrors = True
	Err.Number = 0
	Else
		checkErrors = False
	End If
END FUNCTION

'------------------------------------------------
'Check Dot Net Framework
'------------------------------------------------
PUBLIC FUNCTION checkDotNet()
	checkDotNet = False
	Dim WshShell
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("****Set WshShell = CreateObject(WScript.Shell)****")  then exit function
	WshShell.RegRead(REG_NET_FRAMEWORK)
	If checkErrors ("***Check to see if Dot Net Frame work is in registry***") then exit function
	WSCRIPT.ECHO "Dot Net FrameWork  was detected in the System registry...v1.0.3075"
	WSCRIPT.ECHO "			PASS"
	checkDotNet = true	
END FUNCTION

'-------------------------------------------------------------------------
'Check to see if PFPRO_CERT_PATH is set
'-------------------------------------------------------------------------
PUBLIC FUNCTION checkPFPRO()
	checkPFPRO= false
	Dim WshSysEnv, WshShell, strValue, strPath
	strPath = my_Drive & UCASE(PAYMENTSRV_PATH)
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("Set WshShell = CreateObject(WScript.Shell)")  then exit function
	set WshSysEnv = WshShell.Environment("SYSTEM")
	strValue = UCASE(WshSysEnv("PFPRO_CERT_PATH"))
	If InStr(1, strValue, strPath) =0 then
		WSCRIPT.ECHO "The System Path PFPRO_CERT has not been set Correctly, Looking for " & strPath & "  and Found  " & strValue 
		WSCRIPT.ECHO "			***FAILED***"
		MsgBox "If you plan on using payment server you must set the PFRO_CERT_PATH"
	Else
		WSCRIPT.ECHO "The System Path PFPRO has been set correctly..." & strPath
		WSCRIPT.ECHO "			PASS"
	End If
	checkPFPRO= true
END FUNCTION

'-----------------------------------------------------------------------------------------------------------
'Check System Path for shared dlls and framework 1.1.4322
'-----------------------------------------------------------------------------------------------------------
PUBLIC FUNCTION checkSysPath()
	checkSysPath = false
	Dim WshSysEnv, WshShell, strValue, strPathDll, strPathNet
	strPathDll = my_Drive & UCASE (SHARED_DLLS_PATH)
	strPathNet = my_Drive &UCASE (DOT_NET_FRAME_PATH)
	Set WshShell = CreateObject("WScript.Shell")
	If CheckErrors ("Set WshShell = CreateObject(WScript.Shell)")  then exit function
	set WshSysEnv = WshShell.Environment("SYSTEM")
	strValue = UCASE(WshSysEnv("PATH"))
	If inStr(1, strValue, strPathDll) =0 then
		WSCRIPT.ECHO "Shared Dll not included in System Path, Looking for..." & strPathDll
		WSCRIPT.ECHO "			***FAILED***"
		exit function
	else
		WSCRIPT.ECHO "Found Shared Dll in System Path..." & strPathDll
		WSCRIPT.ECHO "			PASS"
	End if
	
	If inStr(1, strValue, strPathNet) =0 then
		WSCRIPT.ECHO "Dot net framework v1.0.3705 not included in System Path, Looking for... " & strPathNet
		WSCRIPT.ECHO "			***FAILED***"
		exit function
	else
		WSCRIPT.ECHO "Found Dot net framework v1.0.3705 in path..." & strPathNet & vbCrLf & " Was Not in System Path "
		WSCRIPT.ECHO "			PASS"
	End if
	checkSysPath = true
END FUNCTION
