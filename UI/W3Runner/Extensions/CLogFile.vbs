' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
'
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CLogFile
' DESCRIPTION : Class to manipulate a log file.
'               This class can be use outside of W3Runner.
' SAMPLE      :
'
' ----------------------------------------------------------------------------------------------------------------------------

CLASS CLogFile

  PUBLIC FileName
  Private m_objTextFile

  PRIVATE SUB Class_Initialize()
     CONST CTextFile = "W3RunnerLib.CTextFile"
     Set m_objTextFile = CreateObject(CTextFile)
  END SUB

  PUBLIC PROPERTY GET TextFile() ' As CTextFile
    Set TextFile = m_objTextFile
  END PROPERTY

  PUBLIC FUNCTION Initialize(strFileName) ' As Boolean
    FileName = strFileName
  END FUNCTION

  PUBLIC FUNCTION Clear() ' As Boolean
      If Delete() Then
         Create()
      End If
  END FUNCTION

  PUBLIC FUNCTION Delete() ' As Boolean
      Delete = m_objTextFile.DeleteFile(FileName)
  END FUNCTION

  PUBLIC FUNCTION Create() ' As Boolean
      Create = m_objTextFile.LogFile(FileName,Now() & " *** File Creation *** ",TRUE)
  END FUNCTION

  PUBLIC FUNCTION Add(strString) ' As Boolean
    Add = m_objTextFile.LogFile(FileName,Now() & " " & strString)
  END FUNCTION

  PUBLIC PROPERTY GET EOF() ' As Boolean
    EOF = m_objTextFile.EOF
  END PROPERTY

  PUBLIC FUNCTION ReadLn() ' As String
    ReadLn = m_objTextFile.ReadLn()
  END FUNCTION

  PUBLIC FUNCTION OpenFile() ' As Boolean
    OpenFile = m_objTextFile.OpenFile(FileName)
  END FUNCTION

  PUBLIC FUNCTION CloseFile() ' As Boolean
    CloseFile = m_objTextFile.CloseFile()
  END FUNCTION

END CLASS

