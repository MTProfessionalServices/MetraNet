VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cTextFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        : CTextFile
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  : This class is a wrapper for access to a text file and supplie others function related to files.
'                 This class comes from the F.Torres OoVblib6v1. NOT MODIFIED SINCE.
'  VERSION      : none.
'
'**************************************************************************

Option Explicit

Private m_booOpen          As Boolean
Private m_lngHandle        As Long

' DESCRIPTION : The file name associated with the instance.
Private m_lineRead       As Long

' DESCRIPTION : Contains the number
Private m_lineWritten    As Long

' DESCRIPTION : The file name associated with the instance.
' REMARKS     : Should be converted into a property.
Public fileName          As String

' DESCRIPTION : Event description
' REMARKS     : Event Remarks
Public Event Click()

' DESCRIPTION : Type description
' REMARKS     : Type Remarks
' AUTHOR      : Jose de las vegas
Private Type TCFILE
    fileName    As String
    FileHandle  As Long
End Type

' DocJet does not support to comment enum or I do not know how to make it work.
' DESCRIPTION : Enum description
Public Enum CTextFile_OPEN_MODE
    OPEN_MODE_READ
    OPEN_MODE_WRITE
    OPEN_MODE_APPEND
End Enum


' ---------------------------------------------------------------------------
' FUNCTION          : FileCopy
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           :
' DESCRIPTION       : Copy a file! Attention the creation date and last modified date are
'                     Copied too!
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function FileCopy(ByVal sourceFileName As String, ByVal destFileName As String) As Boolean

  On Error GoTo ErrMgr
  
  FileCopy = True
  VBA.FileCopy sourceFileName, destFileName
  Exit Function
  
ErrMgr:
  FileCopy = False
  Err.Clear
  
End Function

' ---------------------------------------------------------------------------
' FUNCTION          : DeleteFiles
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           :
' DESCRIPTION       : Deletes files from a folder based on a wildcard like *.*.
'                     Be carefull.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function DeleteFiles(path As String, wildCard As String) As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
 
    Dim MyName  As String
    
    MyName = Dir(path & "\" & wildCard, vbNormal)
    Do While MyName <> ""
        If MyName <> "." And MyName <> ".." Then
            If Not DeleteFile(path & "\" & MyName) Then DeleteFiles = False
        End If
        MyName = Dir
    Loop
    DeleteFiles = True

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function

' ---------------------------------------------------------------------------
' FUNCTION          : GetPathFromFileName
' INPUT ARGUMENTS   :
'                       strFileName - The file name, a path + a file name.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : A path string
' DESCRIPTION       : Returns the path from a path + file name string. Returns "" if failed.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function GetPathFromFileName(strFileName As String) As String

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
 
    Dim i As Integer: i = Len(strFileName)
    
    If strFileName = "" Then Exit Function
    
    Do While (i > 0) And (Mid(strFileName, i, 1) <> "\")
        i = i - 1
        If i = 0 Then Exit Do
    Loop
    If i = 0 Then
        GetPathFromFileName = ""
    Else
        GetPathFromFileName = Mid(strFileName, 1, i - 1)
    End If

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function

' ---------------------------------------------------------------------------
' FUNCTION          : GetFileName
' INPUT ARGUMENTS   :
'                       strFileName : The file name, a path + a file name.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Returns the filename without the path. Returns "" if failed.
' DESCRIPTION       :
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function GetFileName(strFileName As String) As String

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
 
    Dim s As String
    Dim i As Integer
    
    GetFileName = ""
    If strFileName = "" Then Exit Function
    
    i = Len(strFileName)
    s = ""
    While i > 1 And Mid(strFileName, i, 1) <> "\"
        s = Mid(strFileName, i, 1) + s
        i = i - 1
    Wend
    GetFileName = s

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler
    
End Function

' ---------------------------------------------------------------------------
' FUNCTION          : RenameFile
' INPUT ARGUMENTS   :
'                       strOldFileName - The old file name.
'                       strNewFileName - The new file name.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if ok.
' DESCRIPTION       : 2/28/00 10:16:25 PM
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function RenameFile(strOldFileName As String, strNewFileName As String) As Integer

  On Error GoTo ErrMgr
          
        Name strOldFileName As strNewFileName
        RenameFile = True
        
  Exit Function
ErrMgr:
  
End Function


' ---------------------------------------------------------------------------
' FUNCTION          : DeleteFile
' INPUT ARGUMENTS   :
'                       strFileName : The file name to delete.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if ok.
' DESCRIPTION       : 2/28/00 10:17:46 PM
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function DeleteFile(strFileName As String) As Boolean
 
  On Error GoTo ErrMgr
      
    Kill strFileName
    DeleteFile = True
    
  Exit Function
ErrMgr:
  
End Function


' ---------------------------------------------------------------------------
' FUNCTION          : OpenFile
' INPUT ARGUMENTS   :
'                       strFileName - The text file name to open.
' OUTPUT ARGUMENTS  :
'                       eOpenMode - The opening file mode. Default value is read.
' RETURNS           : TRUE if ok.
' DESCRIPTION       : Open a file with a mode (READ, WRITE, APPEND). If the mode is READ, the file can be
'                     read by other application. The file is SHARED.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function OpenFile(strFileName As String, Optional eOpenMode As CTextFile_OPEN_MODE = CTextFile_OPEN_MODE.OPEN_MODE_READ) As Boolean

    On Error GoTo ErrMgr
    
    Me.fileName = strFileName
    m_lineRead = 0
    m_lineWritten = 0
    
    m_lngHandle = FreeFile
    
    Select Case eOpenMode
    
        Case OPEN_MODE_APPEND
            Open strFileName For Append As m_lngHandle
            
        Case OPEN_MODE_READ
            Open strFileName For Input Access Read Shared As m_lngHandle
            
        Case OPEN_MODE_WRITE
            Open strFileName For Output As m_lngHandle
            
    End Select
    
    m_booOpen = True
    OpenFile = True
    
Exit Function

ErrMgr:
    
End Function

' ---------------------------------------------------------------------------
' FUNCTION          : CloseFile
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if ok.
' DESCRIPTION       : Close the opened file. This function can be called if the file
'                     is not opened.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function CloseFile() As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    If m_booOpen Then
        Close #m_lngHandle
        m_booOpen = False
    End If
    CloseFile = True

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function
 

' ---------------------------------------------------------------------------
' FUNCTION          : Writeln
' INPUT ARGUMENTS   :
'                       strS - the string to write.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if ok.
' DESCRIPTION       : Write a string to the file. Does not work if the file is opened is READ mode.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function Writeln(ByVal strS As String) As Boolean

  On Error GoTo ErrMgr
  
  Print #m_lngHandle, strS
  m_lineWritten = m_lineWritten + 1
  Writeln = True
  Exit Function
  
ErrMgr:
  
End Function


' ---------------------------------------------------------------------------
' FUNCTION          : ReadLn
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Return the string read. If the function failed the function returns "".
' DESCRIPTION       :
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function ReadLn() As String
 
  Dim strS As String
  
  On Error GoTo ErrMgr
  
  Line Input #m_lngHandle, strS
  ReadLn = strS
  m_lineRead = m_lineRead + 1
  Exit Function
ErrMgr:
  
End Function


' ---------------------------------------------------------------------------
' FUNCTION          : Class_Initialize
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           :
' DESCRIPTION       : The constructor
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Private Sub Class_Initialize()

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
    m_booOpen = False

    Exit Sub ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Sub


' ---------------------------------------------------------------------------
' FUNCTION          : Class_Terminate
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           :
' DESCRIPTION       : The destructor. Close the file if it is opened.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Private Sub Class_Terminate()

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    CloseFile

    Exit Sub ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Sub


' ---------------------------------------------------------------------------
' FUNCTION          : ExistFile
' INPUT ARGUMENTS   :
'                       strFileName - The file name to test if it is valid.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if the file exist.
' DESCRIPTION       : The function does not return if the file is locked, by Exced for instance.
' AUTHOR            : FTorres
' REMARKS           : No Remark
' ---------------------------------------------------------------------------
Public Function ExistFile(strFileName As String) As Boolean

    On Error GoTo ErrMgr
  
    Dim lngFreeFile As Integer
  
    lngFreeFile = FreeFile()
  
    Open strFileName For Input Access Read Shared As lngFreeFile
    Close #lngFreeFile
    ExistFile = True
    
    Exit Function
ErrMgr:
      
End Function

' ---------------------------------------------------------------------------
' FUNCTION          : CountLines
' INPUT ARGUMENTS   :
'                       strFileName : the filename to count the line.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Returns the number of line. If the function failed return -1.
' DESCRIPTION       : Returns the number of line.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function CountLines(strFileName As String) As Long

    Dim clsFile As New cTextFile
    Dim s       As String
    Dim lngL    As Long
        
    CountLines = -1
        
    On Error GoTo ErrMgr
    
    If (clsFile.OpenFile(strFileName, OPEN_MODE_READ)) Then
        lngL = 0
        Do While Not clsFile.EOF()
            s = clsFile.ReadLn()
            lngL = lngL + 1
        Loop
        CountLines = lngL
        clsFile.CloseFile
    End If
    Exit Function
ErrMgr:
    
End Function

' ---------------------------------------------------------------------------
' FUNCTION          : View
' INPUT ARGUMENTS   :
'                       strFileName : The file name to view.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE if ok.
' DESCRIPTION       : View a file with the notepad.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function View(strFileName As String) As Boolean

    On Error GoTo ErrMgr
    
    Shell "notepad.exe " & strFileName, vbNormalFocus
    View = True
    
    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function

' ---------------------------------------------------------------------------
' FUNCTION          : LoadTxtFileIn1String
' INPUT ARGUMENTS   :
'                       strFileName : The file name to read.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : String. If the function failed the function returns "".
' DESCRIPTION       : Returns the all text file in one string. CRLF are use as a line separator.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function LoadTxtFileIn1String(strFileName As String) As String

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
 
    Dim s As String
    If OpenFile(strFileName) Then
        Do While Not EOF
            s = s & ReadLn() & vbCrLf
        Loop
        CloseFile
        LoadTxtFileIn1String = s
    End If

    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function

' ---------------------------------------------------------------------------
' FUNCTION          : CompareTextFiles
' INPUT ARGUMENTS   :
'                       strfileName1, strfileName2 : The file name to compare.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : TRUE, if the 2 files are equal.
' DESCRIPTION       : Compare 2 text file are returns TRUE, if they are equal.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function CompareTextFiles(strFileName1 As String, strFilename2 As String) As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler
 
    Dim f1      As New cTextFile
    Dim f2      As New cTextFile
    Dim s1      As String
    Dim s2      As String
    Dim lngLine As Long
    
    If f1.OpenFile(strFileName1) Then
    
        If f2.OpenFile(strFilename2) Then
            
            Do While Not f1.EOF
            
                lngLine = lngLine + 1
                s1 = f1.ReadLn
                s2 = f2.ReadLn
                If s1 <> s2 Then
                    Debug.Print strFileName1
                    Debug.Print strFilename2
                    Debug.Print "LINE:" & lngLine
                    Debug.Print s1
                    Debug.Print s2
                    CompareTextFiles = False
                    Exit Do
                End If
            Loop
            f2.CloseFile
            CompareTextFiles = True
        End If
        f1.CloseFile
    End If
    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function



' ---------------------------------------------------------------------------
' FUNCTION          : LinesRead
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Returns the number of line read, since the file was opened.
' DESCRIPTION       :
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Property Get LinesRead() As Long

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    LinesRead = m_lineRead

    Exit Property ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Property

' ---------------------------------------------------------------------------
' FUNCTION          : LinesWritten
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Returns the number of lines written since the file was opened.
' DESCRIPTION       : 2/28/00 10:39:42 PM
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Property Get LinesWritten() As Long

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    LinesWritten = m_lineWritten

    Exit Property ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Property

' ---------------------------------------------------------------------------
' FUNCTION          : EOF
' INPUT ARGUMENTS   :
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT :
' RETURNS           : Returns TRUE, if the End Of File is reached. This function works only
'                     if the file is opened in READ mode.
' DESCRIPTION       : 2/28/00 10:40:05 PM
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Property Get EOF() As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    EOF = VBA.EOF(m_lngHandle)

    Exit Property ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Property


' ---------------------------------------------------------------------------
' FUNCTION          : LogFile
' INPUT ARGUMENTS   :
'                       strFileName - The file name in which we are going to loga string.
'                       strMessage  - The string to log.
' OUTPUT ARGUMENTS  :
' OPTIONAL ARGUMENT : booCreate   : We can force the file to be re-created. Default value is false.
' RETURNS           : TRUE if ok.
' DESCRIPTION       : Log the string strMessage at the end of the file strFileName. If the file name
'                     does not exist it is created. The file is opened in exclusiv mode.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function LogFile(strFileName As String, strMessage As String, Optional booCreate As Boolean = False) As Boolean

    On Error GoTo ErrMgr ' @VbAddCode.ErrorHandler

    If (booCreate) Then Me.DeleteFile strFileName
    
    If Me.OpenFile(strFileName, IIf(ExistFile(strFileName), OPEN_MODE_APPEND, OPEN_MODE_WRITE)) Then
    
        Me.Writeln strMessage
        Me.CloseFile
        LogFile = True
    End If
    
    Exit Function ' @VbAddCode.ErrorHandler
ErrMgr:     ' @VbAddCode.ErrorHandler

End Function

' ---------------------------------------------------------------------------
' FUNCTION          : GetDir
' INPUT ARGUMENTS   :
'                       strPath - The path to read.
' OUTPUT ARGUMENTS  :
'                       varDirList : varDirList is a variant so it can support to kind of output format.
'                                  If it is a string the result is returned is CSV format
'                                  Else must be a collection.
'                                  This Is kept for REMARKS al reason.
'                       strWildCard : The kind of file we want to read. Default value is *.*.
' RETURNS           :
' DESCRIPTION       : Return a filename list from the folder strPath
'                     Default wildcard is *.*.
' AUTHOR            : FTorres
' REMARKS           :
' ---------------------------------------------------------------------------
Public Function GetDir(strPath As String, varDirList As Variant, Optional strWildCard As String = "*.*") As Boolean

    On Error GoTo ErrMgr
    
    Dim strFileName  As String
    
    strFileName = Dir(strPath & "\" & strWildCard, vbNormal)
    Do While strFileName <> ""
        If strFileName <> "." And strFileName <> ".." Then
        
            If VarType(varDirList) = vbString Then
                ' Return result as a string
                varDirList = varDirList & strFileName & ","
            Else
                ' Return result as a collection
                varDirList.Add strFileName
            End If
        End If
        strFileName = Dir
    Loop
    If VarType(varDirList) = vbString Then varDirList = Left(varDirList, Len(varDirList) - 1)
    
    GetDir = True
    Exit Function
    
ErrMgr:
    Err.Clear
End Function

