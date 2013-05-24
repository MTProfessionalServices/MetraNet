Attribute VB_Name = "Global2"
Option Explicit

Public Declare Function GetFileVersionInfo _
  Lib "Version.dll" _
  Alias "GetFileVersionInfoA" _
  (ByVal lptstrFilename As String, _
   ByVal dwHandle As Long, _
   ByVal dwLen As Long, _
   lpData As Any) _
  As Long

Public Declare Function GetFileVersionInfoSize _
  Lib "Version.dll" _
  Alias "GetFileVersionInfoSizeA" _
  (ByVal lptstrFilename As String, _
   lpdwHandle As Long) _
  As Long

Public Declare Function VerQueryValue _
  Lib "Version.dll" _
  Alias "VerQueryValueA" _
  (pBlock As Any, _
   ByVal lpSubBlock As String, _
   lplpBuffer As Any, _
   puLen As Long) _
  As Long

Public Declare Sub MoveMemory _
  Lib "kernel32" _
  Alias "RtlMoveMemory" _
  (dest As Any, _
   ByVal Source As Long, _
   ByVal length As Long)


