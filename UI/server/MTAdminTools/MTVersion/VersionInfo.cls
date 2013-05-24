VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "VersionInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


' API Calls for getting a file's version information
Public Type FileVersion
  FileVersion As String               ' Full file version as a string
  FileVersionMSl As Integer           ' File version MSB Low
  FileVersionMSh As Integer           ' File version MSB High
  FileVersionLSl As Integer           ' File version LSB Low
  FileVersionLSh As Integer           ' File version LSB High
  ProductVersion As String            ' File product version as a string
  ProductVersionMSl As Integer        ' Product version MSB low
  ProductVersionMSh As Integer        ' Product version MSB high
  ProductVersionLSl As Integer        ' Product version LSB low
  ProductVersionLSh As Integer        ' Product version LSB high
End Type

Public Type VS_FIXEDFILEINFO
   dwSignature As Long
   dwStrucVersionl As Integer
   dwStrucVersionh As Integer
   dwFileVersionMSl As Integer
   dwFileVersionMSh As Integer
   dwFileVersionLSl As Integer
   dwFileVersionLSh As Integer
   dwProductVersionMSl As Integer
   dwProductVersionMSh As Integer
   dwProductVersionLSl As Integer
   dwProductVersionLSh As Integer
   dwFileFlagsMask As Long
   dwFileFlags As Long
   dwFileOS As Long
   dwFileType As Long
   dwFileSubtype As Long
   dwFileDateMS As Long
   dwFileDateLS As Long
End Type


'----------------------------------------------------------------------------
'  EVENTS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: onstartpage
'   Description:  Set up the ASP variable.  Call during CreateObject
'   Parameters: sc As ScriptingContext
'   Return Value: none
'-----------------------------------------------------------------------------
Public Sub onstartpage(sc As ASPTypeLibrary.ScriptingContext)
       Set response = sc.response
       Set session = sc.session
       Set server = sc.server
       Set request = sc.request
       Set application = sc.application
End Sub

'----------------------------------------------------------------------------
'   Name: GetMetraTechVersionInformation
'   Description: Prints a table row containing file version information
'   Parameters: strFileName - Name of the file
'   Returns: Nothing
'-----------------------------------------------------------------------------
Public Sub GetMetraTechVersionInformation(strFileName As String)
  Dim lngRC As Long
  Dim lngDummy As Long
  Dim abytBuffer() As Byte
  Dim lngBufferLen As Long
  Dim lngVerPointer As Long
  Dim udtVerBuffer As VS_FIXEDFILEINFO
  Dim lngVerbufferLen As Long
  Dim recFileVer As FileVersion
  Dim fso As New FileSystemObject
  Dim f As File
  Dim dateLastModified As Date
  Static bEven As Boolean
  
  On Error GoTo PROC_ERR
  
  ' Get the size
  lngBufferLen = GetFileVersionInfoSize(strFileName, lngDummy)
  If lngBufferLen < 1 Then
     Exit Sub
  End If

  ' Set up the byte array
  ReDim abytBuffer(lngBufferLen)
  
  'Get the file last date modified
  Set f = fso.GetFile(strFileName)
  dateLastModified = f.dateLastModified

  
  ' Get the file version information
  lngRC = GetFileVersionInfo(strFileName, 0&, lngBufferLen, abytBuffer(0))
  lngRC = VerQueryValue(abytBuffer(0), "\", lngVerPointer, lngVerbufferLen)
  
  ' Manipulate the bits
  MoveMemory udtVerBuffer, lngVerPointer, Len(udtVerBuffer)

  ' Build the file version string
  recFileVer.FileVersion = _
    Format$(udtVerBuffer.dwFileVersionMSh) & "." & _
    Format$(udtVerBuffer.dwFileVersionMSl) & "." & _
    Format$(udtVerBuffer.dwFileVersionLSh) & "." & _
    Format$(udtVerBuffer.dwFileVersionLSl)
                            
  recFileVer.FileVersionLSh = udtVerBuffer.dwFileVersionLSh
  recFileVer.FileVersionLSl = udtVerBuffer.dwFileVersionLSl
  recFileVer.FileVersionMSh = udtVerBuffer.dwFileVersionMSh
  recFileVer.FileVersionMSl = udtVerBuffer.dwFileVersionMSl
  
  ' Build the product version string
  recFileVer.ProductVersion = _
    Format$(udtVerBuffer.dwProductVersionMSh) & "." & _
    Format$(udtVerBuffer.dwProductVersionMSl) & "." & _
    Format$(udtVerBuffer.dwProductVersionLSh) & "." & _
    Format$(udtVerBuffer.dwProductVersionLSl)
        
  recFileVer.ProductVersionLSh = udtVerBuffer.dwProductVersionLSh
  recFileVer.ProductVersionLSl = udtVerBuffer.dwProductVersionLSl
  recFileVer.ProductVersionMSh = udtVerBuffer.dwProductVersionMSh
  recFileVer.ProductVersionMSl = udtVerBuffer.dwProductVersionMSl
  
  If Not bEven Then
    response.Write "      <tr>" & vbNewLine
    response.Write "        <td class = ""clsTableTextOdd"">" & strFileName & "</td>" & vbNewLine
    response.Write "        <td class = ""clsTableTextOdd"">" & recFileVer.FileVersion & "</td>" & vbNewLine
    response.Write "        <td class = ""clsTableTextOdd"">" & dateLastModified & "</td>" & vbNewLine
    response.Write "      </tr>" & vbNewLine
  Else
    response.Write "      <tr>" & vbNewLine
    response.Write "        <td class = ""clsTableTextEven"">" & strFileName & "</td>" & vbNewLine
    response.Write "        <td class = ""clsTableTextEven"">" & recFileVer.FileVersion & "</td>" & vbNewLine
    response.Write "        <td class = ""clsTableTextEven"">" & dateLastModified & "</td>" & vbNewLine
    response.Write "      </tr>" & vbNewLine
  End If
  
  bEven = Not bEven
  
PROC_EXIT:
  Exit Sub
  
PROC_ERR:
  response.Write "Error: " & Err.Number & ". " & Err.Description & "GetResourceVersion"
  Resume PROC_EXIT
  
End Sub





