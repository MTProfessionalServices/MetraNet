'*******************************************************************************
'*
'* Copyright 2000-2009 by MetraTech Corp.
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corp. MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corp. MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corp.,
'* and USER agrees to preserve the same.
'*
'* Name:        replaceCfgPaths.vbs
'* Created By:  Mike Pento
'* Description: Replace path strings in key.cfg.
'*
'*******************************************************************************

' Require explicit declarations
option explicit

' **
' * Function: replaceCfgPaths()
' * Description: Replace hard coded paths in key.cfg file
' * with [INSTALLDIR] & "RMP" from InstallShield CustomActionData
' * value.
' **
Function replaceCfgPaths()
	Dim FileContents
	Dim dFileContents
	Dim Find
	Dim ReplaceWith
	Dim FileName
	
	' init
	Find="R:"
	ReplaceWith = session.Property("CustomActionData") & "RMP"  
	FileName = session.Property("CustomActionData") & "RMP\Config\Security\key.cfg" 
	
	' read contents of config file
	FileContents = getCfgFile(FileName)

	' replace all strings in contents
	dFileContents = replace(FileContents, Find, ReplaceWith, 1, -1, 1)

	' compare source and results ...
	if dFileContents <> FileContents Then
		' ... write result if different from source
		writeCfgFile FileName, dFileContents	
	End If	
End Function 

' **
' * Function: getCfgFile(FileName)
' * Description: Read contents of config file.
' **
Function getCfgFile(FileName)
  If FileName<>"" Then
    Dim FS, FileStream
    Set FS = CreateObject("Scripting.FileSystemObject")
      on error resume Next
      Set FileStream = FS.OpenTextFile(FileName)
      getCfgFile = FileStream.ReadAll
  End If
End Function

' **
' * Function: writeCfgFile(FileName, Contents)
' * Description: Write string contents to file FileName.
' **
Function writeCfgFile(FileName, Contents)
  Dim OutStream
  Dim FS

  on error resume Next
  Set FS = CreateObject("Scripting.FileSystemObject")
    Set OutStream = FS.OpenTextFile(FileName, 2, True)
    OutStream.Write Contents
End Function
