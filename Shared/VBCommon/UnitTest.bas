Attribute VB_Name = "UnitTestModule"
Option Explicit

Public g_objUTListBox As ListBox

Public Function UT(Optional booExp As Variant, Optional strText As String) As Variant
    If IsMissing(booExp) Then
        UT_Log strText
    Else
        UT = booExp
        If (booExp) Then
            UT_Log strText & " {SUCCEED} "
            
        Else
            UT_Log strText & " {FAILED}  "
        End If
    End If
End Function

Public Function UT_Log(strE As String) As Boolean
    
    Dim objTextFile As New cTextFile
    
    UT_Log = objTextFile.LogFile(UT_LogFileName, Now() & " " & strE)
    
    If (Not g_objUTListBox Is Nothing) Then
    
        g_objUTListBox.AddItem Now() & " " & strE
        g_objUTListBox.ListIndex = g_objUTListBox.NewIndex
    End If
End Function


Public Function UT_LogData(strFileName As String, strData As String) As Boolean

    Dim objTextFile As New cTextFile
    UT_LogData = objTextFile.LogFile(strFileName, strData, True)
End Function


Public Function UT_LogDataAndCompare(strData As String, strRegressionTextFile As String) As Boolean

    Dim objTextFile     As New cTextFile
    Dim strFileName     As String
    Dim lngErrorLine    As Long
    Dim strS1           As String
    Dim strS2           As String
    
    strFileName = App.Path & "\CurrentUnitTestDataFile.txt"
    
    UT_LogData strFileName, strData
    
    If (objTextFile.CompareTextFiles(strFileName, strRegressionTextFile, lngErrorLine, strS1, strS2)) Then
        UT_LogDataAndCompare = True
    Else
        UT , "File Compare Error : Line# " & lngErrorLine
        UT , "File Compare Error : File  " & strFileName
        UT , "File Compare Error : Line  " & strS1
        
        UT , "File Compare Error : File  " & strRegressionTextFile
        UT , "File Compare Error : Line  " & strS2
        
    End If
    
End Function



Public Function UT_ReadData(strFileName As String) As String

    Dim objTextFile As New cTextFile
    UT_ReadData = objTextFile.LoadTxtFileIn1String(strFileName)
End Function

Public Function UT_LogFileName() As String

    UT_LogFileName = App.Path & "\UnitTest.log"
End Function

Public Function UT_DeleteLogFileName() As Boolean
    Dim objTextFile As New cTextFile
    
    UT_DeleteLogFileName = objTextFile.DeleteFile(UT_LogFileName)

End Function
